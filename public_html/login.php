<?php
declare(strict_types=1);
session_start();
require dirname(__DIR__) . '/config/config.php';
if (signed_in()) { header('Location: index.php'); exit; }
$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    verify_csrf();
    $identifier = trim((string)($_POST['identifier'] ?? ''));
    $password = (string)($_POST['password'] ?? '');
    if ($identifier === '' || $password === '') {
        $error = 'Enter your email or username and password.';
    } else {
        try {
            $stmt = db()->prepare('SELECT id, name, email, password_hash, role, status FROM users WHERE email = ? OR username = ? LIMIT 1');
            $stmt->execute([$identifier, strtolower($identifier)]); $user = $stmt->fetch();
            if ($user && $user['status'] === 'active' && password_verify($password, $user['password_hash'])) {
                session_regenerate_id(true);
                $_SESSION['user_id'] = (int)$user['id']; $_SESSION['name'] = $user['name']; $_SESSION['role'] = $user['role'];
                header('Location: index.php'); exit;
            }
            $error = 'Those sign-in details did not match an active account.';
        } catch (PDOException $e) { $error = 'ShuleLite is not connected yet. Import the database schema and try again.'; }
    }
}
?><!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="theme-color" content="#f7f8f4"><title>Sign in · ShuleLite</title><link rel="stylesheet" href="assets/app.css"><script defer src="assets/app.js"></script></head><body class="auth-page"><main class="auth-shell"><a class="brand" href="index.php"><span class="brand-mark">S</span><span>shule<span class="brand-lite">lite</span></span></a><section class="auth-card"><div class="eyebrow">YOUR SCHOOL, IN SYNC</div><h1>Good to have you back.</h1><p class="muted">Sign in to continue to your school workspace.</p><?php if ($error): ?><div class="notice error" role="alert"><?=e($error)?></div><?php endif; ?><form method="post" action="login.php" class="form-stack"><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><label for="identifier">Email or username</label><input id="identifier" name="identifier" type="text" autocomplete="username" required value="<?=e($_POST['identifier'] ?? '')?>"><label for="password">Password</label><div class="password-wrap"><input id="password" name="password" type="password" autocomplete="current-password" required><button type="button" class="password-toggle" aria-label="Show password" aria-pressed="false">Show</button></div><button class="button primary full" type="submit">Sign in <span aria-hidden="true">→</span></button></form><p class="auth-foot">Need access? Ask your school administrator to invite you.</p></section><div class="auth-caption">A calmer way to run a school day.</div></main></body></html>
