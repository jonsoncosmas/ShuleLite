<?php
declare(strict_types=1);
session_start();
require dirname(__DIR__) . '/config/config.php';
require_sign_in();
$role = $_SESSION['role']; $userId = (int)$_SESSION['user_id'];
$canCreateCentral = in_array($role, ['system_admin','sub_admin'], true);
$canManageCentral = $canCreateCentral;
$canCreateTeacher = in_array($role, ['teacher','head_academic','assistant_academic','examination_officer'], true);
$centralCatalogPairExists = static function (PDO $db, string $classLevel, string $subject): bool {
    $q = $db->prepare('SELECT 1 FROM academic_classes c JOIN academic_class_subjects s ON s.class_id=c.id WHERE c.name=? AND s.name=? LIMIT 1');
    $q->execute([$classLevel, $subject]);
    return (bool)$q->fetchColumn();
};
$error = ''; $success = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $manageAction = (string)($_POST['manage_action'] ?? '');
    if (in_array($manageAction, ['update_central','delete_central'], true)) {
        if (!$canManageCentral) { http_response_code(403); exit('Only system admins and sub admins can manage central notes.'); }
        $noteId=(int)($_POST['note_id']??0);$pdo=db();
        try {
            $pdo->beginTransaction();
            $find=$pdo->prepare("SELECT * FROM learning_notes WHERE id=? AND note_type='central' FOR UPDATE");$find->execute([$noteId]);$current=$find->fetch();
            if(!$current)throw new DomainException('That central note could not be found.');
            if($manageAction==='delete_central'){
                $audit=$pdo->prepare('INSERT INTO audit_logs (actor_id,action,entity_type,entity_id,details) VALUES (?,?,?,?,?)');
                $audit->execute([$userId,'delete','learning_note',$noteId,json_encode(['note_type'=>'central','subtopic'=>$current['subtopic'],'class_level'=>$current['class_level'],'subject'=>$current['subject']],JSON_THROW_ON_ERROR)]);
                $delete=$pdo->prepare("DELETE FROM learning_notes WHERE id=? AND note_type='central'");$delete->execute([$noteId]);
                $pdo->commit();header('Location: notes.php?deleted=1');exit;
            }
            $subtopic=trim((string)($_POST['subtopic']??''));$classLevel=trim((string)($_POST['class_level']??''));$subject=trim((string)($_POST['subject']??''));$topic=trim((string)($_POST['topic']??''));$content=trim((string)($_POST['content']??''));$source=trim((string)($_POST['source']??''));
            if($subtopic===''||$classLevel===''||$subject===''||$topic===''||$content==='')throw new DomainException('Add a subtopic, class, subject, topic, and note content.');
            if(mb_strlen($subtopic)>180||mb_strlen($classLevel)>80||mb_strlen($subject)>100||mb_strlen($topic)>180||mb_strlen($source)>180)throw new DomainException('One or more fields are too long.');
            if(!$centralCatalogPairExists($pdo,$classLevel,$subject))throw new DomainException('Choose a class and subject from the system catalog.');
            $update=$pdo->prepare("UPDATE learning_notes SET subtopic=?,class_level=?,subject=?,topic=?,content=?,source=? WHERE id=? AND note_type='central'");$update->execute([$subtopic,$classLevel,$subject,$topic,$content,$source?:null,$noteId]);
            $term=$pdo->prepare('INSERT IGNORE INTO learning_note_terms (term_type,name,created_by) VALUES (?,?,?)');$term->execute(['class',$classLevel,$userId]);$term->execute(['subject',$subject,$userId]);
            $audit=$pdo->prepare('INSERT INTO audit_logs (actor_id,action,entity_type,entity_id,details) VALUES (?,?,?,?,?)');$audit->execute([$userId,'update','learning_note',$noteId,json_encode(['note_type'=>'central','class_level'=>$classLevel,'subject'=>$subject,'topic'=>$topic],JSON_THROW_ON_ERROR)]);
            $pdo->commit();header('Location: notes.php?updated=1');exit;
        } catch (DomainException $e) {if($pdo->inTransaction())$pdo->rollBack();$error=$e->getMessage();}
          catch (Throwable $e) {if($pdo->inTransaction())$pdo->rollBack();$error='The central note could not be updated. Please try again.';}
    }
    if ($manageAction === '') {
        $type = $canCreateCentral ? 'central' : 'teacher';
        $subtopic = trim((string)($_POST['subtopic'] ?? ''));
        $classLevel = trim((string)($_POST['class_level'] ?? ''));
        $subject = trim((string)($_POST['subject'] ?? ''));
        $topic = trim((string)($_POST['topic'] ?? ''));
        $content = trim((string)($_POST['content'] ?? ''));
        $source = trim((string)($_POST['source'] ?? ''));
        if (!$canCreateCentral && !$canCreateTeacher) { http_response_code(403); exit('You do not have permission to create notes.'); }
        if ($subtopic === '' || $classLevel === '' || $subject === '' || $topic === '' || $content === '') {
            $error = 'Add a subtopic, class, subject, topic, and note content.';
        } elseif (mb_strlen($subtopic) > 180 || mb_strlen($classLevel) > 80 || mb_strlen($subject) > 100 || mb_strlen($topic) > 180 || mb_strlen($source) > 180) {
            $error = 'One or more fields are too long. Shorten the highlighted details and try again.';
        } else {
            try {
                $schoolId = null;
                if ($type === 'central') {
                    if (!$centralCatalogPairExists(db(), $classLevel, $subject)) $error = 'Choose a class and subject from the system catalog.';
                } else {
                    $assignment = db()->prepare('SELECT a.school_id FROM teacher_assignments a JOIN school_classes c ON c.school_id=a.school_id AND c.name=a.class_level JOIN school_class_subjects s ON s.class_id=c.id AND s.name=a.subject JOIN school_memberships m ON m.school_id=a.school_id AND m.user_id=a.user_id WHERE a.user_id = ? AND a.class_level = ? AND a.subject = ? AND a.active = 1 LIMIT 1');
                    $assignment->execute([$userId, $classLevel, $subject]); $assignment = $assignment->fetch();
                    if (!$assignment) { $error = 'Choose a class and subject from your school catalog where you have an active assignment.'; }
                    else $schoolId = (int)$assignment['school_id'];
                }
                if ($error === '') {
                    $pdo = db(); $pdo->beginTransaction();
                    $saveTerm = $pdo->prepare('INSERT IGNORE INTO learning_note_terms (term_type,name,created_by) VALUES (?,?,?)');
                    $saveTerm->execute(['class',$classLevel,$userId]);
                    $saveTerm->execute(['subject',$subject,$userId]);
                    $insert = $pdo->prepare('INSERT INTO learning_notes (note_type,class_level,subject,topic,subtopic,content,source,author_id,school_id) VALUES (?,?,?,?,?,?,?,?,?)');
                    $insert->execute([$type,$classLevel,$subject,$topic,$subtopic,$content,$source ?: null,$userId,$schoolId]);
                    $audit = $pdo->prepare('INSERT INTO audit_logs (actor_id,action,entity_type,entity_id,details) VALUES (?,?,?,?,?)');
                    $audit->execute([$userId,'create','learning_note',(int)$pdo->lastInsertId(),json_encode(['note_type'=>$type,'class_level'=>$classLevel,'subject'=>$subject ?: null,'topic'=>$topic], JSON_THROW_ON_ERROR)]);
                    $pdo->commit(); header('Location: notes.php?saved=1'); exit;
                }
            } catch (Throwable $exception) {
                if (isset($pdo) && $pdo->inTransaction()) $pdo->rollBack();
                $error = 'We could not save this note. Check the database setup and try again.';
            }
        }
    }
}
if (isset($_GET['saved'])) $success = 'Your note has been saved.';
if (isset($_GET['updated'])) $success = 'Central note updated.';
if (isset($_GET['deleted'])) $success = 'Central note deleted.';
$assignments = []; $notes = []; $classOptions=[]; $classSubjectOptions=[]; $loadError = '';
try {
    if ($canCreateTeacher) { $q = db()->prepare('SELECT DISTINCT a.school_id,a.class_level,a.subject FROM teacher_assignments a JOIN school_classes c ON c.school_id=a.school_id AND c.name=a.class_level JOIN school_class_subjects s ON s.class_id=c.id AND s.name=a.subject JOIN school_memberships m ON m.school_id=a.school_id AND m.user_id=a.user_id WHERE a.user_id=? AND a.active=1 ORDER BY a.class_level,a.subject'); $q->execute([$userId]); $assignments = $q->fetchAll(); }
    if ($canCreateCentral) {
        $classOptions=db()->query('SELECT name FROM academic_classes ORDER BY name')->fetchAll(PDO::FETCH_COLUMN);
        $catalogPairs=db()->query('SELECT c.name class_level,s.name subject FROM academic_classes c JOIN academic_class_subjects s ON s.class_id=c.id ORDER BY c.name,s.name')->fetchAll(PDO::FETCH_ASSOC);
        foreach($catalogPairs as $pair)$classSubjectOptions[$pair['class_level']][]=$pair['subject'];
    } elseif ($canCreateTeacher) {
        $q=db()->prepare('SELECT DISTINCT c.name class_level,s.name subject FROM teacher_assignments a JOIN school_classes c ON c.school_id=a.school_id AND c.name=a.class_level JOIN school_class_subjects s ON s.class_id=c.id AND s.name=a.subject JOIN school_memberships m ON m.school_id=a.school_id AND m.user_id=a.user_id WHERE a.user_id=? AND a.active=1 ORDER BY c.name,s.name');$q->execute([$userId]);$catalogPairs=$q->fetchAll(PDO::FETCH_ASSOC);
        foreach($catalogPairs as $pair){$classOptions[]=$pair['class_level'];$classSubjectOptions[$pair['class_level']][]=$pair['subject'];}
        $classOptions=array_values(array_unique($classOptions));
    }
    if ($canManageCentral) {
        $notes = db()->query("SELECT n.*,u.name author_name FROM learning_notes n JOIN users u ON u.id=n.author_id WHERE n.note_type='central' ORDER BY n.updated_at DESC LIMIT 100")->fetchAll();
    } elseif ($role === 'teacher') {
        $q = db()->prepare("SELECT n.*,u.name author_name FROM learning_notes n JOIN users u ON u.id=n.author_id WHERE (n.note_type='teacher' AND EXISTS (SELECT 1 FROM teacher_assignments a JOIN school_memberships m ON m.school_id=a.school_id AND m.user_id=a.user_id WHERE a.user_id=? AND a.active=1 AND a.school_id=n.school_id AND a.class_level=n.class_level AND a.subject=n.subject)) OR (n.note_type='central' AND n.school_id IS NULL AND EXISTS (SELECT 1 FROM teacher_assignments a JOIN school_memberships m ON m.school_id=a.school_id AND m.user_id=a.user_id JOIN school_classes sc ON sc.school_id=a.school_id AND sc.name=a.class_level JOIN school_class_subjects ss ON ss.class_id=sc.id AND ss.name=a.subject LEFT JOIN academic_classes ac ON ac.name=n.class_level LEFT JOIN academic_class_subjects ats ON ats.class_id=ac.id AND ats.name=n.subject WHERE a.user_id=? AND a.active=1 AND (sc.name=n.class_level OR (ac.id IS NOT NULL AND sc.core_class_id=ac.id)) AND (n.subject IS NULL OR n.subject='' OR ss.name=n.subject OR (ats.id IS NOT NULL AND ss.core_subject_id=ats.id)))) ORDER BY n.updated_at DESC LIMIT 200");
        $q->execute([$userId,$userId]); $notes = $q->fetchAll();
    } elseif (in_array($role, ['headteacher','director'], true)) {
        $q = db()->prepare("SELECT n.*,u.name author_name FROM learning_notes n JOIN users u ON u.id=n.author_id WHERE n.note_type='central' AND n.school_id IS NULL OR (n.note_type='teacher' AND EXISTS (SELECT 1 FROM school_memberships m WHERE m.user_id=? AND m.school_id=n.school_id)) ORDER BY n.updated_at DESC LIMIT 500");
        $q->execute([$userId]); $notes = $q->fetchAll();
    } elseif ($canCreateTeacher) {
        $q = db()->prepare("SELECT n.*,u.name author_name FROM learning_notes n JOIN users u ON u.id=n.author_id WHERE n.note_type='central' OR (n.note_type='teacher' AND n.author_id=?) ORDER BY n.updated_at DESC LIMIT 100"); $q->execute([$userId]); $notes = $q->fetchAll();
    } else {
        $notes = db()->query("SELECT n.*,u.name author_name FROM learning_notes n JOIN users u ON u.id=n.author_id WHERE n.note_type='central' ORDER BY n.updated_at DESC LIMIT 100")->fetchAll();
    }
} catch (PDOException $exception) { $loadError = 'Notes are not available yet. Apply the latest database schema and reload this page.'; }
$roleNames = ['system_admin'=>'System admin','sub_admin'=>'Sub admin','admin'=>'Admin','director'=>'Director','sub_director'=>'School manager','headteacher'=>'Head of school','head_academic'=>'Head of academics','assistant_academic'=>'Assistant academic','examination_officer'=>'Examination officer','teacher'=>'Teacher','driver'=>'Driver','hr'=>'HR','storekeeper'=>'Stores'];
?><!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Learning Materials · ShuleLite</title><link rel="stylesheet" href="assets/app.css"><script defer src="assets/app.js"></script></head><body><div class="app-shell">
<?php require __DIR__ . "/sidebar.php"; ?>
<main class="main-area"><header class="topbar"><button class="icon-button menu-toggle" data-menu aria-label="Open navigation" aria-expanded="false">☰</button><div class="crumb">Academics <span>/</span> Learning Materials</div><?php if(in_array($role,['system_admin','sub_admin'],true)):$pendingEditCount=pending_school_edit_request_count();?><a class="notification-bell" href="requests.php#requested" aria-label="<?=$pendingEditCount?> pending edit requests" title="<?=$pendingEditCount?> pending edit requests"><span aria-hidden="true">🔔</span><?php if($pendingEditCount):?><span class="notification-badge"><?=$pendingEditCount>99?'99+':$pendingEditCount?></span><?php endif;?></a><?php endif;?><div class="top-actions"><span class="role-chip"><?=e($roleNames[$role]??'School team')?></span><div class="user-avatar" aria-hidden="true"><?=e(strtoupper(substr($_SESSION['name']??'U',0,1)))?></div><div class="user-name"><?=e($_SESSION['name']??'User')?></div></div></header>
<div class="page-content"><section class="welcome-row"><div><div class="eyebrow">ACADEMICS</div><h1>Learning Materials</h1><p class="muted">Central curriculum resources and class subject notes, together.</p></div><?php if(in_array($role,['system_admin','sub_admin','admin','director','sub_director','headteacher','head_academic','assistant_academic','examination_officer','teacher'],true)):?><a class="button primary" href="ai_questions.php"><span aria-hidden="true">✦</span> AI Questions</a><?php endif;?></section><?php if($error):?><div class="notice error" role="alert"><?=e($error)?></div><?php endif;?><?php if($success):?><div class="notice success" role="status"><?=e($success)?></div><?php endif;?><?php if($loadError):?><div class="notice error" role="alert"><?=e($loadError)?></div><?php endif;?>
<?php if($canCreateCentral||$canCreateTeacher):?><section class="note-create"><div class="section-heading"><div><div class="eyebrow"><?=$canCreateCentral?'CENTRAL CURRICULUM':'YOUR TEACHING'?></div><h2><?=$canCreateCentral?'Add a class level note':'Add a subject note'?></h2></div></div><p class="muted note-intro"><?=$canCreateCentral?'Add curriculum notes for a class and subject.':'Write notes for an assigned subject and class.'?></p><?php if($canCreateTeacher&&!$canCreateCentral&&!$assignments):?><div class="empty-hint">No teaching assignments are linked to your account yet.</div><?php else:?><form method="post" class="note-form"><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><div class="form-grid"><div><label for="note-class">Class</label><input id="note-class" name="class_level" list="note-class-options" required maxlength="80" value="<?=e($_POST['class_level']??'')?>" placeholder="<?=$canCreateCentral?'Search system classes':'Search school classes'?>"><datalist id="note-class-options"><?php foreach($classOptions as $class):?><option value="<?=e($class)?>"><?php endforeach;?></datalist></div><div><label for="note-topic">Topic</label><input id="note-topic" name="topic" maxlength="180" required value="<?=e($_POST['topic']??'')?>" placeholder="For example, Plant needs and growth"></div><div><label for="note-subtopic">Subtopic</label><input id="note-subtopic" name="subtopic" maxlength="180" required value="<?=e($_POST['subtopic']??'')?>" placeholder="For example, Plant growth and needs"></div><div><label for="note-subject">Subject</label><input id="note-subject" name="subject" list="note-subject-options" required maxlength="100" value="<?=e($_POST['subject']??'')?>" placeholder="Search subjects for selected class"><datalist id="note-subject-options"></datalist></div><?php if($canCreateCentral):?><div><label for="note-source">Source</label><input id="note-source" name="source" maxlength="180" value="<?=e($_POST['source']??'')?>" placeholder="TIE reference or curriculum source"></div><?php endif;?></div><div><label for="note-content">Note content</label><textarea id="note-content" name="content" rows="7" required placeholder="Write a clear, useful note for teachers and learners."><?=e($_POST['content']??'')?></textarea></div><button class="button primary" type="submit">Save note <span aria-hidden="true">→</span></button></form><?php endif;?></section><?php endif;?>
<section class="content-section"><div class="section-heading"><div><div class="eyebrow">RESOURCE LIBRARY</div><h2><?=$canManageCentral?'Central class notes':'Available notes'?></h2></div><span class="count-pill"><?=count($notes)?> notes</span></div><?php if(!$notes):?><div class="empty-state"><span class="empty-icon" aria-hidden="true">▤</span><h3>No notes yet</h3><p>Notes will appear here when a central resource or assigned subject note is added.</p></div><?php elseif($canManageCentral):?><?php $notesByClass=[];foreach($notes as $note)$notesByClass[$note['class_level']][]=$note;?><?php foreach($notesByClass as $className=>$classNotes):?><details class="central-class-group" open><summary><span><?=e($className)?></span><span class="count-pill"><?=count($classNotes)?> notes</span></summary><div class="table-wrap central-notes-table-wrap"><table class="central-notes-table"><thead><tr><th>Subject</th><th>Topic</th><th>Subtopic</th><th>Actions</th></tr></thead><tbody><?php foreach($classNotes as $note):?><tr><td><?=e($note['subject'])?></td><td><?=e($note['topic']??'—')?></td><td><?=e($note['subtopic'])?></td><td><div class="central-note-actions"><button class="button" type="button" data-view-central-note data-note="<?=e(json_encode(['id'=>(int)$note['id'],'subtopic'=>$note['subtopic'],'class_level'=>$note['class_level'],'subject'=>$note['subject'],'topic'=>$note['topic']??'','content'=>$note['content'],'source'=>$note['source']??'','author'=>$note['author_name'],'created'=>date('j M Y',strtotime($note['created_at']))],JSON_HEX_APOS|JSON_HEX_QUOT|JSON_HEX_TAG|JSON_HEX_AMP))?>">View</button><button class="button danger-button" type="button" data-delete-central-note data-id="<?=$note['id']?>" data-subtopic="<?=e($note['subtopic'])?>">Delete</button></div></td></tr><?php endforeach;?></tbody></table></div></details><?php endforeach;?><?php else:?><div class="notes-list"><?php foreach($notes as $note):?><article class="note-card"><div class="note-meta"><span class="note-type <?=e($note['note_type'])?>"><?=$note['note_type']==='central'?'TIE central note':'Teacher note'?></span><span><?=e($note['class_level'])?><?= $note['subject']?' · '.e($note['subject']):''?></span></div><h3><?=e($note['subtopic'])?></h3><?php if(!empty($note['topic'])):?><p class="note-source">Topic: <?=e($note['topic'])?></p><?php endif;?><?php if($note['source']):?><p class="note-source">Source: <?=e($note['source'])?></p><?php endif;?><details><summary>Read note</summary><div class="note-body"><?=nl2br(e($note['content']))?></div></details><div class="note-byline">Added by <?=e($note['author_name'])?> · <?=e(date('j M Y',strtotime($note['created_at'])))?></div></article><?php endforeach;?></div><?php endif;?></section>
<script>
const learningClassSubjects=<?=json_encode($classSubjectOptions,JSON_HEX_APOS|JSON_HEX_QUOT|JSON_HEX_TAG|JSON_HEX_AMP)?>;
function refreshLearningSubjects(classInput,subjectInput){const list=document.querySelector('#note-subject-options');if(!list||!subjectInput)return;list.replaceChildren(...[...new Set(learningClassSubjects[(classInput?.value||'').trim()]||[])].map(name=>{const option=document.createElement('option');option.value=name;return option}))}
const centralClassInput=document.querySelector('#note-class'),centralSubjectInput=document.querySelector('#note-subject'),editClassInput=document.querySelector('#edit-note-class'),editSubjectInput=document.querySelector('#edit-note-subject');
[[centralClassInput,centralSubjectInput],[editClassInput,editSubjectInput]].forEach(([classInput,subjectInput])=>{if(!classInput||!subjectInput)return;classInput.addEventListener('input',()=>refreshLearningSubjects(classInput,subjectInput));classInput.addEventListener('change',()=>refreshLearningSubjects(classInput,subjectInput));refreshLearningSubjects(classInput,subjectInput)});
</script><?php if($canManageCentral):?><dialog class="central-note-dialog" id="central-note-dialog"><div class="central-dialog-top"><div><span class="eyebrow" id="central-note-class"></span><h2 id="central-note-heading"></h2></div><button class="icon-button" type="button" data-close-dialog aria-label="Close">×</button></div><div id="central-note-view"><div class="central-note-meta"><span id="central-note-subject"></span><span id="central-note-topic"></span></div><p class="central-note-source" id="central-note-source"></p><div class="central-note-content" id="central-note-content"></div><p class="muted" id="central-note-byline"></p><button class="button primary" type="button" id="edit-central-note">Edit note</button></div><form method="post" class="central-note-edit-form" id="central-note-edit" hidden><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><input type="hidden" name="manage_action" value="update_central"><input type="hidden" name="note_id" id="edit-note-id"><div class="form-grid"><label>Class<input name="class_level" id="edit-note-class" list="note-class-options" required maxlength="80"></label><label>Topic<input name="topic" id="edit-note-topic" required maxlength="180"></label><label>Subtopic<input name="subtopic" id="edit-note-subtopic" required maxlength="180"></label><label>Subject<input name="subject" id="edit-note-subject" list="note-subject-options" required maxlength="100"></label><label>Source<input name="source" id="edit-note-source" maxlength="180"></label></div><label>Notes<textarea name="content" id="edit-note-content" rows="9" required></textarea></label><div class="dialog-actions"><button class="button" type="button" id="cancel-note-edit">Cancel</button><button class="button primary" type="submit">Save changes</button></div></form></dialog><dialog class="central-delete-dialog" id="central-delete-dialog"><form method="post" class="delete-confirm-card"><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><input type="hidden" name="manage_action" value="delete_central"><input type="hidden" name="note_id" id="delete-note-id"><span class="delete-confirm-icon" aria-hidden="true">!</span><h2>Delete this note?</h2><p>You’re about to remove <strong id="delete-note-subtopic"></strong> from central learning materials. This can’t be undone.</p><div class="dialog-actions"><button class="button" type="button" data-close-delete>Keep note</button><button class="button danger-button" type="submit">Delete note</button></div></form></dialog><?php endif;?><footer class="page-footer">ShuleLite <span>·</span> Learning resources</footer></div></main></div><?php if($canManageCentral):?><script>
(()=>{const viewDialog=document.querySelector('#central-note-dialog'),deleteDialog=document.querySelector('#central-delete-dialog'),view=document.querySelector('#central-note-view'),edit=document.querySelector('#central-note-edit');let activeNote=null;const put=(id,value)=>{document.getElementById(id).textContent=value||''};document.querySelectorAll('[data-view-central-note]').forEach(button=>button.addEventListener('click',()=>{activeNote=JSON.parse(button.dataset.note);put('central-note-class',activeNote.class_level);put('central-note-heading',activeNote.subtopic);put('central-note-subject',activeNote.subject);put('central-note-topic',activeNote.topic?'Topic: '+activeNote.topic:'');put('central-note-source',activeNote.source?'Source: '+activeNote.source:'');put('central-note-content',activeNote.content);put('central-note-byline','Added by '+activeNote.author+' · '+activeNote.created);view.hidden=false;edit.hidden=true;viewDialog.showModal()}));document.querySelector('#edit-central-note')?.addEventListener('click',()=>{if(!activeNote)return;for(const [id,key] of [['edit-note-id','id'],['edit-note-class','class_level'],['edit-note-subject','subject'],['edit-note-topic','topic'],['edit-note-subtopic','subtopic'],['edit-note-source','source'],['edit-note-content','content']])document.getElementById(id).value=activeNote[key]||'';editClassInput?.dispatchEvent(new Event('input'));view.hidden=true;edit.hidden=false});document.querySelector('#cancel-note-edit')?.addEventListener('click',()=>{edit.hidden=true;view.hidden=false});document.querySelectorAll('[data-close-dialog]').forEach(b=>b.addEventListener('click',()=>viewDialog.close()));viewDialog?.addEventListener('click',e=>{if(e.target===viewDialog)viewDialog.close()});document.querySelectorAll('[data-delete-central-note]').forEach(button=>button.addEventListener('click',()=>{document.querySelector('#delete-note-id').value=button.dataset.id;put('delete-note-subtopic',button.dataset.subtopic);deleteDialog.showModal()}));document.querySelector('[data-close-delete]')?.addEventListener('click',()=>deleteDialog.close());deleteDialog?.addEventListener('click',e=>{if(e.target===deleteDialog)deleteDialog.close()});})();
</script><?php endif;?></body></html>
