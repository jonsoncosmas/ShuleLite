<?php
declare(strict_types=1);
session_start();
require dirname(__DIR__) . '/config/config.php';
require_sign_in();
$role = $_SESSION['role']; $userId = (int)$_SESSION['user_id'];
$canCreateCentral = $role === 'system_admin';
$canCreateTeacher = in_array($role, ['teacher','head_academic','assistant_academic','examination_officer'], true);
$error = ''; $success = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $type = $canCreateCentral ? 'central' : 'teacher';
    $title = trim((string)($_POST['title'] ?? ''));
    $classLevel = trim((string)($_POST['class_level'] ?? ''));
    $subject = trim((string)($_POST['subject'] ?? ''));
    $content = trim((string)($_POST['content'] ?? ''));
    $source = trim((string)($_POST['source'] ?? ''));
    if (!$canCreateCentral && !$canCreateTeacher) { http_response_code(403); exit('You do not have permission to create notes.'); }
    if ($title === '' || $classLevel === '' || $content === '' || ($type === 'teacher' && $subject === '')) {
        $error = 'Add a title, class level, note content, and subject for a teacher note.';
    } elseif (mb_strlen($title) > 180 || mb_strlen($classLevel) > 80 || mb_strlen($subject) > 100 || mb_strlen($source) > 180) {
        $error = 'One or more fields are too long. Shorten the highlighted details and try again.';
    } else {
        try {
            $schoolId = null;
            if ($type === 'teacher') {
                $assignment = db()->prepare('SELECT school_id FROM teacher_assignments WHERE user_id = ? AND class_level = ? AND subject = ? AND active = 1 LIMIT 1');
                $assignment->execute([$userId, $classLevel, $subject]); $assignment = $assignment->fetch();
                if (!$assignment) { $error = 'You are not assigned to that subject and class. Ask your school academic lead to assign it first.'; }
                else $schoolId = (int)$assignment['school_id'];
            }
            if ($error === '') {
                $pdo = db(); $pdo->beginTransaction();
                $insert = $pdo->prepare('INSERT INTO learning_notes (note_type,title,class_level,subject,content,source,author_id,school_id) VALUES (?,?,?,?,?,?,?,?)');
                $insert->execute([$type,$title,$classLevel,$type === 'central' ? null : $subject,$content,$source ?: null,$userId,$schoolId]);
                $audit = $pdo->prepare('INSERT INTO audit_logs (actor_id,action,entity_type,entity_id,details) VALUES (?,?,?,?,?)');
                $audit->execute([$userId,'create','learning_note',(int)$pdo->lastInsertId(),json_encode(['note_type'=>$type,'class_level'=>$classLevel,'subject'=>$subject ?: null], JSON_THROW_ON_ERROR)]);
                $pdo->commit(); header('Location: notes.php?saved=1'); exit;
            }
        } catch (Throwable $exception) {
            if (isset($pdo) && $pdo->inTransaction()) $pdo->rollBack();
            $error = 'We could not save this note. Check the database setup and try again.';
        }
    }
}
if (isset($_GET['saved'])) $success = 'Your note has been saved.';
$assignments = []; $notes = []; $loadError = '';
try {
    if ($canCreateTeacher) { $q = db()->prepare('SELECT school_id,class_level,subject FROM teacher_assignments WHERE user_id = ? AND active = 1 ORDER BY class_level,subject'); $q->execute([$userId]); $assignments = $q->fetchAll(); }
    if ($role === 'system_admin') {
        $notes = db()->query("SELECT n.*,u.name author_name FROM learning_notes n JOIN users u ON u.id=n.author_id WHERE n.note_type='central' ORDER BY n.updated_at DESC LIMIT 100")->fetchAll();
    } elseif ($canCreateTeacher) {
        $q = db()->prepare("SELECT n.*,u.name author_name FROM learning_notes n JOIN users u ON u.id=n.author_id WHERE n.note_type='central' OR (n.note_type='teacher' AND n.author_id=?) ORDER BY n.updated_at DESC LIMIT 100"); $q->execute([$userId]); $notes = $q->fetchAll();
    } else {
        $notes = db()->query("SELECT n.*,u.name author_name FROM learning_notes n JOIN users u ON u.id=n.author_id WHERE n.note_type='central' ORDER BY n.updated_at DESC LIMIT 100")->fetchAll();
    }
} catch (PDOException $exception) { $loadError = 'Notes are not available yet. Apply the latest database schema and reload this page.'; }
$roleNames = ['system_admin'=>'System admin','sub_admin'=>'Sub admin','admin'=>'Admin','director'=>'Director','sub_director'=>'School manager','headteacher'=>'Head of school','head_academic'=>'Head of academics','assistant_academic'=>'Assistant academic','examination_officer'=>'Examination officer','teacher'=>'Teacher','driver'=>'Driver','hr'=>'HR','storekeeper'=>'Stores'];
?><!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Learning notes · ShuleLite</title><link rel="stylesheet" href="assets/app.css"><script defer src="assets/app.js"></script></head><body><div class="app-shell"><aside class="sidebar" id="sidebar"><a class="brand" href="index.php"><span class="brand-mark">S</span><span>shule<span class="brand-lite">lite</span></span></a><div class="workspace-label">WORKSPACE</div><nav class="side-nav" aria-label="Main navigation"><a class="nav-item" href="index.php"><span class="nav-icon" aria-hidden="true">⌂</span>Overview</a><a class="nav-item active" href="notes.php" aria-current="page"><span class="nav-icon" aria-hidden="true">▤</span>Learning notes</a><?php if(in_array($_SESSION['role']??'', ['system_admin','sub_admin'],true)):?><a class="nav-item" href="requests.php">✉ &nbsp;Requests<?php $requestBadgeCount=pending_school_edit_request_count();if($requestBadgeCount):?><span class="side-nav-count"><?=$requestBadgeCount>99?'99+':$requestBadgeCount?></span><?php endif;?></a><?php endif;?><?php if(in_array($_SESSION['role']??'', ['system_admin','sub_admin','director'],true)):?><a class="nav-item" href="subscriptions.php">◷ &nbsp;Subscriptions</a><?php endif;?></nav><div class="sidebar-bottom"><a class="nav-item" href="logout.php"><span class="nav-icon" aria-hidden="true">↪</span>Sign out</a></div></aside><main class="main-area"><header class="topbar"><button class="icon-button menu-toggle" data-menu aria-label="Open navigation" aria-expanded="false">☰</button><div class="crumb">Academics <span>/</span> Learning notes</div><?php if(in_array($_SESSION['role']??'', ['system_admin','sub_admin'],true)):$pendingEditCount=pending_school_edit_request_count();?><a class="notification-bell" href="requests.php#requested" aria-label="<?=$pendingEditCount?> pending edit requests" title="<?=$pendingEditCount?> pending edit requests"><span aria-hidden="true">🔔</span><?php if($pendingEditCount):?><span class="notification-badge"><?=$pendingEditCount>99?'99+':$pendingEditCount?></span><?php endif;?></a><?php endif;?><div class="top-actions"><span class="role-chip"><?=e($roleNames[$role] ?? 'School team')?></span><div class="user-avatar" aria-hidden="true"><?=e(strtoupper(substr($_SESSION['name'] ?? 'U',0,1)))?></div><div class="user-name"><?=e($_SESSION['name'] ?? 'User')?></div></div></header><div class="page-content"><section class="welcome-row"><div><div class="eyebrow">ACADEMICS</div><h1>Learning notes</h1><p class="muted">Central curriculum resources and class subject notes, together.</p></div></section><?php if($error):?><div class="notice error" role="alert"><?=e($error)?></div><?php endif;?><?php if($success):?><div class="notice success" role="status"><?=e($success)?></div><?php endif;?><?php if($loadError):?><div class="notice error" role="alert"><?=e($loadError)?></div><?php endif;?>
<?php if($canCreateCentral || $canCreateTeacher):?><section class="note-create"><div class="section-heading"><div><div class="eyebrow"><?= $canCreateCentral ? 'CENTRAL CURRICULUM' : 'YOUR TEACHING' ?></div><h2><?= $canCreateCentral ? 'Add a class level note' : 'Add a subject note' ?></h2></div></div><p class="muted note-intro"><?= $canCreateCentral ? 'Add TIE reference notes for a class level. Teachers can use these central resources across schools.' : 'Write notes for an assigned subject and class. Your academic lead manages your teaching assignments.' ?></p><?php if($canCreateTeacher && !$canCreateCentral && !$assignments):?><div class="empty-hint">No teaching assignments are linked to your account yet.</div><?php else:?><form method="post" class="note-form"><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><div class="form-grid"><div><label for="note-title">Note title</label><input id="note-title" name="title" maxlength="180" required value="<?=e($_POST['title']??'')?>" placeholder="For example, Plant growth and needs"></div><div><label for="note-class">Class level</label><?php if($canCreateTeacher && !$canCreateCentral):?><select id="note-class" name="class_level" required><option value="">Choose assigned class</option><?php foreach(array_unique(array_column($assignments,'class_level')) as $class):?><option value="<?=e($class)?>" <?=($_POST['class_level']??'')===$class?'selected':''?>><?=e($class)?></option><?php endforeach;?></select><?php else:?><input id="note-class" name="class_level" required maxlength="80" value="<?=e($_POST['class_level']??'')?>" placeholder="For example, Grade 4"><?php endif;?></div><?php if(!$canCreateCentral):?><div><label for="note-subject">Subject</label><select id="note-subject" name="subject" required><option value="">Choose subject</option><?php foreach(array_values(array_unique(array_column($assignments,'subject'))) as $subject):?><option value="<?=e($subject)?>" <?=($_POST['subject']??'')===$subject?'selected':''?>><?=e($subject)?></option><?php endforeach;?></select></div><?php else:?><div><label for="note-source">Source</label><input id="note-source" name="source" maxlength="180" value="<?=e($_POST['source']??'')?>" placeholder="TIE reference or curriculum source"></div><?php endif;?></div><div><label for="note-content">Note content</label><textarea id="note-content" name="content" rows="7" required placeholder="Write a clear, useful note for teachers and learners."><?=e($_POST['content']??'')?></textarea></div><button class="button primary" type="submit">Save note <span aria-hidden="true">→</span></button></form><?php endif;?></section><?php endif;?>
<section class="content-section"><div class="section-heading"><div><div class="eyebrow">RESOURCE LIBRARY</div><h2><?= $role==='system_admin' ? 'Central class notes' : 'Available notes' ?></h2></div><span class="count-pill"><?=count($notes)?> notes</span></div><?php if(!$notes):?><div class="empty-state"><span class="empty-icon" aria-hidden="true">▤</span><h3>No notes yet</h3><p>Notes will appear here when a central resource or assigned subject note is added.</p></div><?php else:?><div class="notes-list"><?php foreach($notes as $note):?><article class="note-card"><div class="note-meta"><span class="note-type <?=e($note['note_type'])?>"><?= $note['note_type']==='central'?'TIE central note':'Teacher note' ?></span><span><?=e($note['class_level'])?><?= $note['subject'] ? ' · '.e($note['subject']) : ''?></span></div><h3><?=e($note['title'])?></h3><?php if($note['source']):?><p class="note-source">Source: <?=e($note['source'])?></p><?php endif;?><details><summary>Read note</summary><div class="note-body"><?=nl2br(e($note['content']))?></div></details><div class="note-byline">Added by <?=e($note['author_name'])?> · <?=e(date('j M Y',strtotime($note['created_at'])))?></div></article><?php endforeach;?></div><?php endif;?></section><footer class="page-footer">ShuleLite <span>·</span> Learning resources</footer></div></main></div></body></html>
