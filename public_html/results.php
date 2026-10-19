<?php
declare(strict_types=1);
session_start();
require dirname(__DIR__).'/config/config.php';
require_sign_in();

$role=$_SESSION['role']??'';
$uid=(int)($_SESSION['user_id']??0);
$allowed=['system_admin','sub_admin','admin','director','sub_director','headteacher','head_academic','assistant_academic','examination_officer','teacher'];
if(!in_array($role,$allowed,true)){http_response_code(403);exit('Your role cannot view academic results.');}
$canEdit=in_array($role,['headteacher','head_academic','assistant_academic','examination_officer','teacher'],true);
if(in_array($role,['system_admin','sub_admin'],true)){$schools=db()->query('SELECT id,name FROM schools ORDER BY name')->fetchAll();}
else{$q=db()->prepare('SELECT s.id,s.name FROM schools s JOIN school_memberships m ON m.school_id=s.id WHERE m.user_id=? ORDER BY s.name');$q->execute([$uid]);$schools=$q->fetchAll();}
$schoolIds=array_map('intval',array_column($schools,'id'));
if(!$schoolIds){http_response_code(403);exit('You do not have access to school results.');}
$marks=implode(',',array_fill(0,count($schoolIds),'?'));
$examId=(int)($_GET['exam']??$_POST['exam_id']??0);
$pupilId=(int)($_GET['pupil']??0);
$notice='';
$exam=null;
$rows=[];
$pupil=null;
$groups=[];

if($_SERVER['REQUEST_METHOD']==='POST'&&($_POST['action']??'')==='save_scores'){
    verify_csrf();
    if(!$canEdit){http_response_code(403);exit('Your role cannot edit results.');}
    $q=db()->prepare("SELECT x.* FROM school_exams x WHERE x.id=? AND x.school_id IN ($marks)");
    $q->execute(array_merge([$examId],$schoolIds));
    $saveExam=$q->fetch();
    if(!$saveExam){http_response_code(404);exit('Exam not found.');}
    $scores=$_POST['score']??[];$newScores=$_POST['new_score']??[];
    if(!is_array($scores)||!is_array($newScores)){http_response_code(400);exit('Invalid result fields.');}
    $hasNewScores=false;foreach($newScores as $subjectValues)if(is_array($subjectValues))foreach($subjectValues as $raw)if($raw!=='')$hasNewScores=true;
    if(!$scores&&!$hasNewScores){header('Location: results.php?exam='.$examId.'&saved=0');exit;}
    $db=db();$db->beginTransaction();
    try{
        $read=$db->prepare('SELECT * FROM pupil_results WHERE id=? AND school_id=? AND exam_name=? AND academic_year=?');
        $update=$db->prepare('UPDATE pupil_results SET score=? WHERE id=?');
        $audit=$db->prepare('INSERT INTO audit_logs(actor_id,action,entity_type,entity_id,details) VALUES(?,?,?,?,?)');
        $scopeClassName=null;
        if($saveExam['class_id']){$q=$db->prepare('SELECT name FROM school_classes WHERE id=? AND school_id=?');$q->execute([(int)$saveExam['class_id'],$saveExam['school_id']]);$scopeClassName=$q->fetchColumn();}
        foreach($scores as $resultId=>$rawScore){
            $resultId=filter_var($resultId,FILTER_VALIDATE_INT);$score=filter_var($rawScore,FILTER_VALIDATE_FLOAT);
            if(!$resultId||$score===false)throw new DomainException('Enter a valid score for each edited field.');
            $read->execute([$resultId,$saveExam['school_id'],$saveExam['name'],$saveExam['academic_year']]);$record=$read->fetch();
            if(!$record||($scopeClassName!==null&&$record['class_level']!==$scopeClassName))throw new DomainException('A result is outside this exam. Refresh and try again.');
            if($role==='teacher'){$access=$db->prepare('SELECT 1 FROM teacher_assignments WHERE user_id=? AND school_id=? AND class_level=? AND subject=? AND active=1 UNION SELECT 1 FROM result_delegations WHERE user_id=? AND school_id=? AND active=1 AND academic_year=? AND (class_level IS NULL OR class_level=?) LIMIT 1');$access->execute([$uid,$record['school_id'],$record['class_level'],$record['subject'],$uid,$record['school_id'],$record['academic_year'],$record['class_level']]);if(!$access->fetch())throw new DomainException('You do not have editing access to this subject and class.');}
            if($score<0||$score>(float)$record['max_score'])throw new DomainException('Scores must be between zero and the maximum shown.');
            $update->execute([$score,$resultId]);
            $audit->execute([$uid,'update','pupil_result',$resultId,json_encode(['field'=>'score','before'=>(float)$record['score'],'after'=>$score],JSON_THROW_ON_ERROR)]);
        }
        $classLevel=trim((string)($_POST['class_level']??''));$stream=trim((string)($_POST['stream']??''));$assessment=trim((string)($_POST['assessment']??''));$maxScore=filter_var($_POST['max_score']??null,FILTER_VALIDATE_FLOAT);
        if($hasNewScores){
            if(!$assessment||strlen($assessment)>120||$maxScore===false||$maxScore<=0)throw new DomainException('Enter the assessment name and a maximum score greater than zero.');
            $classCheck=$db->prepare('SELECT id FROM school_classes WHERE school_id=? AND name=?');$classCheck->execute([$saveExam['school_id'],$classLevel]);$entryClass=$classCheck->fetchColumn();
            if(!$entryClass||($scopeClassName!==null&&$scopeClassName!==$classLevel))throw new DomainException('This class is outside the selected exam.');
            $pupilCheck=$db->prepare("SELECT id FROM pupils WHERE id=? AND school_id=? AND class_level=? AND COALESCE(NULLIF(stream,''),'No stream')=? AND status='active'");
            $subjectCheck=$db->prepare('SELECT name FROM school_class_subjects WHERE id=? AND class_id=?');
            $exists=$db->prepare('SELECT id FROM pupil_results WHERE pupil_id=? AND school_id=? AND subject=? AND exam_name=? AND academic_year=? AND assessment=? LIMIT 1');
            $insert=$db->prepare('INSERT INTO pupil_results(pupil_id,school_id,class_level,stream,subject,exam_name,assessment,academic_year,score,max_score,entered_by) VALUES(?,?,?,?,?,?,?,?,?,?,?)');
            foreach($newScores as $pupilKey=>$subjectScores){
                $pupilKey=filter_var($pupilKey,FILTER_VALIDATE_INT);if(!$pupilKey||!is_array($subjectScores))throw new DomainException('Invalid pupil result entry.');
                $pupilCheck->execute([$pupilKey,$saveExam['school_id'],$classLevel,$stream]);if(!$pupilCheck->fetchColumn())throw new DomainException('A pupil is outside this class or stream. Refresh and try again.');
                foreach($subjectScores as $subjectId=>$rawScore){
                    if($rawScore==='')continue;$subjectId=filter_var($subjectId,FILTER_VALIDATE_INT);$score=filter_var($rawScore,FILTER_VALIDATE_FLOAT);
                    if(!$subjectId||$score===false||$score<0||$score>$maxScore)throw new DomainException('Enter scores between zero and the maximum shown.');
                    $subjectCheck->execute([$subjectId,$entryClass]);$subjectName=$subjectCheck->fetchColumn();if(!$subjectName)throw new DomainException('A subject is outside this class. Refresh and try again.');
                    if($role==='teacher'){$access=$db->prepare('SELECT 1 FROM teacher_assignments WHERE user_id=? AND school_id=? AND class_level=? AND subject=? AND active=1 UNION SELECT 1 FROM result_delegations WHERE user_id=? AND school_id=? AND active=1 AND academic_year=? AND (class_level IS NULL OR class_level=?) LIMIT 1');$access->execute([$uid,$saveExam['school_id'],$classLevel,$subjectName,$uid,$saveExam['school_id'],$saveExam['academic_year'],$classLevel]);if(!$access->fetch())throw new DomainException('You do not have editing access to this subject and class.');}
                    $exists->execute([$pupilKey,$saveExam['school_id'],$subjectName,$saveExam['name'],$saveExam['academic_year'],$assessment]);if($exists->fetch())throw new DomainException('That pupil already has a score for this assessment. Refresh the page to edit it.');
                    $insert->execute([$pupilKey,$saveExam['school_id'],$classLevel,$stream==='No stream'?null:$stream,$subjectName,$saveExam['name'],$assessment,$saveExam['academic_year'],$score,$maxScore,$uid]);$newId=(int)$db->lastInsertId();
                    $audit->execute([$uid,'create','pupil_result',$newId,json_encode(['assessment'=>$assessment,'subject'=>$subjectName,'score'=>$score,'max_score'=>$maxScore],JSON_THROW_ON_ERROR)]);
                }
            }
        }
        $db->commit();header('Location: results.php?exam='.$examId.'&saved=1');exit;
    }catch(Throwable $error){if($db->inTransaction())$db->rollBack();$notice=$error instanceof DomainException?$error->getMessage():'Scores could not be saved. Check the result fields and try again.';}
}

if($examId){
    $q=db()->prepare("SELECT x.*,s.name school_name,c.name class_name FROM school_exams x JOIN schools s ON s.id=x.school_id LEFT JOIN school_classes c ON c.id=x.class_id WHERE x.id=? AND x.school_id IN ($marks)");
    $q->execute(array_merge([$examId],$schoolIds));$exam=$q->fetch();
    if(!$exam){http_response_code(404);exit('Exam not found.');}
    $scopeFilter=$exam['class_id']?' AND r.class_level=(SELECT name FROM school_classes WHERE id=?)':'';
    $params=[$exam['school_id'],$exam['name'],$exam['academic_year']];
    if($exam['class_id'])$params[]=(int)$exam['class_id'];
    $teacherFilter='';
    if($role==='teacher'){$teacherFilter=' AND (EXISTS(SELECT 1 FROM teacher_assignments a WHERE a.user_id=? AND a.school_id=r.school_id AND a.class_level=r.class_level AND a.subject=r.subject AND a.active=1) OR EXISTS(SELECT 1 FROM result_delegations d WHERE d.user_id=? AND d.school_id=r.school_id AND d.active=1 AND d.academic_year=r.academic_year AND (d.class_level IS NULL OR d.class_level=r.class_level)))';$params[]=$uid;$params[]=$uid;}
    $sql="SELECT r.*,p.admission_number,p.first_name,p.middle_name,p.last_name FROM pupil_results r JOIN pupils p ON p.id=r.pupil_id WHERE r.school_id=? AND r.exam_name=? AND r.academic_year=?$scopeFilter$teacherFilter ORDER BY r.class_level,r.stream,p.last_name,p.first_name,r.subject,r.assessment";
    $q=db()->prepare($sql);$q->execute($params);$rows=$q->fetchAll();
    foreach($rows as $row){
        $className=$row['class_level'];$streamName=$row['stream']?:'No stream';$subject=$row['subject'];$pupilKey=(int)$row['pupil_id'];
        $groups[$className]['streams'][$streamName]['subjects'][$subject]=true;
        $groups[$className]['streams'][$streamName]['pupils'][$pupilKey]['name']=$row['first_name'].(!empty($row['middle_name'])?' '.$row['middle_name']:'').' '.$row['last_name'];
        $groups[$className]['streams'][$streamName]['pupils'][$pupilKey]['admission']=$row['admission_number'];
        $groups[$className]['streams'][$streamName]['pupils'][$pupilKey]['results'][$subject][]=$row;
    }
    if($exam['class_id']){$q=db()->prepare('SELECT id,name FROM school_classes WHERE id=? AND school_id=?');$q->execute([(int)$exam['class_id'],$exam['school_id']]);}
    else{$q=db()->prepare("SELECT id,name FROM school_classes WHERE school_id=? AND name IN (SELECT DISTINCT class_level FROM pupils WHERE school_id=? AND status='active')");$q->execute([$exam['school_id'],$exam['school_id']]);}
    $classList=array_column($q->fetchAll(),'id','name');
    foreach($classList as $className=>$classId){
        $q=db()->prepare("SELECT id,first_name,middle_name,last_name,admission_number,stream FROM pupils WHERE school_id=? AND class_level=? AND status='active' ORDER BY last_name,first_name");$q->execute([$exam['school_id'],$className]);$classPupils=$q->fetchAll();
        $q=db()->prepare('SELECT id,name FROM school_class_subjects WHERE class_id=? ORDER BY name');$q->execute([$classId]);$classSubjects=$q->fetchAll();
        if($role==='teacher'){$q=db()->prepare('SELECT subject FROM teacher_assignments WHERE user_id=? AND school_id=? AND class_level=? AND active=1');$q->execute([$uid,$exam['school_id'],$className]);$allowedSubjects=array_fill_keys(array_column($q->fetchAll(),'subject'),true);$q=db()->prepare('SELECT 1 FROM result_delegations WHERE user_id=? AND school_id=? AND active=1 AND academic_year=? AND (class_level IS NULL OR class_level=?) LIMIT 1');$q->execute([$uid,$exam['school_id'],$exam['academic_year'],$className]);$delegated=(bool)$q->fetchColumn();if(!$delegated)$classSubjects=array_values(array_filter($classSubjects,fn($subject)=>isset($allowedSubjects[$subject['name']])));}
        foreach($classPupils as $student){$streamName=$student['stream']?:'No stream';$pupilKey=(int)$student['id'];$groups[$className]['streams'][$streamName]['pupils'][$pupilKey]['name']=$student['first_name'].(!empty($student['middle_name'])?' '.$student['middle_name']:'').' '.$student['last_name'];$groups[$className]['streams'][$streamName]['pupils'][$pupilKey]['admission']=$student['admission_number'];$groups[$className]['streams'][$streamName]['pupils'][$pupilKey]['results']??=[];foreach($classSubjects as $subject){$groups[$className]['streams'][$streamName]['subjects'][$subject['name']]=(int)$subject['id'];}}
    }
}elseif($pupilId){
    $q=db()->prepare("SELECT p.*,s.name school_name FROM pupils p JOIN schools s ON s.id=p.school_id WHERE p.id=? AND p.school_id IN ($marks) AND p.status='active'");
    $q->execute(array_merge([$pupilId],$schoolIds));$pupil=$q->fetch();
    if(!$pupil){http_response_code(404);exit('Pupil not found.');}
    if($role==='teacher'){$access=db()->prepare('SELECT 1 FROM teacher_assignments WHERE user_id=? AND school_id=? AND class_level=? AND active=1 UNION SELECT 1 FROM result_delegations WHERE user_id=? AND school_id=? AND active=1 AND (class_level IS NULL OR class_level=?) LIMIT 1');$access->execute([$uid,$pupil['school_id'],$pupil['class_level'],$uid,$pupil['school_id'],$pupil['class_level']]);if(!$access->fetch()){http_response_code(403);exit('This pupil is outside your result-entry assignment.');}}
    if($role==='teacher'){$q=db()->prepare('SELECT r.* FROM pupil_results r WHERE r.pupil_id=? AND (EXISTS(SELECT 1 FROM teacher_assignments a WHERE a.user_id=? AND a.school_id=r.school_id AND a.class_level=r.class_level AND a.subject=r.subject AND a.active=1) OR EXISTS(SELECT 1 FROM result_delegations d WHERE d.user_id=? AND d.school_id=r.school_id AND d.active=1 AND d.academic_year=r.academic_year AND (d.class_level IS NULL OR d.class_level=r.class_level))) ORDER BY r.academic_year DESC,r.exam_name,r.subject,r.assessment');$q->execute([$pupilId,$uid,$uid]);}
    else{$q=db()->prepare('SELECT * FROM pupil_results WHERE pupil_id=? ORDER BY academic_year DESC,exam_name,subject,assessment');$q->execute([$pupilId]);}
    $rows=$q->fetchAll();
}else{http_response_code(400);exit('Choose an exam or pupil.');}

$title=$exam?($exam['name'].' · '.$exam['academic_year']):($pupil['first_name'].(!empty($pupil['middle_name'])?' '.$pupil['middle_name']:'').' '.$pupil['last_name']);
$schoolName=$exam['school_name']??$pupil['school_name']??'';
if(isset($_GET['saved']))$notice=$_GET['saved']==='1'?'Result scores saved.':'No scores were changed.';
?><!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title><?=e($title)?> · Results</title><link rel="stylesheet" href="assets/app.css"></head>
<body><div class="app-shell">
<aside class="sidebar"><a class="brand" href="index.php"><span class="brand-mark">S</span><span>shule<span class="brand-lite">lite</span></span></a><div class="workspace-label">WORKSPACE</div><nav class="side-nav" aria-label="Main navigation"><a class="nav-item" href="index.php">⌂ &nbsp;Overview</a><a class="nav-item active" href="academics.php">▤ &nbsp;Academics</a><?php if(in_array($_SESSION['role']??'', ['system_admin','sub_admin'],true)):?><a class="nav-item" href="requests.php">✉ &nbsp;Requests<?php $requestBadgeCount=pending_school_edit_request_count();if($requestBadgeCount):?><span class="side-nav-count"><?=$requestBadgeCount>99?'99+':$requestBadgeCount?></span><?php endif;?></a><?php endif;?><?php if(in_array($_SESSION['role']??'', ['system_admin','sub_admin','director'],true)):?><a class="nav-item" href="subscriptions.php">◷ &nbsp;Subscriptions</a><?php endif;?></nav><div class="sidebar-bottom"><a class="nav-item" href="logout.php">↪ &nbsp;Sign out</a></div></aside>
<main class="main-area"><header class="topbar"><div class="crumb">Workspace <span>/</span> <a href="academics.php">Academics</a> <span>/</span> Results</div><?php if(in_array($_SESSION['role']??'', ['system_admin','sub_admin'],true)):$pendingEditCount=pending_school_edit_request_count();?><a class="notification-bell" href="requests.php#requested" aria-label="<?=$pendingEditCount?> pending edit requests" title="<?=$pendingEditCount?> pending edit requests"><span aria-hidden="true">🔔</span><?php if($pendingEditCount):?><span class="notification-badge"><?=$pendingEditCount>99?'99+':$pendingEditCount?></span><?php endif;?></a><?php endif;?><div class="top-actions"><span class="role-chip"><?=e(str_replace('_',' ',$role))?></span><div class="user-name"><?=e($_SESSION['name']??'')?></div></div></header>
<div class="page-content"><section class="setup-hero"><div><div class="eyebrow">ASSESSMENT RECORDS</div><h1><?=e($title)?></h1><p class="muted"><?=e($schoolName)?></p></div><a class="button" href="academics.php">Back to academics</a></section>
<?php if($notice):?><div class="notice <?=$notice==='Result scores saved.'?'success':'error'?>" role="status"><?=e($notice)?></div><?php endif;?>
<?php if($exam):?><section class="content-section"><div class="section-heading"><div><div class="eyebrow">RESULTS</div><h2><?=count($rows)?> result records</h2></div><?php if($exam['class_name']):?><span class="count-pill"><?=e($exam['class_name'])?></span><?php else:?><span class="count-pill">All classes</span><?php endif;?></div>
<?php if(!$groups):?><div class="empty-state"><h3>No results recorded</h3><p>Results will appear here when they are entered for this exam.</p></div>
<?php else:foreach($groups as $className=>$classGroup):$pupilCount=0;foreach($classGroup['streams'] as $streamGroup)$pupilCount+=count($streamGroup['pupils']);?>
<details class="results-class"><summary><span class="results-group-title"><strong><?=e($className)?></strong><small><?=count($classGroup['streams'])?> streams</small></span><span class="count-pill"><?=$pupilCount?> pupils</span></summary><div class="results-class-content">
<?php foreach($classGroup['streams'] as $streamName=>$streamGroup):?><details class="results-stream"><summary><strong><?=e($streamName)?></strong><span class="count-pill"><?=count($streamGroup['pupils'])?> pupils</span></summary><div class="results-stream-content"><form method="post" class="results-edit-form"><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><input type="hidden" name="action" value="save_scores"><input type="hidden" name="exam_id" value="<?=$examId?>"><input type="hidden" name="class_level" value="<?=e($className)?>"><input type="hidden" name="stream" value="<?=e($streamName)?>"><?php $hasEmptyCells=false;foreach($streamGroup['pupils'] as $studentRow)foreach(array_keys($streamGroup['subjects']) as $subjectName)if(empty($studentRow['results'][$subjectName]))$hasEmptyCells=true;if($canEdit&&$hasEmptyCells):?><div class="results-entry-meta"><label>Assessment / paper<input name="assessment" maxlength="120" value="<?=e($exam['name'])?>" readonly required></label><label>Maximum score<input type="number" name="max_score" min="0.01" step="0.01" value="100" required></label></div><?php endif;?><div class="table-wrap"><table class="results-matrix"><thead><tr><th scope="col">Pupil name</th><?php foreach(array_keys($streamGroup['subjects']) as $subjectName):?><th scope="col"><?=e($subjectName)?></th><?php endforeach;?></tr></thead><tbody>
<?php foreach($streamGroup['pupils'] as $pupilKey=>$studentRow):?><tr><th scope="row"><span class="results-pupil-name"><?=e($studentRow['name'])?></span><small><?=e($studentRow['admission'])?></small><span class="results-pupil-actions"><button class="results-icon-button" type="button" aria-label="View <?=e($studentRow['name'])?>" title="View pupil"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12Z"></path><circle cx="12" cy="12" r="3"></circle></svg></button><button class="results-icon-button" type="button" aria-label="Continue for <?=e($studentRow['name'])?>" title="Continue"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 12h14"></path><path d="m12 5 7 7-7 7"></path></svg></button></span></th><?php foreach($streamGroup['subjects'] as $subjectName=>$subjectId):?><td><?php $subjectRecords=$studentRow['results'][$subjectName]??[];if(!$subjectRecords):?><label class="results-score-field"><span>Score</span><?php if($canEdit):?><input aria-label="<?=e($studentRow['name'].' · '.$subjectName.' score')?>" type="number" min="0" step="0.01" name="new_score[<?=$pupilKey?>][<?=$subjectId?>]" placeholder="—"><?php else:?><span class="muted">—</span><?php endif;?></label><?php else:foreach($subjectRecords as $record):?><label class="results-score-field"><span><?=e($record['assessment'])?> <small>/ <?=e((string)$record['max_score'])?></small></span><?php if($canEdit):?><input aria-label="<?=e($studentRow['name'].' · '.$subjectName.' · '.$record['assessment'])?>" type="number" min="0" max="<?=e((string)$record['max_score'])?>" step="0.01" name="score[<?=$record['id']?>]" value="<?=e((string)$record['score'])?>" required><?php else:?><strong><?=e((string)$record['score'])?></strong><?php endif;?></label><?php endforeach;endif;?></td><?php endforeach;?></tr><?php endforeach;?>
</tbody></table></div><?php if($canEdit):?><div class="results-save-row"><button class="button primary" type="submit">Save scores for <?=e($streamName)?></button></div><?php endif;?></form></div></details><?php endforeach;?></div></details><?php endforeach;endif;?></section>
<?php else:?><section class="content-section"><div class="section-heading"><div><div class="eyebrow">PUPIL RESULTS</div><h2><?=count($rows)?> records</h2></div></div><?php if($rows):?><div class="table-wrap"><table><thead><tr><th>Academic year</th><th>Exam</th><th>Subject</th><th>Assessment / paper</th><th>Score</th></tr></thead><tbody><?php foreach($rows as $r):?><tr><td><?=e((string)$r['academic_year'])?></td><td><?=e($r['exam_name'])?></td><td><?=e($r['subject'])?></td><td><?=e($r['assessment'])?></td><td><?=e($r['score'].' / '.$r['max_score'])?></td></tr><?php endforeach;?></tbody></table></div><?php else:?><div class="empty-state"><h3>No results recorded</h3><p>Results will appear here when they are entered for this pupil.</p></div><?php endif;?></section><?php endif;?>
</div></main></div><script>
(()=>{
const scoreInputs='input[name^="new_score["],input[name^="score["]';
const numericValue=input=>input.value.trim()===''?null:Number(input.value);
const maximumFor=input=>{if(input.name.startsWith('new_score[')){const field=input.form?.querySelector('[name="max_score"]');return field?Number(field.value):null}return input.max!==''?Number(input.max):null};
const validateScore=input=>{const score=numericValue(input),maximum=maximumFor(input);if(score===null||!Number.isFinite(score)||maximum===null||!Number.isFinite(maximum))return true;if(score>maximum){input.setCustomValidity(`Score cannot exceed the maximum of ${maximum}.`);input.setAttribute('aria-invalid','true');input.classList.remove('score-invalid-shake');void input.offsetWidth;input.classList.add('score-invalid-shake');requestAnimationFrame(()=>{input.focus();input.select()});return false}input.setCustomValidity('');input.removeAttribute('aria-invalid');input.classList.remove('score-invalid-shake');return true};
document.addEventListener('focusout',event=>{const input=event.target.closest(scoreInputs);if(input)validateScore(input)});
document.addEventListener('input',event=>{const input=event.target.closest(scoreInputs);if(input){input.setCustomValidity('');input.removeAttribute('aria-invalid');input.classList.remove('score-invalid-shake')}});
document.addEventListener('submit',event=>{const form=event.target.closest('.results-edit-form');if(!form)return;for(const input of form.querySelectorAll(scoreInputs)){if(!validateScore(input)){event.preventDefault();return}}});
})();
</script></body></html>
