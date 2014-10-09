del *.dcu
del *.exe
del *.local
del *.vlb
del *.identcache
;del win32\debug\*.dcu
;del win32\debug\*.exe
:del win32\release\*.dcu
;del win32\release\*.exe
rd win32 /q /s
rd win64 /q /s
rd __history /q /s