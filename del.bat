del *.dcu
del *.exe
del *.local
;del *.identcache
;del win32\debug\*.dcu
;del win32\debug\*.exe
:del win32\release\*.dcu
;del win32\release\*.exe
rd win32 /q /s
rd __history /q /s