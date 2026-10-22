<?php
declare(strict_types=1);
function school_sms_template(string $event,?PDO $db=null,?int $school=null):string
{
    $body=match($event){
        'fee_payment'=>'A fee payment has been recorded for your linked child. Sign in to ShuleLite to view the receipt.',
        'attendance_alert'=>'Your linked child has an absence or late mark. Sign in to ShuleLite to view school attendance details.',
        'exam_publication'=>'New examination results for your linked child are available in ShuleLite.',
        'school_announcement'=>'Your school has shared a new announcement. Sign in to ShuleLite to read it.',
        'fee_reminder'=>'A school fee balance remains for your linked child. Sign in to ShuleLite to view the account.',
        'contract_expiry'=>'A staff contract is due for review within 30 days. Please contact your school administrator.',
        default=>throw new InvalidArgumentException('Unsupported school SMS event.'),
    };
    if($db&&$school){$q=$db->prepare('SELECT message_body FROM school_sms_templates WHERE school_id=? AND event_type=?');$q->execute([$school,$event]);$custom=$q->fetchColumn();if(is_string($custom)&&trim($custom)!=='')return trim($custom);}
    return $body;
}
function queue_school_sms_event(PDO $db,int $school,int $pupil,string $sourceType,int $sourceId,string $event,int $actor):int
{
    if(!in_array($event,['fee_payment','attendance_alert','exam_publication','school_announcement','fee_reminder'],true)||$school<1||$pupil<1||$sourceId<1)throw new InvalidArgumentException('Invalid notification event.');
    $q=$db->prepare("SELECT DISTINCT g.guardian_user_id,u.phone FROM pupil_guardians g JOIN users u ON u.id=g.guardian_user_id WHERE g.school_id=? AND g.pupil_id=? AND g.receives_notifications=1 AND u.role='parent' AND u.status='active' AND u.phone IS NOT NULL AND TRIM(u.phone)<>''");$q->execute([$school,$pupil]);$rows=$q->fetchAll();
    $insert=$db->prepare("INSERT IGNORE INTO school_sms_outbox(school_id,pupil_id,recipient_user_id,recipient_phone,event_type,source_type,source_id,message_body,created_by) VALUES(?,?,?,?,?,?,?,?,?)");$created=0;$body=school_sms_template($event,$db,$school);
    foreach($rows as $row){$insert->execute([$school,$pupil,(int)$row['guardian_user_id'],trim((string)$row['phone']),$event,substr($sourceType,0,60),$sourceId,$body,$actor]);$created+=$insert->rowCount();}
    return $created;
}

function queue_school_announcement_sms(PDO $db,int $school,int $announcement,int $actor):int
{
    if($school<1||$announcement<1)throw new InvalidArgumentException('Invalid announcement notification event.');
    $q=$db->prepare("SELECT g.guardian_user_id,u.phone FROM pupil_guardians g JOIN users u ON u.id=g.guardian_user_id JOIN school_announcements a ON a.id=? AND a.school_id=g.school_id WHERE g.school_id=? AND g.receives_notifications=1 AND u.role='parent' AND u.status='active' AND u.phone IS NOT NULL AND TRIM(u.phone)<>'' AND a.status='published' AND a.audience IN ('all','parents') AND (a.expires_at IS NULL OR a.expires_at>=CURRENT_DATE) GROUP BY g.guardian_user_id,u.phone");$q->execute([$announcement,$school]);$insert=$db->prepare("INSERT IGNORE INTO school_sms_outbox(school_id,pupil_id,recipient_user_id,recipient_phone,event_type,source_type,source_id,message_body,created_by) VALUES(?,NULL,?,?, 'school_announcement','school_announcement',?,?,?)");$created=0;$body=school_sms_template('school_announcement',$db,$school);foreach($q->fetchAll() as $guardian){$insert->execute([$school,(int)$guardian['guardian_user_id'],trim((string)$guardian['phone']),$announcement,$body,$actor]);$created+=$insert->rowCount();}return $created;
}

function queue_contract_expiry_sms(PDO $db):int
{
    $q=$db->query("SELECT c.id,c.school_id,c.user_id,u.phone FROM employee_contracts c JOIN users u ON u.id=c.user_id JOIN school_memberships m ON m.user_id=u.id AND m.school_id=c.school_id WHERE c.status='active' AND c.end_date BETWEEN CURRENT_DATE AND DATE_ADD(CURRENT_DATE,INTERVAL 30 DAY) AND u.status='active' AND u.phone IS NOT NULL AND TRIM(u.phone)<>'' AND u.role NOT IN ('system_admin','sub_admin','admin','parent','pupil') ORDER BY c.end_date,c.id LIMIT 500");
    $insert=$db->prepare("INSERT IGNORE INTO school_sms_outbox(school_id,pupil_id,recipient_user_id,recipient_phone,event_type,source_type,source_id,message_body) VALUES(?,NULL,?,?,'contract_expiry','employee_contract',?,?)");$created=0;
    foreach($q->fetchAll() as $contract){$body=school_sms_template('contract_expiry',$db,(int)$contract['school_id']);$insert->execute([(int)$contract['school_id'],(int)$contract['user_id'],trim((string)$contract['phone']),(int)$contract['id'],$body]);$created+=$insert->rowCount();}return $created;
}

function shule_sms_send_notification(string $phone,string $body,string $reference):array
{
    $endpoint='https://messaging-service.co.tz/api/sms/v1/text/single';$token=shule_sms_basic_auth();$to=director_sms_phone($phone);
    if($token==='')return ['accepted'=>false,'http_status'=>null,'message_id'=>null,'diagnostic'=>'SMS authorization is not configured.'];
    if(!$to)return ['accepted'=>false,'http_status'=>null,'message_id'=>null,'diagnostic'=>'The guardian phone could not be formatted as a Tanzania mobile number.'];
    if(!function_exists('curl_init'))return ['accepted'=>false,'http_status'=>null,'message_id'=>null,'diagnostic'=>'PHP cURL is not enabled.'];
    $sender=trim((string)getenv('SHULELITE_SMS_SENDER'))?:'Elimika';$payload=json_encode(['from'=>$sender,'to'=>$to,'text'=>$body,'reference'=>$reference],JSON_UNESCAPED_UNICODE);
    if($payload===false)return ['accepted'=>false,'http_status'=>null,'message_id'=>null,'diagnostic'=>'The SMS request could not be encoded.'];
    $curl=curl_init($endpoint);curl_setopt_array($curl,[CURLOPT_RETURNTRANSFER=>true,CURLOPT_TIMEOUT=>20,CURLOPT_CONNECTTIMEOUT=>8,CURLOPT_FOLLOWLOCATION=>false,CURLOPT_POST=>true,CURLOPT_POSTFIELDS=>$payload,CURLOPT_HTTPHEADER=>['Authorization: '.(str_starts_with($token,'Basic ')?$token:'Basic '.$token),'Content-Type: application/json','Accept: application/json']]);$response=curl_exec($curl);$error=curl_error($curl);$status=(int)curl_getinfo($curl,CURLINFO_HTTP_CODE);$errno=curl_errno($curl);curl_close($curl);$decoded=is_string($response)?json_decode($response,true):null;$id=is_array($decoded)?(string)($decoded['message_id']??$decoded['data']['message_id']??$decoded['messages'][0]['messageId']??''):'';$success=is_array($decoded)&&(($decoded['success']??false)===true||$id!=='');$accepted=$errno===0&&$status>=200&&$status<300&&$success;
    $diagnostic=$errno?'Transport error '.$errno.': '.substr($error,0,500):(!$accepted?'Provider did not confirm SMS acceptance (HTTP '.$status.').':'Provider accepted SMS.');return ['accepted'=>$accepted,'http_status'=>$status?:null,'message_id'=>$id?:null,'recipient'=>$to,'diagnostic'=>$diagnostic];
}
