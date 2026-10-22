<?php
declare(strict_types=1);
session_start();
require dirname(__DIR__).'/config/config.php';
require_sign_in();
$role=(string)($_SESSION['role']??'');
if(!in_array($role,['admin','director','sub_director','headteacher','bursar'],true)){
    http_response_code(403);exit('Your role cannot access fee arrears.');
}
$uid=(int)$_SESSION['user_id'];
$school=filter_var($_GET['school_id']??null,FILTER_VALIDATE_INT);
if(!$school||$school<1){http_response_code(422);exit('Choose a school.');}
$db=db();
$q=$db->prepare('SELECT s.name FROM schools s JOIN school_memberships m ON m.school_id=s.id WHERE s.id=? AND m.user_id=?');
$q->execute([$school,$uid]);
$schoolName=$q->fetchColumn();
if($schoolName===false){http_response_code(403);exit('That school is outside your access.');}
$q=$db->prepare("SELECT p.admission_number,p.first_name,p.middle_name,p.last_name,p.class_level,p.status,b.balance FROM pupils p JOIN (SELECT pupil_id,SUM(CASE WHEN entry_type IN ('charge','payment_reversal','discount_reversal') THEN amount WHEN entry_type IN ('payment','charge_reversal','discount') THEN -amount ELSE 0 END) balance FROM school_fee_ledger WHERE school_id=? GROUP BY pupil_id HAVING balance>0) b ON b.pupil_id=p.id WHERE p.school_id=? ORDER BY b.balance DESC,p.class_level,p.last_name,p.first_name");
$q->execute([$school,$school]);
header('Content-Type: text/csv; charset=utf-8');
header('Content-Disposition: attachment; filename="fee-arrears-'.(int)$school.'-'.date('Ymd').'.csv"');
header('Cache-Control: no-store');
$out=fopen('php://output','wb');
$safeCsvCell=static function(mixed $value):string{$cell=(string)$value;return preg_match('/^[\s]*[=+@\-]/',$cell)?"'".$cell:$cell;};
fputcsv($out,array_map($safeCsvCell,[$schoolName,'Fee arrears report',date('Y-m-d')]));
fputcsv($out,['Admission number','Pupil name','Class','Status','Outstanding balance (KES)']);
while($row=$q->fetch()){
    $cells=[$row['admission_number'],trim($row['first_name'].' '.$row['middle_name'].' '.$row['last_name']),$row['class_level'],$row['status'],number_format((float)$row['balance'],2,'.','')];
    fputcsv($out,array_map($safeCsvCell,$cells));
}
fclose($out);
