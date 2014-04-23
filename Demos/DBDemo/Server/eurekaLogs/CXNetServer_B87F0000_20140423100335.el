EurekaLog 7.0.6.27 RC 5  

Exception:
---------------------------------------------
  2.2 Address: 005596B8
  2.5 Type   : EOleException
  2.6 Message: ???¨®?? 'B_Materialxxx' ?TD¡ì?¡ê.
  2.7 ID     : B87F0000
  2.11 Sent  : 0

User:
--------------------------------
  3.2 Name : ymofen
  3.3 Email: example@example.com

Steps to reproduce:
------------
  8.1 Text: 


Call Stack Information:
-----------------------------------------------------------------------------------------------------------------------------------------
|Methods |Details|Stack   |Address |Module         |Offset  |Unit             |Class             |Procedure/Method            |Line     |
-----------------------------------------------------------------------------------------------------------------------------------------
|*Exception Thread: ID=6960; Parent=4012; Priority=0                                                                                    |
|Class=TIOCPWorker; Name= (uIOCPWorker.TIOCPWorker.Execute)                                                                             |
|DeadLock=0; Wait Chain=                                                                                                                |
|Comment=                                                                                                                               |
|---------------------------------------------------------------------------------------------------------------------------------------|
|7FFFFFFE|03     |00000000|005596B8|CXNetServer.exe|001596B8|ADODB            |TCustomADODataSet |OpenCursor                  |         |
|00000020|03     |0653FBD0|0052E42D|CXNetServer.exe|0012E42D|DB               |TDataSet          |SetActive                   |         |
|00000020|03     |0653FBEC|0052E225|CXNetServer.exe|0012E225|DB               |TDataSet          |Open                        |         |
|00000020|04     |0653FBF4|005A14C2|CXNetServer.exe|001A14C2|uCDSProvider     |TCDSProvider      |QueryXMLData                |117[15]  |
|00000020|04     |0653FCE8|005C2A67|CXNetServer.exe|001C2A67|uClientContext   |TClientContext    |openSQLScriptEx             |498[56]  |
|00000020|04     |0653FDD8|005C1CD8|CXNetServer.exe|001C1CD8|uClientContext   |TClientContext    |dataReceived                |100[27]  |
|00000020|04     |0653FDF8|0059DF48|CXNetServer.exe|0019DF48|uIOCPCentre      |TIOCPClientContext|RecvBuffer                  |1129[22] |
|00000020|04     |0653FE3C|0059D549|CXNetServer.exe|0019D549|uIOCPCentre      |TIOCPObject       |processIOQueued             |736[85]  |
|00000020|04     |0653FEA0|0059F314|CXNetServer.exe|0019F314|uIOCPWorker      |TIOCPWorker       |Execute                     |34[7]    |
|00000020|03     |0653FEEC|00441A58|CXNetServer.exe|00041A58|Classes          |                  |ThreadProc                  |         |
|00000020|03     |0653FF1C|004056EC|CXNetServer.exe|000056EC|System           |                  |ThreadWrapper               |         |
|00000020|04     |0653FF30|004FE092|CXNetServer.exe|000FE092|EExceptionManager|                  |DefaultThreadHandleException|2852[5]  |
|00000020|04     |0653FF78|0048770B|CXNetServer.exe|0008770B|EThreadsManager  |                  |ThreadWrapper               |611[11]  |
|00000020|03     |0653FF8C|75C13388|kernel32.dll   |00013388|kernel32         |                  |BaseThreadInitThunk         |         |
|7FFFFFFE|04     |00000000|0059F87A|CXNetServer.exe|0019F87A|uIOCPConsole     |TIOCPConsole      |startWorkers                |207[10]  |
-----------------------------------------------------------------------------------------------------------------------------------------

Modules Information:
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|Handle  |Name                |Description                                     |Version           |Size    |Modified           |Path                                                                                                          |
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|00400000|CXNetServer.exe     |                                                |                  |2281984 |2014-04-23 10:03:08|E:\?????DD?\PluginFrame\Source\Tools\DIOCP\Demos\DBDemo\Server\                                               |
|4DAE0000|midas.dll           |Embarcadero MIDAS Component Package             |19.0.13476.4176   |451960  |2013-09-10 06:55:00|F:\Delphi XE5\bin\                                                                                            |
|6C590000|msadce.dll          |OLE DB Cursor Engine                            |6.1.7601.17514    |561152  |2010-11-21 11:24:15|C:\Program Files (x86)\Common Files\System\msadc\                                                             |
|6C620000|schannel.dll        |TLS / SSL Security Provider                     |6.1.7601.18270    |247808  |2013-09-25 09:57:24|C:\Windows\SysWOW64\                                                                                          |
|6C660000|sqloledb.dll        |OLE DB Provider for SQL Server                  |6.1.7601.17514    |921600  |2010-11-21 11:24:28|C:\Program Files (x86)\Common Files\System\Ole DB\                                                            |
|6C750000|comsvcs.dll         |COM+ Services                                   |2001.12.8530.16385|1242112 |2009-07-14 09:15:07|C:\Windows\System32\                                                                                          |
|6CCF0000|oledb32.dll         |OLE DB Core Services                            |6.1.7601.17514    |864256  |2010-11-21 11:24:02|C:\Program Files (x86)\Common Files\System\Ole DB\                                                            |
|6CFE0000|cryptdll.dll        |Cryptography Manager                            |6.1.7600.16385    |58880   |2009-07-14 09:15:07|C:\Windows\System32\                                                                                          |
|6D000000|msv1_0.dll          |Microsoft Authentication Package v1.0           |6.1.7601.17514    |257024  |2010-11-21 11:24:16|C:\Windows\SysWOW64\                                                                                          |
|6D050000|msado15.dll         |ActiveX Data Objects                            |6.1.7601.17857    |1019904 |2012-06-06 13:05:32|C:\Program Files (x86)\Common Files\System\ado\                                                               |
|6D470000|msadcer.dll         |OLE DB Cursor Engine Resources                  |6.1.7600.16385    |8192    |2009-07-14 09:06:52|C:\Program Files (x86)\Common Files\System\msadc\                                                             |
|6D480000|dbnetlib.dll        |Winsock Oriented Net DLL for SQL Clients        |6.1.7600.16385    |135168  |2009-07-14 09:15:09|C:\Windows\System32\                                                                                          |
|6D4B0000|msdatl3.dll         |OLE DB Implementation Support Routines          |6.1.7600.16385    |98304   |2009-07-14 09:15:43|C:\Program Files (x86)\Common Files\System\Ole DB\                                                            |
|6D4D0000|atl.dll             |ATL Module for Windows XP (Unicode)             |3.5.2284.0        |70144   |2009-07-14 09:14:57|C:\Windows\System32\                                                                                          |
|6D4F0000|oledb32r.dll        |OLE DB o?D?¡¤t??¡Á¨º?¡ä                             |6.1.7600.16385    |81920   |2009-07-14 09:09:16|C:\Program Files (x86)\Common Files\System\Ole DB\                                                            |
|6D750000|security.dll        |Security Support Provider Interface             |6.1.7600.16385    |4608    |2009-07-14 09:09:53|C:\Windows\System32\                                                                                          |
|6D7E0000|msdart.dll          |OLE DB Runtime Routines                         |6.1.7600.16385    |126976  |2009-07-14 09:15:43|C:\Windows\System32\                                                                                          |
|6E540000|ntdsapi.dll         |Active Directory Domain Services API            |6.1.7600.16385    |90112   |2009-07-14 09:16:11|C:\Windows\System32\                                                                                          |
|6E7F0000|sqloledb.rll        |SQL Server ¡Á¨º?¡ä¦Ì? OLE DB ¨¬¨¢1?3¨¬D¨°               |6.1.7600.16385    |16384   |2009-07-14 08:12:12|C:\Program Files (x86)\Common Files\System\Ole DB\                                                            |
|700D0000|adsPop32.dll        |ADSafe 32 Bit Pop Windows Block Library         |3.1.0.0           |132920  |2013-11-19 18:21:22|C:\Program Files (x86)\ADSafe3\                                                                               |
|70220000|dwmapi.dll          |Microsoft Desktop Window Manager API            |6.1.7600.16385    |67072   |2009-07-14 09:15:13|C:\Windows\System32\                                                                                          |
|70250000|adsNet32.dll        |ADSafe 32 Bit Net Hook Library                  |3.2.1.403         |107872  |2014-04-03 18:00:58|C:\Program Files (x86)\ADSafe3\                                                                               |
|70460000|uxtheme.dll         |Microsoft UxTheme ?a                            |6.1.7600.16385    |245760  |2009-07-14 09:11:24|C:\Windows\System32\                                                                                          |
|70920000|wsock32.dll         |Windows Socket 32-Bit DLL                       |6.1.7600.16385    |15360   |2009-07-14 09:16:20|C:\Windows\System32\                                                                                          |
|72100000|bcryptprimitives.dll|Windows Cryptographic Primitives Library        |6.1.7600.16385    |249680  |2009-07-14 09:17:54|C:\Windows\SysWOW64\                                                                                          |
|72140000|bcrypt.dll          |Windows Cryptographic Primitives Library (Wow64)|6.1.7600.16385    |80896   |2009-07-14 09:11:20|C:\Windows\System32\                                                                                          |
|72160000|ncrypt.dll          |Windows ?¨®?¨¹?a                                  |6.1.7601.18270    |220160  |2013-09-25 09:56:42|C:\Windows\System32\                                                                                          |
|721A0000|rsaenh.dll          |Microsoft Enhanced Cryptographic Provider       |6.1.7600.16385    |242936  |2009-07-14 09:17:54|C:\Windows\System32\                                                                                          |
|721E0000|cryptsp.dll         |Cryptographic Service Provider API              |6.1.7600.16385    |78848   |2009-07-14 09:15:07|C:\Windows\System32\                                                                                          |
|728F0000|WSHTCPIP.DLL        |Winsock2 ¡ã??¨²3¨¬D¨° DLL (TL/IPv4)                 |6.1.7600.16385    |9216    |2009-07-14 09:16:20|C:\Windows\System32\                                                                                          |
|72950000|credssp.dll         |Credential Delegation Security Package          |6.1.7601.17514    |17408   |2010-11-21 11:24:33|C:\Windows\System32\                                                                                          |
|72960000|gamelsp.dll         |GameLSP Sockets 2.0 Service Provider            |6.0.4.93          |110464  |2013-10-29 21:02:55|C:\Windows\System32\                                                                                          |
|72B30000|comctl32.dll        |¨®??¡ì¨¬??¨¦???t?a                                  |6.10.7601.17514   |1680896 |2010-11-21 11:23:55|C:\Windows\winsxs\x86_microsoft.windows.common-controls_6595b64144ccf1df_6.0.7601.17514_none_41e6975e2bd6f2b2\|
|72D20000|mswsock.dll         |Microsoft Windows Sockets 2.0 ¡¤t??¨¬¨¢1?3¨¬D¨°      |6.1.7601.18254    |231424  |2013-09-08 10:03:58|c:\Windows\System32\                                                                                          |
|72F10000|secur32.dll         |Security Support Provider Interface             |6.1.7601.18270    |22016   |2013-09-25 09:57:26|C:\Windows\System32\                                                                                          |
|72FF0000|RpcRtRemote.dll     |Remote RPC Extension                            |6.1.7601.17514    |46080   |2010-11-21 11:24:14|C:\Windows\System32\                                                                                          |
|734E0000|safemon.dll         |360¡ã2¨¨??¨¤¨º? ¨ª??¨¹¡¤¨¤?¡è?¡ê?¨¦                        |8.4.0.1270        |1579592 |2014-04-01 11:29:48|C:\Program Files (x86)\360\360safe\safemon\                                                                   |
|74800000|winnsi.dll          |Network Store Information RPC interface         |6.1.7600.16385    |16896   |2009-07-14 09:16:19|C:\Windows\System32\                                                                                          |
|74810000|IPHLPAPI.DLL        |IP Helper API                                   |6.1.7601.17514    |103936  |2010-11-21 11:24:32|C:\Windows\System32\                                                                                          |
|748B0000|wkscli.dll          |Workstation Service Client DLL                  |6.1.7601.17514    |47104   |2010-11-21 11:23:51|C:\Windows\System32\                                                                                          |
|748C0000|srvcli.dll          |Server Service Client DLL                       |6.1.7601.17514    |90112   |2010-11-21 11:24:16|C:\Windows\System32\                                                                                          |
|748E0000|netutils.dll        |Net Win32 API Helpers DLL                       |6.1.7601.17514    |22528   |2010-11-21 11:24:16|C:\Windows\System32\                                                                                          |
|748F0000|netapi32.dll        |Net Win32 API DLL                               |6.1.7601.17887    |57344   |2013-04-28 18:55:39|C:\Windows\System32\                                                                                          |
|74A30000|version.dll         |Version Checking and File Installation Libraries|6.1.7600.16385    |21504   |2009-07-14 09:16:17|C:\Windows\System32\                                                                                          |
|74B10000|CRYPTBASE.dll       |Base cryptographic API DLL                      |6.1.7600.16385    |36864   |2009-07-14 09:15:07|C:\Windows\SysWOW64\                                                                                          |
|74B20000|sspicli.dll         |Security Support Provider Interface             |6.1.7601.18270    |96768   |2013-09-25 09:58:17|C:\Windows\SysWOW64\                                                                                          |
|74B80000|msctf.dll           |MSCTF ¡¤t???¡Â DLL                                |6.1.7600.16385    |828928  |2009-07-14 09:15:43|C:\Windows\SysWOW64\                                                                                          |
|74C50000|imm32.dll           |Multi-User Windows IMM32 API Client DLL         |6.1.7601.17514    |119808  |2010-11-21 11:24:25|C:\Windows\System32\                                                                                          |
|74CB0000|ole32.dll           |¨®?¨®¨² Windows ¦Ì? Microsoft OLE                   |6.1.7601.17514    |1414144 |2010-11-21 11:24:01|C:\Windows\SysWOW64\                                                                                          |
|74E70000|gdi32.dll           |GDI Client DLL                                  |6.1.7601.18275    |311808  |2013-10-03 10:00:44|C:\Windows\SysWOW64\                                                                                          |
|74F00000|shell32.dll         |Windows ¨ªa??1?¨®? DLL                            |6.1.7601.18222    |12872704|2013-07-26 09:55:59|C:\Windows\SysWOW64\                                                                                          |
|75BE0000|psapi.dll           |Process Status Helper                           |6.1.7600.16385    |6144    |2009-07-14 09:16:12|C:\Windows\SysWOW64\                                                                                          |
|75C00000|kernel32.dll        |Windows NT ?¨´¡À? API ?¨ª?¡ì?? DLL                  |6.1.7601.18409    |1114112 |2014-03-04 17:16:17|C:\Windows\SysWOW64\                                                                                          |
|75D10000|clbcatq.dll         |COM+ Configuration Catalog                      |2001.12.8530.16385|522240  |2009-07-14 09:15:03|C:\Windows\SysWOW64\                                                                                          |
|75DB0000|shlwapi.dll         |¨ªa???¨°¨°¡Á¨º¦Ì¨®?1¡è???a                              |6.1.7601.17514    |350208  |2010-11-21 11:23:48|C:\Windows\SysWOW64\                                                                                          |
|75F40000|advapi32.dll        |???? Windows 32 ?¨´¡À? API                        |6.1.7601.18247    |640512  |2013-08-29 09:48:17|C:\Windows\SysWOW64\                                                                                          |
|76010000|imagehlp.dll        |Windows NT Image Helper                         |6.1.7601.18288    |159232  |2013-10-19 09:36:59|C:\Windows\SysWOW64\                                                                                          |
|76250000|rpcrt4.dll          |??3¨¬1y3¨¬¦Ì¡Â¨®???DD¨º¡À                              |6.1.7601.18205    |663552  |2013-08-14 08:24:44|C:\Windows\SysWOW64\                                                                                          |
|76390000|msasn1.dll          |ASN.1 Runtime APIs                              |6.1.7601.17514    |34304   |2010-11-21 11:23:48|C:\Windows\SysWOW64\                                                                                          |
|763A0000|crypt32.dll         |?¨®?¨¹ API32                                      |6.1.7601.18277    |1168384 |2013-10-06 03:57:25|C:\Windows\SysWOW64\                                                                                          |
|764C0000|usp10.dll           |Uniscribe Unicode script processor              |1.626.7601.18009  |626688  |2012-11-22 12:45:03|C:\Windows\SysWOW64\                                                                                          |
|76560000|msvcrt.dll          |Windows NT CRT DLL                              |7.0.7601.17744    |690688  |2011-12-16 15:52:58|C:\Windows\SysWOW64\                                                                                          |
|76610000|nsi.dll             |NSI User-mode interface DLL                     |6.1.7600.16385    |8704    |2009-07-14 09:16:11|C:\Windows\SysWOW64\                                                                                          |
|76630000|KERNELBASE.dll      |Windows NT ?¨´¡À? API ?¨ª?¡ì?? DLL                  |6.1.7601.18229    |274944  |2013-08-02 09:50:42|C:\Windows\SysWOW64\                                                                                          |
|76680000|oleaut32.dll        |                                                |6.1.7601.17676    |571904  |2013-04-28 18:36:38|C:\Windows\SysWOW64\                                                                                          |
|76930000|sechost.dll         |Host for SCM/SDDL/LSA Lookup APIs               |6.1.7600.16385    |92160   |2009-07-14 09:16:13|C:\Windows\SysWOW64\                                                                                          |
|76950000|user32.dll          |?¨¤¨®??¡ì Windows ¨®??¡ì API ?¨ª?¡ì?? DLL              |6.1.7601.17514    |833024  |2010-11-21 11:24:20|C:\Windows\SysWOW64\                                                                                          |
|76C20000|ws2_32.dll          |Windows Socket 2.0 32 ?? DLL                    |6.1.7601.17514    |206848  |2010-11-21 11:23:55|C:\Windows\SysWOW64\                                                                                          |
|770C0000|lpk.dll             |Language Pack                                   |6.1.7601.18177    |25600   |2013-06-06 12:57:01|C:\Windows\SysWOW64\                                                                                          |
|770F0000|ntdll.dll           |NT 2? DLL                                       |6.1.7601.18247    |1292192 |2013-08-29 09:50:30|C:\Windows\SysWOW64\                                                                                          |
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Processes Information:
----------------------


Assembler Information:
------------------------------------------------------------------------
; Base Address: $559000, Allocation Base: $400000, Region Size: 458752
; Allocation Protect: PAGE_EXECUTE_WRITECOPY, Protect: PAGE_EXECUTE_READ
; State: MEM_COMMIT, Type: MEM_IMAGE
; 
;
; ADODB.TCustomADODataSet.OpenCursor (Line=0 - Offset=158)
; --------------------------------------------------------
005596AA  D88B45FC8B80  FMUL DWORD PTR [EBX-$7F7403BB]
005596B0  800100        ADD  BYTE PTR [ECX], 0
005596B3  00508B        ADD  [EAX-$75], DL
005596B6  00FF          ADD  BH, BH
;
; Line=0 - Offset=172
; -------------------
005596B8  90            NOP                             ; <-- EXCEPTION
005596B9  A0000000E8    MOV  AL, [$E8000000]

Registers:
-----------------------------
EAX: 0653FA84   EDI: 00000001
EBX: 00000000   ESI: 0EEDFADE
ECX: 00000007   EBP: 0653FAD4
EDX: 00000000   ESP: 0653FA84
EIP: 7663C41F   FLG: 00000216
EXP: 005596B8   STK: 0653FB68

Stack:               Memory Dump:
------------------   ---------------------------------------------------------------------------
0653FBA4: 00000000   005596B8: 90 A0 00 00 00 E8 CA E3 EA FF E9 8F 00 00 00 33  ...............3
0653FBA0: 00000000   005596C8: C0 55 68 29 97 55 00 64 FF 30 64 89 20 8D 45 C4  .Uh).U.d.0d. .E.
0653FB9C: 00000000   005596D8: E8 9F E2 EA FF 50 8D 45 C8 E8 AE 13 ED FF 50 8B  .....P.E......P.
0653FB98: 00000000   005596E8: 45 FC 8B 80 80 01 00 00 50 8B 00 FF 90 F4 00 00  E.......P.......
0653FB94: 00000000   005596F8: 00 E8 8E E3 EA FF 8B 55 C4 8B 45 FC 05 80 01 00  .......U..E.....
0653FB90: 00000000   00559708: 00 E8 86 E2 EA FF 8B 45 FC 83 B8 80 01 00 00 00  .......E........
0653FB8C: 00000000   00559718: 75 05 E8 45 D0 EC FF 33 C0 5A 59 59 64 89 10 EB  u..E...3.ZYYd...
0653FB88: 00000000   00559728: 2D E9 4A B5 EA FF 8D 55 BC A1 14 33 5E 00 E8 D5  -.J....U...3^...
0653FB84: 00000000   00559738: E7 EA FF 8B 55 BC 8D 45 C0 E8 26 CA EA FF 8B 45  ....U..E..&....E
0653FB80: 00000101   00559748: C0 8B 55 FC E8 33 78 FC FF E8 F6 B9 EA FF 8D 45  ..U..3x........E
0653FB7C: 03BC3460   00559758: B8 50 8B 45 FC 8B 80 80 01 00 00 50 8B 00 FF 90  .P.E.......P....
0653FB78: 020C1630   00559768: DC 00 00 00 E8 1B E3 EA FF 83 7D B8 00 0F 84 4C  ..........}....L
0653FB74: 0653FBCC   00559778: FF FF FF EB 08 8B 45 FC E8 4B 4A 00 00 8B 45 FC  ......E..KJ...E.
0653FB70: 00404FAC   00559788: E8 63 58 00 00 A8 01 74 2B 8D 45 B8 50 8B 45 FC  .cX....t+.E.P.E.
0653FB6C: 0653FBD4   00559798: 8B 80 80 01 00 00 50 8B 00 FF 90 DC 00 00 00 E8  ......P.........
0653FB68: 005596C2   005597A8: E0 E2 EA FF F6 45 B8 04 74 0A B2 0C 8B 45 FC E8  .....E..t....E..



