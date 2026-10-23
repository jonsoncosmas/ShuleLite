<?php
declare(strict_types=1);
$asyncRequest = str_contains(strtolower((string)($_SERVER['HTTP_ACCEPT'] ?? '')), 'application/json');
if ($asyncRequest) ob_start();
session_start();
require dirname(__DIR__) . '/config/config.php';
require_sign_in();
$role = (string)($_SESSION['role'] ?? '');
$uid = (int)($_SESSION['user_id'] ?? 0);
if ($role === 'headteacher') { header('Location: school_setup.php'); exit; }
if (!in_array($role, ['system_admin', 'sub_admin'], true)) { header('Location: notes.php'); exit; }
$db = db();
$error = '';
$saved = isset($_GET['saved']);
$asyncResult = null;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if ($asyncRequest && !hash_equals($_SESSION['csrf'] ?? '', (string)($_POST['csrf'] ?? ''))) {
        http_response_code(400);
        header('Content-Type: application/json; charset=utf-8');
        if (ob_get_level()) ob_clean();
        echo json_encode(['ok'=>false,'message'=>'Your session expired. Refresh the page and try again.']);
        exit;
    }
    verify_csrf();
    $action = (string)($_POST['action'] ?? '');
    $name = trim((string)($_POST['name'] ?? ''));
    $classId = (int)($_POST['class_id'] ?? 0);
    $classIds = $_POST['class_ids'] ?? [];
    try {
        if ($name === '' || mb_strlen($name) > 100) throw new DomainException('Enter a name within 100 characters.');
        $db->beginTransaction();
        if ($action === 'add_class') {
            if (mb_strlen($name) > 80) throw new DomainException('Class names must be 80 characters or fewer.');
            $q = $db->prepare('INSERT INTO academic_classes(name,created_by) VALUES(?,?)');
            $q->execute([$name, $uid]);
            $entityId = (int)$db->lastInsertId();
            $entity = 'academic_class';
            $asyncResult = ['action'=>'add_class','class'=>['id'=>$entityId,'name'=>$name,'subject_count'=>0]];
        } elseif ($action === 'add_subject') {
            if (!in_array($role, ['system_admin', 'sub_admin'], true)) throw new DomainException('Only system admins and sub admins can add core subjects.');
            if (!is_array($classIds) || !$classIds) throw new DomainException('Choose at least one class.');
            $classIds = array_values(array_unique(array_filter(array_map(static fn($id) => filter_var($id, FILTER_VALIDATE_INT), $classIds))));
            if (!$classIds) throw new DomainException('Choose at least one valid class.');
            $placeholders = implode(',', array_fill(0, count($classIds), '?'));
            $q = $db->prepare("SELECT id FROM academic_classes WHERE id IN ($placeholders)");
            $q->execute($classIds);
            $validClassIds = array_map('intval', $q->fetchAll(PDO::FETCH_COLUMN));
            if (count($validClassIds) !== count($classIds)) throw new DomainException('One or more selected classes are no longer available. Refresh and try again.');
            $find = $db->prepare('SELECT id FROM academic_class_subjects WHERE class_id=? AND name=?');
            $insert = $db->prepare('INSERT INTO academic_class_subjects(class_id,name,created_by) VALUES(?,?,?)');
            $audit = $db->prepare('INSERT INTO audit_logs(actor_id,action,entity_type,entity_id,details) VALUES(?,?,?,?,?)');
            $addedClassIds = [];
            $existingClassIds = [];
            $addedSubjects = [];
            foreach ($validClassIds as $selectedClassId) {
                $find->execute([$selectedClassId, $name]);
                if ($find->fetchColumn()) { $existingClassIds[] = $selectedClassId; continue; }
                $insert->execute([$selectedClassId, $name, $uid]);
                $entityId = (int)$db->lastInsertId();
                $audit->execute([$uid, 'create', 'academic_subject', $entityId, json_encode(['name'=>$name,'class_id'=>$selectedClassId], JSON_THROW_ON_ERROR)]);
                $addedClassIds[] = $selectedClassId;
                $addedSubjects[] = ['id'=>$entityId,'class_id'=>$selectedClassId,'name'=>$name];
            }
            if (!$addedClassIds) throw new DomainException('This subject is already registered for all selected classes.');
            $asyncResult = ['action'=>'add_subject','class_ids'=>$addedClassIds,'existing_class_ids'=>$existingClassIds,'subject'=>$name,'subjects'=>$addedSubjects];
        } elseif ($action === 'rename_class') {
            $id = filter_var($_POST['id'] ?? null, FILTER_VALIDATE_INT);
            if (!$id) throw new DomainException('Choose a valid class.');
            if (mb_strlen($name) > 80) throw new DomainException('Class names must be 80 characters or fewer.');
            $q = $db->prepare('SELECT id,name FROM academic_classes WHERE id=? FOR UPDATE');
            $q->execute([$id]);
            $current = $q->fetch(PDO::FETCH_ASSOC);
            if (!$current) throw new DomainException('That core class no longer exists. Refresh and try again.');
            $q = $db->prepare('UPDATE academic_classes SET name=? WHERE id=?');
            $q->execute([$name, $id]);
            $q = $db->prepare('INSERT INTO audit_logs(actor_id,action,entity_type,entity_id,details) VALUES(?,?,?,?,?)');
            $q->execute([$uid, 'rename', 'academic_class', $id, json_encode(['old_name'=>$current['name'],'new_name'=>$name], JSON_THROW_ON_ERROR)]);
            $asyncResult = ['action'=>'rename_class','class'=>['id'=>(int)$id,'name'=>$name]];
        } elseif ($action === 'delete_class') {
            $id = filter_var($_POST['id'] ?? null, FILTER_VALIDATE_INT);
            if (!$id) throw new DomainException('Choose a valid class.');
            $q = $db->prepare('SELECT id,name FROM academic_classes WHERE id=? FOR UPDATE');
            $q->execute([$id]);
            $current = $q->fetch(PDO::FETCH_ASSOC);
            if (!$current) throw new DomainException('That core class no longer exists. Refresh and try again.');
            $q = $db->prepare('SELECT COUNT(*) FROM academic_class_subjects WHERE class_id=?');
            $q->execute([$id]);
            $subjectCount = (int)$q->fetchColumn();
            $q = $db->prepare('DELETE FROM academic_classes WHERE id=?');
            $q->execute([$id]);
            $q = $db->prepare('INSERT INTO audit_logs(actor_id,action,entity_type,entity_id,details) VALUES(?,?,?,?,?)');
            $q->execute([$uid, 'delete', 'academic_class', $id, json_encode(['name'=>$current['name'],'deleted_core_subject_count'=>$subjectCount], JSON_THROW_ON_ERROR)]);
            $asyncResult = ['action'=>'delete_class','class'=>['id'=>(int)$id,'name'=>$current['name']]];
        } elseif ($action === 'rename_subject') {
            $id = filter_var($_POST['id'] ?? null, FILTER_VALIDATE_INT);
            if (!$id) throw new DomainException('Choose a valid subject.');
            $q = $db->prepare('SELECT id,class_id,name FROM academic_class_subjects WHERE id=? FOR UPDATE');
            $q->execute([$id]);
            $current = $q->fetch(PDO::FETCH_ASSOC);
            if (!$current) throw new DomainException('That core subject no longer exists. Refresh and try again.');
            $q = $db->prepare('UPDATE academic_class_subjects SET name=? WHERE id=?');
            $q->execute([$name, $id]);
            $q = $db->prepare('INSERT INTO audit_logs(actor_id,action,entity_type,entity_id,details) VALUES(?,?,?,?,?)');
            $q->execute([$uid, 'rename', 'academic_subject', $id, json_encode(['old_name'=>$current['name'],'new_name'=>$name,'class_id'=>(int)$current['class_id']], JSON_THROW_ON_ERROR)]);
            $asyncResult = ['action'=>'rename_subject','subject'=>['id'=>(int)$id,'class_id'=>(int)$current['class_id'],'name'=>$name]];
        } elseif ($action === 'delete_subject') {
            $id = filter_var($_POST['id'] ?? null, FILTER_VALIDATE_INT);
            if (!$id) throw new DomainException('Choose a valid subject.');
            $q = $db->prepare('SELECT id,class_id,name FROM academic_class_subjects WHERE id=? FOR UPDATE');
            $q->execute([$id]);
            $current = $q->fetch(PDO::FETCH_ASSOC);
            if (!$current) throw new DomainException('That core subject no longer exists. Refresh and try again.');
            $q = $db->prepare('DELETE FROM academic_class_subjects WHERE id=?');
            $q->execute([$id]);
            $q = $db->prepare('INSERT INTO audit_logs(actor_id,action,entity_type,entity_id,details) VALUES(?,?,?,?,?)');
            $q->execute([$uid, 'delete', 'academic_subject', $id, json_encode(['name'=>$current['name'],'class_id'=>(int)$current['class_id']], JSON_THROW_ON_ERROR)]);
            $asyncResult = ['action'=>'delete_subject','subject'=>['id'=>(int)$id,'class_id'=>(int)$current['class_id'],'name'=>$current['name']]];
        } else {
            throw new DomainException('Choose a valid catalog action.');
        }
        if ($action === 'add_class') {
            $q = $db->prepare('INSERT INTO audit_logs(actor_id,action,entity_type,entity_id,details) VALUES(?,?,?,?,?)');
            $q->execute([$uid, 'create', $entity, $entityId, json_encode(['name'=>$name], JSON_THROW_ON_ERROR)]);
        }
        $db->commit();
        if ($asyncRequest) { header('Content-Type: application/json; charset=utf-8'); if (ob_get_level()) ob_clean(); echo json_encode(['ok'=>true] + $asyncResult, JSON_THROW_ON_ERROR); exit; }
        header('Location: academics.php?saved=1');
        exit;
    } catch (DomainException $e) {
        if ($db->inTransaction()) $db->rollBack();
        $error = $e->getMessage();
    } catch (PDOException $e) {
        if ($db->inTransaction()) $db->rollBack();
        error_log('Academics catalog database error: ' . $e->getMessage());
        $error = $e->getCode() === '23000' ? 'That class or subject already exists.' : 'The catalog item could not be saved.';
    } catch (Throwable $e) {
        if ($db->inTransaction()) $db->rollBack();
        error_log('Academics catalog save error: ' . $e->getMessage());
        $error = 'The catalog item could not be saved.';
    }
    if ($asyncRequest) { header('Content-Type: application/json; charset=utf-8'); if (ob_get_level()) ob_clean(); echo json_encode(['ok'=>false,'message'=>$error], JSON_THROW_ON_ERROR); exit; }
}
$classes = $db->query('SELECT c.id,c.name,COUNT(s.id) subject_count FROM academic_classes c LEFT JOIN academic_class_subjects s ON s.class_id=c.id GROUP BY c.id ORDER BY c.name')->fetchAll();
$subjects = [];
foreach ($db->query('SELECT id,class_id,name FROM academic_class_subjects ORDER BY name')->fetchAll() as $row) $subjects[(int)$row['class_id']][] = $row;
?>
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Academics · ShuleLite</title><link rel="stylesheet" href="assets/app.css"><script defer src="assets/app.js"></script><style>.core-class-entry{display:flex;align-items:center;gap:14px;padding:8px 0;border-bottom:1px solid var(--border)}.core-class-entry details{flex:1;min-width:0}.core-class-entry>details>summary{padding:10px 0;cursor:pointer}.core-class-actions{display:flex;align-items:center;gap:10px;flex:none}.core-subject-chip{gap:8px}.catalog-action{padding:0;border:0;background:transparent;color:var(--primary);font:inherit;font-size:12px;font-weight:700;cursor:pointer}.catalog-remove{display:inline-grid;place-items:center;width:24px;height:24px;border:1px solid var(--border);border-radius:50%;background:var(--surface);color:#a33;font-size:18px;line-height:1;cursor:pointer}.catalog-remove:hover{background:color-mix(in srgb,#a33 9%,var(--surface));border-color:#a33}.catalog-action:focus-visible,.catalog-remove:focus-visible{outline:3px solid #d99156;outline-offset:2px}@media(max-width:560px){.core-class-entry{align-items:flex-start;gap:8px}.core-class-actions{padding-top:10px}}</style></head>
<body><div class="app-shell"><?php require __DIR__ . '/sidebar.php'; ?><main class="main-area">
<header class="topbar"><button class="icon-button menu-toggle" data-menu aria-label="Open navigation" aria-expanded="false">☰</button><div class="crumb">Workspace <span>/</span> Academics</div><div class="top-actions"><span class="role-chip"><?=e(str_replace('_', ' ', $role))?></span><span class="user-name"><?=e($_SESSION['name'] ?? '')?></span></div></header>
<div class="page-content"><section class="welcome-row"><div><div class="eyebrow">ACADEMIC STRUCTURE</div><h1>Academics</h1><p class="muted">Define the standard classes and core subjects available to schools. Schools can display their own local names.</p></div></section>
<?php if ($saved): ?><div class="notice success" role="status">Catalog updated.</div><?php endif; ?><?php if ($error): ?><div class="notice error" role="alert"><?=e($error)?></div><?php endif; ?>
<div id="academic-async-status" class="notice" role="status" hidden></div>
<section class="note-create class-add-card"><div class="eyebrow">CORE CLASS CATALOG</div><h2>Add a class</h2><p class="muted">Create a core class that schools can add to their academic setup.</p><form method="post" class="note-form" data-academic-async><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><input type="hidden" name="action" value="add_class"><label for="class-name">Class name</label><input id="class-name" name="name" maxlength="80" placeholder="e.g. Grade 1" required><button class="button primary" type="submit">Add class</button></form></section>
<?php if(in_array($role,['system_admin','sub_admin'],true)):?><section class="note-create"><div class="eyebrow">CORE SUBJECTS</div><h2>Add a subject</h2><p class="muted">Enter a subject name and select one or more classes. The subject can be shared across classes.</p><form method="post" class="note-form" data-academic-async><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><input type="hidden" name="action" value="add_subject"><fieldset class="subject-class-picker" id="subject-classes"<?=$classes?'':' disabled'?>><?php if(!$classes):?><legend>Classes</legend><p class="muted" data-no-classes>Add a class first. It will appear here immediately.</p><?php else:?><legend>Choose classes</legend><?php foreach($classes as $class):?><label class="subject-class-option"><input type="checkbox" name="class_ids[]" value="<?=$class['id']?>"><span><?=e($class['name'])?></span></label><?php endforeach;?><?php endif;?></fieldset><label for="core-subject-name">Subject name</label><input id="core-subject-name" name="name" maxlength="100" required placeholder="e.g. Mathematics"><button class="button primary" type="submit"<?=!$classes?' disabled':''?>>Add core subject</button></form></section><?php endif;?>
<section class="content-section" id="academic-classes"><h2>Classes and core subjects</h2><?php if (!$classes): ?><div class="empty-state" data-academic-empty><h3>No system classes yet</h3><p>Add a class above before schools can set up their academic structure.</p></div><?php endif; ?>
<?php foreach ($classes as $class): ?><div class="core-class-entry" data-class-id="<?=$class['id']?>"><details class="class-directory-accordion"><summary><span data-class-name><?=e($class['name'])?></span> <span class="count-pill" data-subject-count><?= (int)$class['subject_count']?> core subjects</span></summary><div class="class-directory-content"><?php foreach ($subjects[(int)$class['id']] ?? [] as $subject): ?><span class="assignment-chip core-subject-chip" data-subject-id="<?=$subject['id']?>"><span data-subject-name><?=e($subject['name'])?></span><button class="catalog-action" type="button" data-catalog-action="rename_subject" data-id="<?=$subject['id']?>">Rename</button><button class="catalog-remove" type="button" data-catalog-action="delete_subject" data-id="<?=$subject['id']?>" aria-label="Remove <?=e($subject['name'])?> subject" title="Remove subject">×</button></span><?php endforeach; ?></div></details><div class="core-class-actions"><button class="catalog-action" type="button" data-catalog-action="rename_class" data-id="<?=$class['id']?>">Rename class</button><button class="catalog-remove" type="button" data-catalog-action="delete_class" data-id="<?=$class['id']?>" aria-label="Remove <?=e($class['name'])?> class" title="Remove class">×</button></div></div><?php endforeach; ?>
</section></div></main></div><script>
document.addEventListener('submit',async event=>{
 const form=event.target.closest('form[data-academic-async]');if(!form)return;event.preventDefault();
 const button=form.querySelector('button[type="submit"]')||form.querySelector('button'),status=document.querySelector('#academic-async-status'),oldLabel=button?.textContent;
 if(form.querySelector('[name="action"]').value==='add_subject'&&!form.querySelector('input[name="class_ids[]"]:checked')){status.hidden=false;status.className='notice error';status.textContent='Select at least one class for this subject.';return;}
 if(button){button.disabled=true;button.textContent='Saving...';}
 try{
  const response=await fetch(location.href,{method:'POST',body:new FormData(form),headers:{Accept:'application/json'},credentials:'same-origin'}),raw=await response.text();let data;try{data=JSON.parse(raw)}catch(parseError){console.error('Academics request returned non-JSON:',raw);throw new Error('The server returned an invalid response. Check the PHP error log and try again.');}
  if(!response.ok||!data.ok)throw new Error(data.message||'Could not save this catalog item.');
  if(data.action==='add_class'){
   document.querySelector('[data-academic-empty]')?.remove();
   const entry=document.createElement('div');entry.className='core-class-entry';entry.dataset.classId=data.class.id;const details=document.createElement('details');details.className='class-directory-accordion';
   const summary=document.createElement('summary'),className=document.createElement('span');className.dataset.className='';className.textContent=data.class.name;summary.append(className,document.createTextNode(' '));const count=document.createElement('span');count.className='count-pill';count.dataset.subjectCount='';count.textContent='0 core subjects';summary.append(count);
   const content=document.createElement('div');content.className='class-directory-content';const actions=document.createElement('div');actions.className='core-class-actions';const rename=document.createElement('button');rename.className='catalog-action';rename.type='button';rename.dataset.catalogAction='rename_class';rename.dataset.id=data.class.id;rename.textContent='Rename class';const remove=document.createElement('button');remove.className='catalog-remove';remove.type='button';remove.dataset.catalogAction='delete_class';remove.dataset.id=data.class.id;remove.setAttribute('aria-label',`Remove ${data.class.name} class`);remove.title='Remove class';remove.textContent='×';actions.append(rename,remove);
   details.append(summary,content);entry.append(details,actions);document.querySelector('#academic-classes').append(entry);
   <?php if(in_array($role,['system_admin','sub_admin'],true)): ?>
   const classPicker=document.querySelector('#subject-classes');if(classPicker){classPicker.disabled=false;classPicker.querySelector('[data-no-classes]')?.remove();if(!classPicker.querySelector('legend')){const legend=document.createElement('legend');legend.textContent='Choose classes';classPicker.append(legend);}const label=document.createElement('label');label.className='subject-class-option';const checkbox=document.createElement('input');checkbox.type='checkbox';checkbox.name='class_ids[]';checkbox.value=data.class.id;const text=document.createElement('span');text.textContent=data.class.name;label.append(checkbox,text);classPicker.append(label);const addSubjectButton=classPicker.form.querySelector('button[type="submit"]');if(addSubjectButton)addSubjectButton.disabled=false;}
   <?php endif; ?>
  }else{
   data.subjects.forEach(subject=>{const details=document.querySelector(`[data-class-id="${CSS.escape(String(subject.class_id))}"]`);if(!details)return;const chip=document.createElement('span'),label=document.createElement('span'),rename=document.createElement('button'),remove=document.createElement('button');chip.className='assignment-chip core-subject-chip';chip.dataset.subjectId=subject.id;label.dataset.subjectName='';label.textContent=subject.name;rename.className='catalog-action';rename.type='button';rename.dataset.catalogAction='rename_subject';rename.dataset.id=subject.id;rename.textContent='Rename';remove.className='catalog-remove';remove.type='button';remove.dataset.catalogAction='delete_subject';remove.dataset.id=subject.id;remove.setAttribute('aria-label',`Remove ${subject.name} subject`);remove.title='Remove subject';remove.textContent='×';chip.append(label,rename,remove);details.querySelector('.class-directory-content').append(chip);const count=details.querySelector('[data-subject-count]'),number=Number(count.textContent.match(/\d+/)?.[0]||0)+1;count.textContent=number+' core subjects';});
  }
  if(form.querySelector('[name="action"]').value==='add_class')form.reset();else form.querySelector('[name="name"]').value='';
  status.hidden=false;status.className='notice success';status.textContent=data.action==='add_subject'?`Subject added to ${data.class_ids.length} class${data.class_ids.length===1?'':'es'}${data.existing_class_ids?.length?`; skipped ${data.existing_class_ids.length} where it already existed`:''}.`:'Catalog item saved.';
 }catch(error){status.hidden=false;status.className='notice error';status.textContent=error.message||'Catalog item could not be saved.';}
 finally{if(button){button.disabled=false;button.textContent=oldLabel;}}
});
document.addEventListener('click',async event=>{
 const button=event.target.closest('[data-catalog-action]');if(!button||button.disabled)return;event.preventDefault();
 const action=button.dataset.catalogAction,id=button.dataset.id,status=document.querySelector('#academic-async-status'),details=button.closest('[data-class-id]');if(!details||!id)return;
 const isClass=action.endsWith('_class'),currentNode=isClass?details.querySelector('[data-class-name]'):button.closest('[data-subject-id]')?.querySelector('[data-subject-name]');if(!currentNode)return;
 const oldName=currentNode.textContent.trim(),isDelete=action.startsWith('delete_');let nextName=oldName;
 if(isDelete){const message=action==='delete_class'?`Remove core class “${oldName}” and its core subjects? Existing school class names and records will remain; their links to this core class will be cleared.`:`Remove core subject “${oldName}”? Existing school subject names and records will remain; their links to this core subject will be cleared.`;if(!confirm(message))return;}
 else{const proposed=prompt(`Rename ${isClass?'class':'subject'}:`,oldName);if(proposed===null)return;nextName=proposed.trim();if(!nextName){status.hidden=false;status.className='notice error';status.textContent='Enter a name before saving.';return}if(nextName===oldName)return;}
 button.disabled=true;const formData=new FormData();formData.set('csrf',document.querySelector('form[data-academic-async] [name="csrf"]')?.value||'');formData.set('action',action);formData.set('id',id);formData.set('name',isDelete?oldName:nextName);
 try{const response=await fetch(location.href,{method:'POST',body:formData,headers:{Accept:'application/json'},credentials:'same-origin'});let data;try{data=await response.json()}catch{throw new Error('The server returned an invalid response. Refresh and try again.')}if(!response.ok||!data.ok)throw new Error(data.message||'Could not update the core catalog.');
  if(action==='rename_class'){details.querySelector('[data-class-name]').textContent=data.class.name;details.querySelector('[data-catalog-action="delete_class"]')?.setAttribute('aria-label',`Remove ${data.class.name} class`);}
  else if(action==='rename_subject'){const chip=button.closest('[data-subject-id]');chip.querySelector('[data-subject-name]').textContent=data.subject.name;chip.querySelector('[data-catalog-action="delete_subject"]')?.setAttribute('aria-label',`Remove ${data.subject.name} subject`);}
  else if(action==='delete_subject'){const chip=button.closest('[data-subject-id]');chip.remove();const count=details.querySelector('[data-subject-count]'),number=Math.max(0,Number(count.textContent.match(/\d+/)?.[0]||0)-1);count.textContent=number+' core subject'+(number===1?'':'s');}
  else if(action==='delete_class'){details.remove();const classPicker=document.querySelector('#subject-classes'),option=[...classPicker.querySelectorAll('.subject-class-option')].find(label=>label.querySelector('input')?.value===String(id));option?.remove();if(!classPicker.querySelector('input[name="class_ids[]"]')){classPicker.disabled=true;if(!classPicker.querySelector('[data-no-classes]')){const note=document.createElement('p');note.className='muted';note.dataset.noClasses='';note.textContent='Add a class first. It will appear here immediately.';classPicker.append(note)}const addSubjectButton=classPicker.form.querySelector('button[type="submit"]');if(addSubjectButton)addSubjectButton.disabled=true;}if(!document.querySelector('#academic-classes [data-class-id]')){const empty=document.createElement('div');empty.className='empty-state';empty.dataset.academicEmpty='';const title=document.createElement('h3'),copy=document.createElement('p');title.textContent='No system classes yet';copy.textContent='Add a class above before schools can set up their academic structure.';empty.append(title,copy);document.querySelector('#academic-classes').append(empty)}}
  status.hidden=false;status.className='notice success';status.textContent=isDelete?`${isClass?'Class':'Subject'} removed from the core catalog.`:`${isClass?'Class':'Subject'} renamed.`;
 }catch(error){status.hidden=false;status.className='notice error';status.textContent=error.message||'Core catalog update failed.';}finally{button.disabled=false}
});
</script></body></html>
