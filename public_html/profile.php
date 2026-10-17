<?php
declare(strict_types=1);
session_start();
require dirname(__DIR__) . '/config/config.php';
require_sign_in();
$uid=(int)$_SESSION['user_id']; $error=''; $forced=!empty($_SESSION['must_change_password']);
if($_SERVER['REQUEST_METHOD']==='POST'){
 verify_csrf();
 if(isset($_POST['new_password'])){
  $current=(string)($_POST['current_password']??''); $new=(string)($_POST['new_password']??''); $confirm=(string)($_POST['confirm_password']??'');
  $q=db()->prepare('SELECT password_hash FROM users WHERE id=?'); $q->execute([$uid]); $hash=(string)$q->fetchColumn();
  if(!password_verify($current,$hash)) $error='Current password did not match. Try again.';
  elseif(strlen($new)<12) $error='Choose a password with at least 12 characters.';
  elseif($new!==$confirm) $error='The new passwords do not match.';
  elseif(password_verify($new,$hash)) $error='Choose a new password you have not used for this account.';
  else { $q=db()->prepare('UPDATE users SET password_hash=?,must_change_password=FALSE WHERE id=?'); $q->execute([password_hash($new,PASSWORD_DEFAULT),$uid]); $_SESSION['must_change_password']=false; header('Location: profile.php?changed=1'); exit; }
 } else {
  $username=strtolower(trim((string)($_POST['username']??'')));
  if(!preg_match('/^[a-z0-9._-]{3,60}$/',$username)) $error='Use 3–60 lowercase letters, numbers, dots, underscores or hyphens.';
  else { try { $q=db()->prepare('UPDATE users SET username=? WHERE id=?'); $q->execute([$username,$uid]); header('Location: profile.php?username_saved=1'); exit; } catch(PDOException $ex) { $error=$ex->getCode()==='23000'?'That username is already in use. Choose another one.':'Username could not be saved. Verify the database migration was applied.'; } }
 }
}
$q=db()->prepare('SELECT name,email,username FROM users WHERE id=?'); $q->execute([$uid]); $user=$q->fetch();
?><!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title><?= $forced?'Change your password':'My account' ?> · ShuleLite</title><link rel="stylesheet" href="assets/app.css"></head><body><main class="auth-page"><section class="auth-shell"><a class="brand" href="<?= $forced?'#':'index.php' ?>"><span class="brand-mark">S</span><span>shule<span class="brand-lite">lite</span></span></a><div class="auth-card"><div class="eyebrow"><?= $forced?'ACCOUNT SECURITY':'ACCOUNT SETTINGS' ?></div><h1><?= $forced?'Choose a new password':'My account' ?></h1><?php if($forced):?><p class="muted">Replace your temporary password before continuing. Choose at least 12 characters.</p><?php else:?><p class="muted">Your email and username can both be used to sign in.</p><?php endif;?><?php if($error):?><div class="notice error" role="alert"><?=e($error)?></div><?php endif;?><?php if(isset($_GET['changed'])):?><div class="notice success" role="status">Password changed. Your account is ready.</div><?php elseif(isset($_GET['username_saved'])):?><div class="notice success" role="status">Username saved. You can now use it to sign in.</div><?php endif;?><?php if($forced):?><form method="post" class="form-stack"><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><label for="current-password">Temporary password</label><input id="current-password" name="current_password" type="password" autocomplete="current-password" required><label for="new-password">New password</label><input id="new-password" name="new_password" type="password" minlength="12" autocomplete="new-password" required><label for="confirm-password">Confirm new password</label><input id="confirm-password" name="confirm_password" type="password" minlength="12" autocomplete="new-password" required><button class="button primary full" type="submit">Change password</button></form><?php else:?><p><strong><?=e($user['name'])?></strong><br><span class="muted"><?=e($user['email'])?></span></p><form method="post" class="form-stack"><input type="hidden" name="csrf" value="<?=e(csrf_token())?>"><label for="username">Username</label><input id="username" name="username" autocomplete="username" minlength="3" maxlength="60" pattern="[a-zA-Z0-9._-]+" required value="<?=e($user['username']??'')?>"><button class="button primary full" type="submit">Save username</button></form><p class="auth-foot"><a href="index.php">Return to ShuleLite</a></p><?php endif;?></div></section></main></body></html>