<?php
declare(strict_types=1);

const DB_HOST = 'localhost';
const DB_NAME = 'somaspac_shulelite2';
const DB_USER = 'root';
const DB_PASS = '';

function shule_sms_basic_auth(): string
{
    $environment = trim((string) getenv('SHULELITE_SMS_BASIC_AUTH'));
    if ($environment !== '') return $environment;
    $localFile = __DIR__ . '/sms.local.php';
    if (!is_file($localFile)) return '';
    $settings = require $localFile;
    return is_array($settings) ? trim((string) ($settings['basic_auth'] ?? '')) : '';
}

function db(): PDO
{
    static $pdo;
    if (!$pdo) {
        $pdo = new PDO('mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4', DB_USER, DB_PASS, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    }
    return $pdo;
}

function e(?string $value): string { return htmlspecialchars($value ?? '', ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }
function render_school_select(string $id, array $schools): string
{
    if (count($schools) === 1) {
        $school = $schools[0];
        return '<input type="hidden" name="school_id" value="' . (int)$school['id'] . '"><div class="school-context">School: <strong>' . e($school['name']) . '</strong></div>';
    }
    $html = '<div><label for="' . e($id) . '">School</label><select name="school_id" id="' . e($id) . '" required><option value="">Choose school</option>';
    foreach ($schools as $school) $html .= '<option value="' . (int)$school['id'] . '">' . e($school['name']) . '</option>';
    return $html . '</select></div>';
}
function csrf_token(): string
{
    if (empty($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(32));
    return $_SESSION['csrf'];
}
function verify_csrf(): void
{
    if (!hash_equals($_SESSION['csrf'] ?? '', $_POST['csrf'] ?? '')) {
        http_response_code(400); exit('Your session expired. Refresh the page and try again.');
    }
}
function signed_in(): bool { return !empty($_SESSION['user_id']); }
function require_sign_in(): void
{
    if (!signed_in()) { header('Location: login.php'); exit; }
    try {
        $check = db()->prepare('SELECT status, must_change_password FROM users WHERE id = ?');
        $check->execute([(int)$_SESSION['user_id']]);
        $account = $check->fetch();
        if (!$account || $account['status'] !== 'active') {
            $_SESSION = [];
            session_destroy();
            header('Location: login.php?account=suspended'); exit;
        }
        $_SESSION['must_change_password'] = (bool)$account['must_change_password'];
    } catch (PDOException $error) {
        http_response_code(503); exit('Account access could not be verified. Please try again.');
    }
    $page = basename((string)($_SERVER['SCRIPT_NAME'] ?? ''));
    if (!empty($_SESSION['must_change_password']) && !in_array($page, ['profile.php','logout.php'], true)) {
        header('Location: profile.php?force_password=1'); exit;
    }
}
function can_manage_schools(): bool { return in_array($_SESSION['role'] ?? '', ['system_admin', 'sub_admin'], true); }
function can_access_school_setup(?int $userId = null, ?string $role = null): bool
{
    static $cache = [];
    $role ??= (string)($_SESSION['role'] ?? '');
    $userId ??= (int)($_SESSION['user_id'] ?? 0);
    if ($userId < 1 || in_array($role, ['system_admin','sub_admin'], true)) return false;
    $key = $userId . ':' . $role;
    if (array_key_exists($key, $cache)) return $cache[$key];
    try {
        if (in_array($role, ['headteacher','director'], true)) {
            $q = db()->prepare('SELECT 1 FROM school_memberships WHERE user_id=? LIMIT 1');
            $q->execute([$userId]);
        } elseif ($role === 'admin') {
            $q = db()->prepare('SELECT 1 FROM school_memberships m JOIN school_setup_permissions p ON p.school_id=m.school_id AND p.user_id=m.user_id WHERE m.user_id=? AND p.active=1 LIMIT 1');
            $q->execute([$userId]);
        } else return $cache[$key] = false;
        return $cache[$key] = (bool)$q->fetchColumn();
    } catch (Throwable $error) { return $cache[$key] = false; }
}
function pending_school_edit_request_count(): int
{
    static $count = null;
    if ($count !== null) return $count;
    if (!in_array($_SESSION['role'] ?? '', ['system_admin', 'sub_admin'], true)) return 0;
    try { $count = (int)db()->query("SELECT COUNT(*) FROM school_edit_requests WHERE status='pending'")->fetchColumn(); }
    catch (Throwable $error) { $count = 0; }
    return $count;
}

function director_sms_phone(string $phone): ?string
{
    $digits = preg_replace('/\D+/', '', $phone) ?? '';
    if (str_starts_with($digits, '0')) $digits = '255' . substr($digits, 1);
    elseif (!str_starts_with($digits, '255')) $digits = '255' . $digits;
    if (strlen($digits) < 8 || strlen($digits) > 15) return null;
    return $digits;
}

function send_director_password_sms(string $phone, string $name, string $password): array
{
    $endpoint = 'https://messaging-service.co.tz/api/sms/v1/text/single';
    $token = shule_sms_basic_auth();
    $to = director_sms_phone($phone);
    if ($token === '') return ['accepted'=>false,'endpoint'=>$endpoint,'http_status'=>null,'message_id'=>null,'diagnostic'=>'SMS authorization is not configured.'];
    if (!$to) return ['accepted'=>false,'endpoint'=>$endpoint,'http_status'=>null,'message_id'=>null,'diagnostic'=>'The phone number could not be formatted as a Tanzania mobile number.'];
    if (!function_exists('curl_init')) return ['accepted'=>false,'endpoint'=>$endpoint,'http_status'=>null,'message_id'=>null,'diagnostic'=>'PHP cURL is not enabled.'];
    $sender = trim((string) getenv('SHULELITE_SMS_SENDER')) ?: 'Elimika';
    $payload = json_encode(['from'=>$sender,'to'=>$to,'text'=>"Hello {$name}, your ShuleLite temporary password is {$password}. Sign in and change it immediately.",'reference'=>'director-'.bin2hex(random_bytes(6))]);
    if ($payload === false) return ['accepted'=>false,'endpoint'=>$endpoint,'http_status'=>null,'message_id'=>null,'diagnostic'=>'The SMS request could not be encoded as JSON.'];
    $curl = curl_init($endpoint);
    curl_setopt_array($curl,[CURLOPT_RETURNTRANSFER=>true,CURLOPT_TIMEOUT=>20,CURLOPT_FOLLOWLOCATION=>false,CURLOPT_CUSTOMREQUEST=>'POST',CURLOPT_POSTFIELDS=>$payload,CURLOPT_HTTPHEADER=>['Authorization: '.(str_starts_with($token,'Basic ')?$token:'Basic '.$token),'Content-Type: application/json','Accept: application/json']]);
    $body=curl_exec($curl);$curlError=curl_error($curl);$status=(int)curl_getinfo($curl,CURLINFO_HTTP_CODE);$errno=curl_errno($curl);curl_close($curl);
    $decoded=is_string($body)?json_decode($body,true):null;$providerSuccess=is_array($decoded)?($decoded['success']??null):null;$accepted=$errno===0&&$status>=200&&$status<300&&$providerSuccess===true;
    $messageId=is_array($decoded)?(string)($decoded['message_id']??$decoded['data']['message_id']??''):'';
    if($errno!==0)$diagnostic='cURL error '.$errno.': '.$curlError;
    elseif($status<200||$status>=300)$diagnostic='Provider returned HTTP '.$status.'.';
    elseif($providerSuccess!==true){$providerMessage=is_array($decoded)?($decoded['message']??$decoded['error']??'Provider response did not confirm success.'):'';$diagnostic=is_scalar($providerMessage)?(string)$providerMessage:'Provider response did not confirm success.';if($diagnostic==='')$diagnostic='Provider returned a non-JSON response instead of success confirmation.';}
    else{$providerMessage=$decoded['message']??'Provider accepted the message.';$diagnostic=is_scalar($providerMessage)?(string)$providerMessage:'Provider accepted the message.';}
    $diagnostic=trim(preg_replace('/\s+/',' ',str_replace([$password,$payload],['[redacted]','[request redacted]'],$diagnostic))??'');
    if(is_string($body)&&$body!==''&&$providerSuccess!==true){$bodyText=trim(preg_replace('/\s+/',' ',str_replace([$password,$payload],['[redacted]','[request redacted]'],$body))??'');if($bodyText!=='')$diagnostic=substr($diagnostic.' Provider response: '.$bodyText,0,1200);}
    return ['accepted'=>$accepted,'endpoint'=>$endpoint,'http_status'=>$status?:null,'message_id'=>$messageId?:null,'recipient'=>$to,'diagnostic'=>substr($diagnostic,0,1200)];
}

function check_director_sms_delivery(string $messageId): array
{
    $endpoint = 'https://messaging-service.co.tz/api/sms/v1/reports?messageId=' . rawurlencode($messageId);
    $token = shule_sms_basic_auth();
    if ($token === '') return ['ok'=>false,'endpoint'=>$endpoint,'http_status'=>null,'delivery_status'=>null,'diagnostic'=>'SMS authorization is not configured.'];
    if (!function_exists('curl_init')) return ['ok'=>false,'endpoint'=>$endpoint,'http_status'=>null,'delivery_status'=>null,'diagnostic'=>'PHP cURL is not enabled.'];
    $curl = curl_init($endpoint);
    curl_setopt_array($curl,[CURLOPT_RETURNTRANSFER=>true,CURLOPT_TIMEOUT=>20,CURLOPT_FOLLOWLOCATION=>false,CURLOPT_HTTPGET=>true,CURLOPT_HTTPHEADER=>['Authorization: '.(str_starts_with($token,'Basic ')?$token:'Basic '.$token),'Accept: application/json']]);
    $body=curl_exec($curl);$curlError=curl_error($curl);$status=(int)curl_getinfo($curl,CURLINFO_HTTP_CODE);$errno=curl_errno($curl);curl_close($curl);
    $data=is_string($body)?json_decode($body,true):null;
    if($errno!==0)return ['ok'=>false,'endpoint'=>$endpoint,'http_status'=>$status?:null,'delivery_status'=>null,'diagnostic'=>'Status lookup cURL error '.$errno.': '.$curlError];
    if($status<200||$status>=300)return ['ok'=>false,'endpoint'=>$endpoint,'http_status'=>$status?:null,'delivery_status'=>null,'diagnostic'=>'Status provider returned HTTP '.$status.'.'];
    $report=$data;
    if(is_array($report)&&isset($report['data']))$report=$report['data'];
    if(is_array($report)&&array_is_list($report))$report=$report[0]??[];
    $raw=is_array($report)?($report['status']??$report['delivery_status']??$report['deliveryStatus']??$report['state']??null):null;
    if(!is_scalar($raw)||trim((string)$raw)==='')return ['ok'=>false,'endpoint'=>$endpoint,'http_status'=>$status,'delivery_status'=>null,'diagnostic'=>'Provider returned no delivery status for this message.'];
    $delivery=strtolower(trim((string)$raw));
    return ['ok'=>true,'endpoint'=>$endpoint,'http_status'=>$status,'delivery_status'=>substr($delivery,0,40),'diagnostic'=>'Provider delivery status: '.substr((string)$raw,0,160).'.'];
}
