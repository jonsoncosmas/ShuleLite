<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit("Run this setup from the command line.\n");
}
require dirname(__DIR__) . '/config/config.php';

fwrite(STDOUT, "ShuleLite first system administrator\nName: ");
$name = trim((string)fgets(STDIN));
fwrite(STDOUT, "Email: ");
$email = strtolower(trim((string)fgets(STDIN)));
fwrite(STDOUT, "Password (minimum 12 characters): ");
$password = trim((string)fgets(STDIN));
if ($name === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($password) < 12) {
    fwrite(STDERR, "Enter a name, valid email, and password with at least 12 characters.\n");
    exit(1);
}
$stmt = db()->prepare("INSERT INTO users (name,email,password_hash,role) VALUES (?,?,?,'system_admin')");
try {
    $stmt->execute([$name, $email, password_hash($password, PASSWORD_DEFAULT)]);
    fwrite(STDOUT, "System administrator created. Sign in at /login.php.\n");
} catch (PDOException $error) {
    fwrite(STDERR, $error->getCode() === '23000' ? "That email already has an account.\n" : "Could not create the account. Check database/schema.sql and the database connection.\n");
    exit(1);
}
