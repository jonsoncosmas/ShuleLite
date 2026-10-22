<?php
declare(strict_types=1);
session_start();
require dirname(__DIR__).'/config/config.php';
require_sign_in();
if(!in_array($_SESSION['role']??'', ['admin','director','sub_director','headteacher','head_academic','assistant_academic'], true)){http_response_code(403);exit('You cannot bulk import pupils.');}$school=filter_var($_GET['school_id']??null,FILTER_VALIDATE_INT);if(!$school){http_response_code(422);exit('Choose a school.');}$q=db()->prepare('SELECT 1 FROM school_memberships WHERE user_id=? AND school_id=?');$q->execute([(int)$_SESSION['user_id'],$school]);if(!$q->fetchColumn()){http_response_code(403);exit('That school is outside your access.');}
header('Content-Type: text/csv; charset=utf-8');header('Content-Disposition: attachment; filename="shulelite-pupil-import-template.csv"');header('Cache-Control: no-store');
$out=fopen('php://output','w');fputcsv($out,['Admission Number','Full Names','Class level','Stream','DOB','Day or Boarding','Parent/guardian name','Guardian phone number']);fputcsv($out,['','','','','','','','']);fclose($out);
