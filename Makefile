make: obshaga.lua

obshaga.lua : obshaga.utf
	iconv -t cp1251 obshaga.utf -o obshaga.lua
