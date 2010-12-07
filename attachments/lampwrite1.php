<HTML>
<HEAD><TITLE>synclamp</TITLE></HEAD>
<BODY>
<?php
$fw1 = fopen("lampstate1.txt", "w");

$fp1 = fopen("lamplog1.txt", "a");
$fp2 = fopen("lamplog2.txt", "a");


$s1 = $_GET['state'];
$s2 = $_GET['id'];

//$s3 = $s1 + ",";

$time = date ("Y/m/d H:i:s,");
//print $s2;
if ($s2 == 1 || $s2 == 2)
{ 
fputs($fw1, $s1);
fclose($fw1);

if($s2 == 1)
{
fputs($fp1, $time);
fputs($fp1, $s1);
fclose($fp1);
}
else if($s2 == 2)
{
fputs($fp2, $time);
fputs($fp2, $s1);
fclose($fp2);
}
}

?>
</BODY>
</HTML>
