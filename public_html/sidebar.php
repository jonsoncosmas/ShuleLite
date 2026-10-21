<?php
declare(strict_types=1);

$sidebarRole = (string)($_SESSION['role'] ?? '');
$sidebarUserId = (int)($_SESSION['user_id'] ?? 0);
$sidebarPage = basename((string)($_SERVER['PHP_SELF'] ?? ''));
$sidebarSystemRoles = ['system_admin', 'sub_admin'];
$sidebarResultRoles = ['system_admin','sub_admin','admin','director','sub_director','headteacher','head_academic','assistant_academic','examination_officer','teacher'];
$sidebarItems = [
    ['href'=>'index.php','label'=>'Overview','icon'=>'⌂','active'=>['index.php'],'show'=>true],
    ['href'=>'schools.php','label'=>'Schools','icon'=>'▦','active'=>['schools.php','school_analyze.php'],'show'=>!in_array($sidebarRole,['headteacher','teacher'],true)],
    ['href'=>'team.php','label'=>'Team','icon'=>'♧','active'=>['team.php'],'show'=>$sidebarRole!=='teacher'],
    ['href'=>'audit.php','label'=>'Audit log','icon'=>'◷','active'=>['audit.php'],'show'=>in_array($sidebarRole,$sidebarSystemRoles,true)],
    ['href'=>'accounting.php','label'=>'Accounting','icon'=>'▤','active'=>['accounting.php'],'show'=>in_array($sidebarRole,$sidebarSystemRoles,true)],
    ['href'=>'academics.php','label'=>'Academics','icon'=>'▤','active'=>in_array($sidebarRole,$sidebarSystemRoles,true)?['academics.php']:[],'show'=>in_array($sidebarRole,$sidebarSystemRoles,true)],
    ['href'=>'school_setup.php','label'=>'School setup','icon'=>'⚙','active'=>['school_setup.php'],'show'=>!in_array($sidebarRole,$sidebarSystemRoles,true)&&can_access_school_setup($sidebarUserId,$sidebarRole)],
    ['href'=>'subscriptions.php','label'=>'Subscriptions','icon'=>'◷','active'=>['subscriptions.php'],'show'=>in_array($sidebarRole,['system_admin','sub_admin','director'],true)],
    ['href'=>'subscriptions.php#income','label'=>'Income analysis','icon'=>'▤','active'=>[],'show'=>$sidebarRole==='system_admin','subitem'=>true],
    ['href'=>'requests.php','label'=>'Requests','icon'=>'✉','active'=>['requests.php','school_edit_review.php'],'show'=>in_array($sidebarRole,$sidebarSystemRoles,true),'badge'=>true],
    ['href'=>'results.php','label'=>'Results','icon'=>'▧','active'=>['results.php'],'show'=>in_array($sidebarRole,$sidebarResultRoles,true)],
    ['href'=>'notes.php','label'=>'Learning Materials','icon'=>'▧','active'=>['notes.php','ai_questions.php'],'show'=>true],
];
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
