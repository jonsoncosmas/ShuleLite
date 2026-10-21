<?php
declare(strict_types=1);
$id=filter_input(INPUT_GET,'id',FILTER_VALIDATE_INT);
header('Location: school_analyze.php?id='.(int)$id);
exit;
