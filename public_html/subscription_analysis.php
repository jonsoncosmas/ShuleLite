<?php
declare(strict_types=1);
session_start();
require dirname(__DIR__).'/config/config.php';
require_sign_in();
if(($_SESSION['role']??'')!=='system_admin'){http_response_code(403);exit('Only system admins can analyze subscription income.');}
$year=filter_var($_GET['year']??date('Y'),FILTER_VALIDATE_INT);
if($year===false||$year<2000||$year>2100)$year=(int)date('Y');
header('Location: subscriptions.php?year='.$year.'#income');
exit;
