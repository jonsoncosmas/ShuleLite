<?php
declare(strict_types=1);

$sidebarRole = (string)($_SESSION['role'] ?? '');
$sidebarUserId = (int)($_SESSION['user_id'] ?? 0);
$sidebarPage = basename((string)($_SERVER['PHP_SELF'] ?? ''));
$sidebarSystemRoles = ['system_admin', 'sub_admin'];
$sidebarResultRoles = ['system_admin','sub_admin','admin','director','sub_director','headteacher','head_academic','assistant_academic','examination_officer','teacher'];
if($sidebarRole==='parent'){$sidebarItems=[['href'=>'parent_portal.php','label'=>'My children','icon'=>'♙','active'=>['parent_portal.php'],'show'=>true],['href'=>'messages.php','label'=>'Messages','icon'=>'✉','active'=>['messages.php'],'show'=>true],['href'=>'timetable.php','label'=>'Timetable','icon'=>'◷','active'=>['timetable.php'],'show'=>true],['href'=>'portal_announcements.php','label'=>'Announcements','icon'=>'✉','active'=>['portal_announcements.php'],'show'=>true]];}elseif($sidebarRole==='pupil'){$sidebarItems=[['href'=>'pupil_portal.php','label'=>'My learning','icon'=>'▧','active'=>['pupil_portal.php'],'show'=>true],['href'=>'homework_portal.php','label'=>'Homework','icon'=>'✎','active'=>['homework_portal.php'],'show'=>true],['href'=>'timetable.php','label'=>'Timetable','icon'=>'◷','active'=>['timetable.php'],'show'=>true],['href'=>'portal_announcements.php','label'=>'Announcements','icon'=>'✉','active'=>['portal_announcements.php'],'show'=>true]];}else{$sidebarItems = [
    ['href'=>'index.php','label'=>'Overview','icon'=>'⌂','active'=>['index.php'],'show'=>true],
    ['href'=>'schools.php','label'=>'Schools','icon'=>'▦','active'=>['schools.php','school_analyze.php'],'show'=>!in_array($sidebarRole,['headteacher','teacher','bursar','department_head'],true)],
    ['href'=>'team.php','label'=>'Team','icon'=>'♧','active'=>['team.php'],'show'=>!in_array($sidebarRole,['teacher','bursar','department_head'],true)],
    ['href'=>'audit.php','label'=>'Audit log','icon'=>'◷','active'=>['audit.php'],'show'=>in_array($sidebarRole,$sidebarSystemRoles,true)],
    ['href'=>'accounting.php','label'=>'Accounting','icon'=>'▤','active'=>['accounting.php'],'show'=>in_array($sidebarRole,['system_admin','sub_admin','admin','director','sub_director','headteacher','bursar'],true)],
    ['href'=>'fee_structures.php','label'=>'Fee structures','icon'=>'▧','active'=>['fee_structures.php'],'show'=>in_array($sidebarRole,['admin','director','sub_director','headteacher','bursar'],true)],
    ['href'=>'announcements.php','label'=>'Announcements','icon'=>'✉','active'=>['announcements.php'],'show'=>in_array($sidebarRole,['admin','director','sub_director','headteacher','head_academic'],true)],
    ['href'=>'notification_settings.php','label'=>'SMS templates','icon'=>'✉','active'=>['notification_settings.php'],'show'=>in_array($sidebarRole,['admin','director','sub_director','headteacher'],true)],
    ['href'=>'portal_announcements.php','label'=>'Notice board','icon'=>'▤','active'=>['portal_announcements.php'],'show'=>in_array($sidebarRole,['admin','director','sub_director','headteacher','head_academic','department_head','assistant_academic','examination_officer','teacher','hr','storekeeper','bursar','driver'],true)],
    ['href'=>'messages.php','label'=>'Parent messages','icon'=>'✉','active'=>['messages.php'],'show'=>$sidebarRole==='teacher'],
    ['href'=>'academics.php','label'=>'Academics','icon'=>'▤','active'=>in_array($sidebarRole,$sidebarSystemRoles,true)?['academics.php']:[],'show'=>in_array($sidebarRole,$sidebarSystemRoles,true)],
    ['href'=>'school_setup.php','label'=>'School setup','icon'=>'⚙','active'=>['school_setup.php'],'show'=>!in_array($sidebarRole,$sidebarSystemRoles,true)&&can_access_school_setup($sidebarUserId,$sidebarRole)],
    ['href'=>'subscriptions.php','label'=>'Subscriptions','icon'=>'◷','active'=>['subscriptions.php'],'show'=>in_array($sidebarRole,['system_admin','sub_admin','director'],true)],
    ['href'=>'subscriptions.php#income','label'=>'Income analysis','icon'=>'▤','active'=>[],'show'=>$sidebarRole==='system_admin','subitem'=>true],
    ['href'=>'requests.php','label'=>'Requests','icon'=>'✉','active'=>['requests.php','school_edit_review.php'],'show'=>in_array($sidebarRole,$sidebarSystemRoles,true),'badge'=>true],
    ['href'=>'results.php','label'=>'Results','icon'=>'▧','active'=>['results.php'],'show'=>in_array($sidebarRole,$sidebarResultRoles,true)],
    ['href'=>'academic_reports.php','label'=>'Academic reports','icon'=>'▤','active'=>['academic_reports.php'],'show'=>in_array($sidebarRole,['admin','director','sub_director','headteacher','head_academic','assistant_academic','examination_officer','teacher'],true)],
    ['href'=>'grading_scales.php','label'=>'Grading scales','icon'=>'▧','active'=>['grading_scales.php'],'show'=>in_array($sidebarRole,['director','sub_director','headteacher','head_academic','assistant_academic','examination_officer','teacher'],true)],
    ['href'=>'pupils.php','label'=>'Pupils','icon'=>'♙','active'=>['pupils.php'],'show'=>in_array($sidebarRole,['admin','director','sub_director','headteacher','head_academic','assistant_academic','teacher'],true)],
    ['href'=>'operations.php','label'=>'Operations','icon'=>'◫','active'=>['operations.php'],'show'=>in_array($sidebarRole,['admin','director','sub_director','headteacher','head_academic','assistant_academic','examination_officer','teacher','hr','storekeeper','bursar','driver'],true)],
    ['href'=>'staff_profiles.php','label'=>'Staff profiles','icon'=>'♧','active'=>['staff_profiles.php'],'show'=>in_array($sidebarRole,['hr','director','sub_director','headteacher'],true)],
    ['href'=>'staff_workload.php','label'=>'Staff workload','icon'=>'W','active'=>['staff_workload.php'],'show'=>in_array($sidebarRole,['hr','admin','director','sub_director','headteacher'],true)],
    ['href'=>'staff_attendance.php','label'=>'Staff attendance','icon'=>'T','active'=>['staff_attendance.php'],'show'=>in_array($sidebarRole,['admin','director','sub_director','headteacher','head_academic','department_head','assistant_academic','examination_officer','teacher','hr','storekeeper','bursar','driver'],true)],
    ['href'=>'planning.php','label'=>'Teaching plans','icon'=>'▤','active'=>['planning.php'],'show'=>in_array($sidebarRole,['director','sub_director','headteacher','head_academic','department_head','assistant_academic','teacher'],true)],
    ['href'=>'homework.php','label'=>'Homework','icon'=>'✎','active'=>['homework.php'],'show'=>in_array($sidebarRole,['teacher','head_academic','headteacher','sub_director','director'],true)],
    ['href'=>'timetable.php','label'=>'Timetable','icon'=>'◷','active'=>['timetable.php'],'show'=>in_array($sidebarRole,['teacher','director','sub_director','headteacher','head_academic'],true)],
    ['href'=>'departments.php','label'=>'Academic departments','icon'=>'▥','active'=>['departments.php'],'show'=>in_array($sidebarRole,['admin','director','sub_director','headteacher','department_head'],true)],
    ['href'=>'holiday_packages.php','label'=>'Holiday learning','icon'=>'☼','active'=>['holiday_packages.php'],'show'=>in_array($sidebarRole,['teacher','assistant_academic','head_academic','examination_officer','headteacher','sub_director','director'],true)],
    ['href'=>'question_bank.php','label'=>'Question bank','icon'=>'▨','active'=>['question_bank.php'],'show'=>in_array($sidebarRole,['teacher','assistant_academic','head_academic','examination_officer','headteacher','sub_director','director'],true)],
    ['href'=>'exams.php','label'=>'Examinations','icon'=>'▧','active'=>['exams.php'],'show'=>in_array($sidebarRole,['teacher','assistant_academic','head_academic','examination_officer','headteacher','sub_director','director'],true)],
    ['href'=>'notes.php','label'=>'Learning Materials','icon'=>'▧','active'=>['notes.php','ai_questions.php'],'show'=>!in_array($sidebarRole,['bursar'],true)],
];}
?>
<aside class="sidebar" id="sidebar">
    <a class="brand" href="index.php"><span class="brand-mark">S</span><span>shule<span class="brand-lite">lite</span></span></a>
    <div class="workspace-label">WORKSPACE</div>
    <nav class="side-nav" aria-label="Main navigation">
        <?php foreach ($sidebarItems as $item): if (!$item['show']) continue; $active=in_array($sidebarPage,$item['active'],true); if($sidebarPage==='school_edit_review.php'&&$sidebarRole==='admin'&&$item['href']==='schools.php')$active=true; ?>
            <a class="nav-item<?=!empty($item['subitem'])?' nav-subitem':''?><?=$active?' active':''?>" href="<?=e($item['href'])?>"<?=$active?' aria-current="page"':''?> title="<?=e($item['label'])?>">
                <span class="nav-icon" aria-hidden="true"><?=e($item['icon'])?></span><span class="nav-label"><?=e($item['label'])?></span>
                <?php if(!empty($item['badge'])){$count=pending_school_edit_request_count();if($count):?><span class="side-nav-count"><?=$count>99?'99+':$count?></span><?php endif;}?>
            </a>
        <?php endforeach; ?>
    </nav>
    <div class="sidebar-bottom">
        <a class="nav-item<?=$sidebarPage==='profile.php'?' active':''?>" href="profile.php" title="My account"<?=$sidebarPage==='profile.php'?' aria-current="page"':''?>><span class="nav-icon" aria-hidden="true">◉</span><span class="nav-label">My account</span></a>
        <a class="nav-item" href="logout.php" title="Sign out"><span class="nav-icon" aria-hidden="true">↪</span><span class="nav-label">Sign out</span></a>
    </div>
</aside>
