<?php
declare(strict_types=1);
session_start();
require dirname(__DIR__).'/config/config.php';
require_sign_in();
if(!in_array($_SESSION['role'],['system_admin','sub_admin'],true)){http_response_code(403);exit('Audit logs are available to System Admins and Sub System Admins.');}
$page=max(1,(int)($_GET['page']??1));
$allowedPageSizes=[10,50,100,200];
$perPage=(int)($_GET['per_page']??10);
if(!in_array($perPage,$allowedPageSizes,true))$perPage=10;
$search=trim((string)($_GET['search']??''));
$action=trim((string)($_GET['action']??''));
$entity=trim((string)($_GET['entity']??''));
$actor=trim((string)($_GET['actor']??''));
$where=[];$params=[];
if($search!==''){$where[]="(l.action LIKE ? OR l.entity_type LIKE ? OR CAST(l.entity_id AS CHAR) LIKE ? OR l.details LIKE ? OR u.name LIKE ? OR u.email LIKE ? OR u.username LIKE ?)";$term='%'.$search.'%';array_push($params,$term,$term,$term,$term,$term,$term,$term);}
if($action!==''){$where[]='l.action=?';$params[]=$action;}
if($entity!==''){$where[]='l.entity_type=?';$params[]=$entity;}
if($actor!==''){$where[]='(u.name LIKE ? OR u.email LIKE ? OR u.username LIKE ?)';array_push($params,"%$actor%","%$actor%","%$actor%");}
$clause=$where?'WHERE '.implode(' AND ',$where):'';$db=db();
$count=$db->prepare("SELECT COUNT(*) FROM audit_logs l LEFT JOIN users u ON u.id=l.actor_id $clause");$count->execute($params);$total=(int)$count->fetchColumn();
$pages=max(1,(int)ceil($total/$perPage));$page=min($page,$pages);$offset=($page-1)*$perPage;
$q=$db->prepare("SELECT l.id,l.action,l.entity_type,l.entity_id,l.details,l.created_at,u.name actor_name,u.email,u.username FROM audit_logs l LEFT JOIN users u ON u.id=l.actor_id $clause ORDER BY l.created_at DESC,l.id DESC LIMIT $perPage OFFSET $offset");$q->execute($params);$logs=$q->fetchAll();
if(($_GET['async']??'')==='1'){
 header('Content-Type: application/json; charset=utf-8');
 echo json_encode(['logs'=>$logs,'total'=>$total,'page'=>$page,'pages'=>$pages,'per_page'=>$perPage],JSON_THROW_ON_ERROR);exit;
}
?><!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Audit log · ShuleLite</title>
<link rel="stylesheet" href="assets/app.css">
<script defer src="assets/app.js"></script>
</head>
<body>
<div class="app-shell">
<?php require __DIR__ . "/sidebar.php"; ?>
<main class="main-area">
<header class="topbar"><button class="icon-button menu-toggle" data-menu aria-label="Open navigation" aria-expanded="false">☰</button><div class="crumb">System <span>/</span> Audit log</div><?php if(in_array($_SESSION['role']??'', ['system_admin','sub_admin'],true)):$pendingEditCount=pending_school_edit_request_count();?><a class="notification-bell" href="requests.php#requested" aria-label="<?=$pendingEditCount?> pending edit requests" title="<?=$pendingEditCount?> pending edit requests"><span aria-hidden="true">🔔</span><?php if($pendingEditCount):?><span class="notification-badge"><?=$pendingEditCount>99?'99+':$pendingEditCount?></span><?php endif;?></a><?php endif;?><div class="top-actions"><span class="role-chip"><?=e(str_replace('_',' ',$_SESSION['role']))?></span><div class="user-name"><?=e($_SESSION['name'])?></div></div></header>
<div class="page-content audit-content">
<section class="audit-heading"><div><div class="eyebrow">SYSTEM OVERSIGHT</div><h1>Audit log</h1><p class="muted">Track changes across accounts, schools and learning records.</p></div><div class="audit-live"><span class="audit-live-dot" aria-hidden="true"></span>Activity history</div></section>
<section class="audit-hero" aria-label="Audit activity overview"><div class="audit-hero-copy"><span class="audit-hero-kicker">ACCOUNTABILITY, AT A GLANCE</span><h2>Every change leaves a trail.</h2><p>Review who made a change, what it affected and when it happened.</p></div><div class="audit-hero-stat"><span>Matching events</span><strong><?=number_format($total)?></strong><small><?=count($logs)?> shown on this page</small></div><span class="audit-hero-mark" aria-hidden="true">↗</span></section>
<section class="audit-stats" aria-label="Current log summary"><article class="audit-stat"><span class="audit-stat-icon" aria-hidden="true">⌕</span><div><span class="audit-stat-label">FILTERS ACTIVE</span><strong><?=count(array_filter([$search,$actor,$action,$entity],fn($v)=>$v!==''))?></strong><small>Search criteria applied</small></div></article><article class="audit-stat"><span class="audit-stat-icon" aria-hidden="true">▤</span><div><span class="audit-stat-label">EVENTS PER PAGE</span><strong><?=count($logs)?></strong><small>Up to <?=$perPage?> recent events</small></div></article><article class="audit-stat"><span class="audit-stat-icon warm" aria-hidden="true">◷</span><div><span class="audit-stat-label">CURRENT PAGE</span><strong><?=$page?> <span class="audit-page-of">/ <?=max(1,(int)ceil($total/$perPage))?></span></strong><small>Newest activity appears first</small></div></article></section>
<section class="content-section audit-activity"><div class="section-heading"><div><div class="eyebrow">RECENT ACTIVITY</div><h2>Activity stream</h2><p class="muted audit-section-description">A chronological record of actions in your system.</p></div><span class="count-pill" id="audit-total"><?=number_format($total)?> total events</span></div>
<section class="audit-filter-panel"><div class="audit-filter-heading"><div><span class="eyebrow">NARROW THE ACTIVITY</span><h2>Find a specific change</h2></div><button class="audit-clear" type="button" data-clear-filters>Clear filters <span aria-hidden="true">↗</span></button></div><form method="get" class="audit-filter-form" id="audit-filters"><div><label for="search">Search all activity</label><input id="search" name="search" value="<?=e($search)?>" placeholder="Search people, actions, records, details" autocomplete="off"></div><div><label for="actor">Changed by</label><input id="actor" name="actor" value="<?=e($actor)?>" placeholder="Name, email or username" autocomplete="off"></div><div><label for="action">Action</label><select id="action" name="action"><option value="">All actions</option><?php foreach(['create','update','assign_role','reset_password','suspend','reactivate','activate_role','deactivate_role','delete'] as $option):?><option value="<?=$option?>" <?=$action===$option?'selected':''?>><?=e(ucfirst(str_replace('_',' ',$option)))?></option><?php endforeach;?></select></div><div><label for="entity">Record type</label><select id="entity" name="entity"><option value="">All record types</option><?php foreach(['user','school','pupil','pupil_result','teacher_assignment','learning_note','school_class_registry','school_class','school_stream','school_subject'] as $option):?><option value="<?=$option?>" <?=$entity===$option?'selected':''?>><?=e(ucfirst(str_replace('_',' ',$option)))?></option><?php endforeach;?></select></div><div><label for="per-page">Rows per page</label><select id="per-page" name="per_page"><option value="10" <?=$perPage===10?'selected':''?>>10</option><option value="50" <?=$perPage===50?'selected':''?>>50</option><option value="100" <?=$perPage===100?'selected':''?>>100</option><option value="200" <?=$perPage===200?'selected':''?>>200</option></select></div></form><p class="muted" id="audit-filter-status" role="status" aria-live="polite">Filters update the activity stream automatically.</p></section>
<div class="empty-state audit-empty-state" <?=$logs?'hidden':''?>><span class="empty-icon" aria-hidden="true">◷</span><h3>No matching events</h3><p>Try a different search or clear filters to see more activity.</p><a class="button" href="audit.php">Clear filters</a></div>
<div class="table-wrap audit-table-wrap" <?=$logs?'':'hidden'?>><table class="audit-table"><thead><tr><th scope="col">Date and time</th><th scope="col">Changed by</th><th scope="col">Action</th><th scope="col">Affected record</th><th scope="col">Details</th></tr></thead><tbody><?php foreach($logs as $log):?><tr><td><time class="audit-time" datetime="<?=e($log['created_at'])?>"><strong><?=e(date('j M Y',strtotime($log['created_at'])))?></strong><span><?=e(date('H:i',strtotime($log['created_at'])))?></span></time></td><td><div class="audit-actor"><span class="audit-actor-avatar" aria-hidden="true"><?=e(strtoupper(substr($log['actor_name']?:'?',0,1)))?></span><span><strong><?=e($log['actor_name']?:'Deleted account')?></strong><small><?=e($log['email']?:($log['username']??'No sign-in ID'))?></small></span></div></td><td><span class="audit-action"><?=e(ucfirst(str_replace('_',' ',$log['action'])))?></span></td><td><span class="audit-record-type"><?=e(str_replace('_',' ',$log['entity_type']))?></span><strong class="audit-record-id">#<?=e((string)($log['entity_id']??'—'))?></strong></td><td><?php if($log['details']):?><details class="audit-details"><summary>View details</summary><p><?=e($log['details'])?></p></details><?php else:?><span class="audit-no-details">No additional details</span><?php endif;?></td></tr><?php endforeach;?></tbody></table></div>
<nav class="pagination audit-pagination" id="audit-pagination" aria-label="Audit log pages" <?=$pages<=1?'hidden':''?> data-page="<?=$page?>" data-pages="<?=$pages?>" data-per-page="<?=$perPage?>"><button class="button" type="button" data-page-step="-1" <?=$page<=1?'disabled':''?>>← Previous</button><span>Page <strong data-current-page><?=$page?></strong> of <span data-total-pages><?=$pages?></span></span><button class="button" type="button" data-page-step="1" <?=$page>=$pages?'disabled':''?>>Next →</button></nav></section>
<footer class="audit-footer">ShuleLite <span>·</span> Secure activity history</footer>
</div></main></div>
<script>
(()=>{
 const form=document.querySelector('#audit-filters'),body=document.querySelector('.audit-table tbody'),pagination=document.querySelector('#audit-pagination'),status=document.querySelector('#audit-filter-status'),totalLabel=document.querySelector('#audit-total'),search=form?.elements.search;
 if(!form||!body||!pagination)return;
 let page=Number(pagination.dataset.page)||1,timer;
 const cell=(tag,text,className)=>{const el=document.createElement(tag);if(className)el.className=className;el.textContent=text??'';return el};
 const buildRow=log=>{
  const row=document.createElement('tr'),date=new Date(String(log.created_at).replace(' ','T'));
  const time=cell('td','');const stamp=cell('time','', 'audit-time');stamp.dateTime=log.created_at;stamp.append(cell('strong',Number.isNaN(date.getTime())?log.created_at:date.toLocaleDateString(undefined,{day:'numeric',month:'short',year:'numeric'})),cell('span',Number.isNaN(date.getTime())?'':date.toLocaleTimeString(undefined,{hour:'2-digit',minute:'2-digit',hour12:false})));time.append(stamp);
  const actorCell=cell('td',''),actor=cell('div','', 'audit-actor'),avatar=cell('span',(log.actor_name||'?').slice(0,1).toUpperCase(),'audit-actor-avatar');avatar.setAttribute('aria-hidden','true');const identity=cell('span','');identity.append(cell('strong',log.actor_name||'Deleted account'),cell('small',log.email||log.username||'No sign-in ID'));actor.append(avatar,identity);actorCell.append(actor);
  const actionCell=cell('td','');actionCell.append(cell('span',(log.action||'').replaceAll('_',' ').replace(/^./,c=>c.toUpperCase()),'audit-action'));
  const recordCell=cell('td','');recordCell.append(cell('span',(log.entity_type||'').replaceAll('_',' '),'audit-record-type'),cell('strong','#'+(log.entity_id??'—'),'audit-record-id'));
  const detailCell=cell('td','');if(log.details){const details=document.createElement('details');details.className='audit-details';details.append(cell('summary','View details'),cell('p',log.details));detailCell.append(details)}else detailCell.append(cell('span','No additional details','audit-no-details'));
  row.append(time,actorCell,actionCell,recordCell,detailCell);return row;
 };
 async function update(nextPage=1){
  page=nextPage;const params=new URLSearchParams(new FormData(form));params.set('page',String(page));params.set('async','1');status.textContent='Updating activity stream…';
  try{const response=await fetch('audit.php?'+params.toString(),{headers:{'Accept':'application/json'}});if(!response.ok)throw new Error();const data=await response.json();body.replaceChildren(...data.logs.map(buildRow));page=data.page;pagination.dataset.page=String(page);pagination.dataset.pages=String(data.pages);pagination.dataset.perPage=String(data.per_page);pagination.querySelector('[data-current-page]').textContent=String(data.page);pagination.querySelector('[data-total-pages]').textContent=String(data.pages);pagination.querySelector('[data-page-step="-1"]').disabled=data.page<=1;pagination.querySelector('[data-page-step="1"]').disabled=data.page>=data.pages;totalLabel.textContent=Number(data.total).toLocaleString()+' total events';status.textContent=Number(data.total).toLocaleString()+' matching events · '+data.logs.length+' shown on this page';const empty=document.querySelector('.audit-empty-state'),tableWrap=document.querySelector('.audit-table-wrap');if(empty)empty.hidden=data.logs.length>0;if(tableWrap)tableWrap.hidden=data.logs.length===0;pagination.hidden=data.total===0||data.pages<=1;
  }catch{status.textContent='Could not refresh activity. Please try again.'}
 }
 form.addEventListener('submit',e=>{e.preventDefault();update(1)});form.addEventListener('change',()=>update(1));search?.addEventListener('input',()=>{clearTimeout(timer);timer=setTimeout(()=>update(1),250)});document.querySelector('[data-clear-filters]')?.addEventListener('click',()=>{form.reset();update(1)});pagination.addEventListener('click',e=>{const button=e.target.closest('[data-page-step]');if(button&&!button.disabled)update(page+Number(button.dataset.pageStep))});
 pagination.hidden=Number(pagination.dataset.pages)<=1;
})();
</script>
</body>
</html>
