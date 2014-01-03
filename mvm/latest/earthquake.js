<html>
<head>
<script>
function startEQ()
{
richter=5;
parent.moveBy(0,richter);

setTimeout("parent.moveBy(richter,0)", 10);
setTimeout("parent.moveBy(0,-richter)", 20);
setTimeout("parent.moveBy(-richter,0)", 30);
timer=setTimeout("startEQ()",40);
setTimeout("stopEQ()",500);
}
function stopEQ()
{
clearTimeout(timer);
}
</script>
</head>
<body onload="setTimeout('startEQ()',500)">

<form>
<input type="button" value="Start an earthquake">
<br />
<br />
<input type="button" onclick="stopEQ()" value="Stop the earthquake">
</form>

</body>
</html>
