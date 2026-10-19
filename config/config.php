<?php
declare(strict_types=1);

const DB_HOST = 'localhost';
const DB_NAME = 'somaspac_shulelite2';
const DB_USER = 'root';
const DB_PASS = '';

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
function pending_school_edit_request_count(): int
{
    static $count = null;
    if ($count !== null) return $count;
    if (!in_array($_SESSION['role'] ?? '', ['system_admin', 'sub_admin'], true)) return 0;
    try { $count = (int)db()->query("SELECT COUNT(*) FROM school_edit_requests WHERE status='pending'")->fetchColumn(); }
    catch (Throwable $error) { $count = 0; }
    return $count;
}
