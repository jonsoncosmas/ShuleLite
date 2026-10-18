<?php
declare(strict_types=1);
session_start();
require dirname(__DIR__).'/config/config.php';
require_sign_in();
if(!in_array($_SESSION['role']??'', ['director','sub_director','headteacher','head_academic','assistant_academic'], true)){http_response_code(403);exit('You cannot register pupils.');}
header('Content-Type: text/csv; charset=utf-8');header('Content-Disposition: attachment; filename="shulelite-pupil-import-template.csv"');header('Cache-Control: no-store');
$out=fopen('php://output','w');fputcsv($out,['Admission Number','Full Names','Class level','Stream','DOB','Day or Boarding','Parent/guardian name','Guardian phone number']);fputcsv($out,['','','','','','','','']);fclose($out);
