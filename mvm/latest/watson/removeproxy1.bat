
reg load HKLM\LUA "C:\Documents and
Settings\medivistalua\ntuser.dat"
	!Loads LUA Hive
reg import D:\luaproxy.reg

reg unload HKLM\LUA
	!Unloads LUA Hive