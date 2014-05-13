EurekaLog 7.0.6.27 RC 5  

Exception:
------------------------------------------------------------------------------------------------------------
  2.2 Address: 00405804
  2.5 Type   : EInvalidPointer
  2.6 Message: Application made attempt to free invalid or unknown memory block: $06E18F50 DATA [?] 0 bytes.
  2.7 ID     : 57730000
  2.11 Sent  : 0

User:
----------------
  3.2 Name : 123
  3.3 Email: 

Steps to reproduce:
------------
  8.1 Text: 


Call Stack Information:
-----------------------------------------------------------------------------------------------------------------------------------------
|Methods |Details|Stack   |Address |Module         |Offset  |Unit             |Class             |Procedure/Method            |Line     |
-----------------------------------------------------------------------------------------------------------------------------------------
|*Exception Thread: ID=5468; Parent=2740; Priority=0                                                                                    |
|Class=TIOCPWorker; Name= (uIOCPWorker.TIOCPWorker.Execute)                                                                             |
|DeadLock=0; Wait Chain=?¨°2?¦Ì????¡§¦Ì?3¨¬D¨°?¡ê                                                                                              |
|Comment=                                                                                                                               |
|---------------------------------------------------------------------------------------------------------------------------------------|
|7FFFFFFE|03     |00000000|00405804|CXNetServer.exe|00005804|System           |                  |_LStrAsg                    |         |
|00000020|04     |0462FE70|0059E5FE|CXNetServer.exe|0019E5FE|uIOCPCentre      |TIOCPClientContext|checkPostWSASendCache       |1095[47] |
|00000020|04     |0462FE90|0059DF50|CXNetServer.exe|0019DF50|uIOCPCentre      |TIOCPObject       |processIOQueued             |818[129] |
|00000020|04     |0462FED0|0059FAAC|CXNetServer.exe|0019FAAC|uIOCPWorker      |TIOCPWorker       |Execute                     |34[7]    |
|00000020|03     |0462FF1C|00441A58|CXNetServer.exe|00041A58|Classes          |                  |ThreadProc                  |         |
|00000020|03     |0462FF4C|004056EC|CXNetServer.exe|000056EC|System           |                  |ThreadWrapper               |         |
|00000020|04     |0462FF60|004FE092|CXNetServer.exe|000FE092|EExceptionManager|                  |DefaultThreadHandleException|2852[5]  |
|00000020|04     |0462FFA8|0048770B|CXNetServer.exe|0008770B|EThreadsManager  |                  |ThreadWrapper               |611[11]  |
-----------------------------------------------------------------------------------------------------------------------------------------

Modules Information:
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|Handle  |Name           |Description                                                     |Version          |Size   |Modified           |Path                                                                                                 |
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|00400000|CXNetServer.exe|                                                                |                 |2283520|2014-04-09 10:31:57|E:\¨°¡Á¡¤?¨¨¨ª?t\CXNetServer\                                                                             |
|00D50000|CDSOperator.dll|                                                                |                 |915456 |2014-02-14 15:57:17|E:\¨°¡Á¡¤?¨¨¨ª?t\CXNetServer\Libs\                                                                        |
|05950000|xpsp2res.dll   |Service Pack 2 Messages                                         |5.2.3790.3959    |5535744|2007-02-17 06:44:18|C:\WINDOWS\system32\                                                                                 |
|06720000|msadcer.dll    |Microsoft Data Access - OLE DB Cursor Engine Resources          |2.82.3959.0      |12288  |2007-02-17 06:58:04|C:\Program Files\Common Files\System\msadc\                                                          |
|06FB0000|sqloledb.rll   |Microsoft OLE DB Provider for SQL Server                        |2000.86.3959.0   |53248  |2007-02-17 06:57:00|C:\Program Files\Common Files\System\Ole DB\                                                         |
|1B5D0000|mswstr10.dll   |Microsoft Jet Sort Library                                      |4.0.9502.0       |621344 |2007-02-17 06:58:30|C:\WINDOWS\system32\                                                                                 |
|4A170000|comsvcs.dll    |COM+ Services                                                   |2001.12.4720.3959|1295872|2007-02-17 06:42:28|C:\WINDOWS\system32\                                                                                 |
|4B430000|msado15.dll    |Microsoft Data Access - ActiveX Data Objects                    |2.82.5011.0      |598016 |2012-05-28 16:27:53|C:\Program Files\Common Files\System\ado\                                                            |
|4BB20000|oledb32.dll    |Microsoft Data Access - OLE DB Core Services                    |2.82.3959.0      |491520 |2007-02-17 06:43:42|C:\Program Files\Common Files\System\Ole DB\                                                         |
|4BFF0000|msadce.dll     |Microsoft Data Access - OLE DB Cursor Engine                    |2.82.3959.0      |356352 |2007-02-17 06:43:24|C:\Program Files\Common Files\System\msadc\                                                          |
|4C470000|oledb32r.dll   |Microsoft Data Access - OLE DB Core Services Resources          |2.82.3959.0      |40960  |2007-02-17 06:55:36|C:\Program Files\Common Files\System\Ole DB\                                                         |
|4C510000|MSCTFIME.IME   |Microsoft Text Frame Work Service IME                           |5.2.3790.3959    |177152 |2007-02-17 06:43:24|C:\WINDOWS\system32\                                                                                 |
|4C9D0000|sqloledb.dll   |Microsoft OLE DB Provider for SQL Server                        |2000.86.3959.0   |528384 |2007-02-17 06:44:18|C:\Program Files\Common Files\System\Ole DB\                                                         |
|4DAE0000|midas.dll      |Borland MIDAS Component Package                                 |7.0.4.453        |296448 |2011-04-06 10:46:11|E:\¨°¡Á¡¤?¨¨¨ª?t\??¡Á¡ã\2¨¦D¨´??¡Á¡ã?¨ª?¡ì??\                                                                     |
|61540000|msdatl3.dll    |Microsoft Data Access - OLE DB Implementation Support Routines  |2.82.3959.0      |86016  |2007-02-17 06:43:26|C:\Program Files\Common Files\System\Ole DB\                                                         |
|68000000|rsaenh.dll     |Microsoft Enhanced Cryptographic Provider                       |5.2.3790.3959    |213336 |2007-02-17 23:19:44|C:\WINDOWS\system32\                                                                                 |
|68100000|dssenh.dll     |Microsoft Enhanced DSS and Diffie-Hellman Cryptographic Provider|5.2.3790.3959    |147288 |2007-02-17 23:19:44|C:\WINDOWS\system32\                                                                                 |
|69660000|hnetcfg.dll    |Home Networking Configuration Manager                           |5.2.3790.3959    |345088 |2007-02-17 07:00:36|C:\WINDOWS\system32\                                                                                 |
|6D810000|dbnetlib.dll   |Winsock Oriented Net DLL for SQL Clients                        |2000.86.3959.0   |114688 |2007-02-17 06:42:30|C:\WINDOWS\system32\                                                                                 |
|70200000|safemon.dll    |360¡ã2¨¨??¨¤¨º? ¨ª??¨¹¡¤¨¤?¡è?¡ê?¨¦                                        |8.4.0.1270       |1579592|2014-04-01 11:29:48|D:\Program Files\360\360Safe\safemon\                                                                |
|71A40000|wshtcpip.dll   |Windows Sockets Helper DLL                                      |5.2.3790.3959    |18944  |2007-02-17 06:44:46|C:\WINDOWS\system32\                                                                                 |
|71A80000|mswsock.dll    |Microsoft Windows Sockets 2.0 Service Provider                  |5.2.3790.4318    |251392 |2008-06-21 02:20:04|C:\WINDOWS\system32\                                                                                 |
|71AD0000|uxtheme.dll    |Microsoft UxTheme Library                                       |6.0.3790.3959    |204800 |2007-02-17 06:54:22|C:\WINDOWS\system32\                                                                                 |
|71B10000|wsock32.dll    |Windows Socket 32-Bit DLL                                       |5.2.3790.0       |28672  |2003-03-27 12:00:00|C:\WINDOWS\system32\                                                                                 |
|71B50000|ws2help.dll    |Windows Socket 2.0 Helper for Windows NT                        |5.2.3790.3959    |19456  |2007-02-17 06:55:06|C:\WINDOWS\system32\                                                                                 |
|71B60000|ws2_32.dll     |Windows Socket 2.0 32-Bit DLL                                   |5.2.3790.3959    |83456  |2007-02-17 06:44:46|C:\WINDOWS\system32\                                                                                 |
|71B80000|tsappcmp.dll   |Terminal Services Application Compatibility DLL                 |5.2.3790.3959    |58880  |2007-02-17 06:44:20|C:\WINDOWS\system32\                                                                                 |
|71BA0000|netapi32.dll   |Net Win32 API DLL                                               |5.2.3790.5030    |345600 |2012-06-30 00:13:55|C:\WINDOWS\system32\                                                                                 |
|71E90000|security.dll   |Security Support Provider Interface                             |5.2.3790.0       |5632   |2003-03-27 12:00:00|C:\WINDOWS\system32\                                                                                 |
|74430000|MSCTF.dll      |MSCTF Server DLL                                                |5.2.3790.3959    |315392 |2007-02-17 06:58:06|C:\WINDOWS\system32\                                                                                 |
|74480000|mlang.dll      |Multi Language Support DLL                                      |6.0.3790.3959    |589824 |2007-02-17 06:43:16|C:\WINDOWS\system32\                                                                                 |
|74990000|msdart.dll     |Microsoft Data Access - OLE DB Runtime Routines                 |2.82.3959.0      |106496 |2007-02-17 06:43:26|C:\WINDOWS\system32\                                                                                 |
|74AE0000|usp10.dll      |Uniscribe Unicode script processor                              |1.422.3790.5194  |379904 |2013-07-10 18:05:49|C:\WINDOWS\system32\                                                                                 |
|75870000|userenv.dll    |Userenv                                                         |5.2.3790.3959    |760320 |2007-02-17 06:54:22|C:\WINDOWS\system32\                                                                                 |
|75D60000|apphelp.dll    |Application Compatibility Client Library                        |5.2.3790.3959    |148992 |2007-02-17 06:58:58|C:\WINDOWS\system32\                                                                                 |
|76080000|msasn1.dll     |ASN.1 Runtime APIs                                              |5.2.3790.4584    |58880  |2009-09-05 05:27:59|C:\WINDOWS\system32\                                                                                 |
|760A0000|crypt32.dll    |Crypto API32                                                    |5.131.3790.5235  |591872 |2013-10-07 19:04:15|C:\WINDOWS\system32\                                                                                 |
|76180000|imm32.dll      |Windows IMM32 API Client DLL                                    |5.2.3790.3959    |110592 |2007-02-17 06:43:02|C:\WINDOWS\system32\                                                                                 |
|76620000|cryptdll.dll   |Cryptography Manager                                            |5.2.3790.3959    |33280  |2007-02-17 06:42:30|C:\WINDOWS\system32\                                                                                 |
|76630000|ntdsapi.dll    |NT5DS                                                           |5.2.3790.3959    |71680  |2007-02-17 06:43:36|C:\WINDOWS\system32\                                                                                 |
|76690000|schannel.dll   |TLS / SSL Security Provider                                     |5.2.3790.5014    |153088 |2012-06-04 16:58:45|C:\WINDOWS\system32\                                                                                 |
|76AB0000|psapi.dll      |Process Status Helper                                           |5.2.3790.3959    |20480  |2007-02-17 06:43:52|C:\WINDOWS\system32\                                                                                 |
|76B70000|imagehlp.dll   |Windows NT Image Helper                                         |5.2.3790.5240    |154112 |2013-10-19 11:37:39|C:\WINDOWS\system32\                                                                                 |
|76BF0000|msv1_0.dll     |Microsoft Authentication Package v1.0                           |5.2.3790.4587    |146432 |2009-09-11 18:41:36|C:\WINDOWS\system32\                                                                                 |
|76C50000|iphlpapi.dll   |IP Helper API                                                   |5.2.3790.3959    |94720  |2007-02-17 06:57:26|C:\WINDOWS\system32\                                                                                 |
|76E30000|dnsapi.dll     |DNS Client API DLL                                              |5.2.3790.4318    |162304 |2008-06-21 02:20:04|C:\WINDOWS\system32\                                                                                 |
|76E70000|wldap32.dll    |Win32 LDAP API DLL                                              |5.2.3790.3959    |178176 |2007-02-17 06:54:54|C:\WINDOWS\system32\                                                                                 |
|76EB0000|secur32.dll    |Security Support Provider Interface                             |5.2.3790.3959    |65024  |2007-02-17 06:43:54|C:\WINDOWS\system32\                                                                                 |
|76F70000|comres.dll     |COM+ Resources                                                  |2001.12.4720.3959|1401856|2007-02-17 06:59:46|C:\WINDOWS\system32\                                                                                 |
|774B0000|ole32.dll      |Microsoft OLE for Windows                                       |5.2.3790.5209    |1270272|2013-08-05 21:34:40|C:\WINDOWS\system32\                                                                                 |
|775F0000|oleaut32.dll   |                                                                |5.2.3790.4807    |553984 |2010-12-21 02:57:29|C:\WINDOWS\system32\                                                                                 |
|77680000|clbcatq.dll    |COM+ Configuration Catalog                                      |2001.12.4720.3959|510976 |2007-02-17 06:42:26|C:\WINDOWS\system32\                                                                                 |
|77B60000|version.dll    |Version Checking and File Installation Libraries                |5.2.3790.3959    |18432  |2007-02-17 06:44:22|C:\WINDOWS\system32\                                                                                 |
|77B70000|msvcrt.dll     |Windows NT CRT DLL                                              |7.0.3790.3959    |348672 |2007-02-17 06:43:34|C:\WINDOWS\system32\                                                                                 |
|77BD0000|gdi32.dll      |GDI Client DLL                                                  |5.2.3790.5236    |285696 |2013-10-09 21:15:16|C:\WINDOWS\system32\                                                                                 |
|77C20000|rpcrt4.dll     |Remote Procedure Call Runtime                                   |5.2.3790.5254    |648192 |2013-11-07 13:38:01|C:\WINDOWS\system32\                                                                                 |
|77CD0000|comctl32.dll   |User Experience Controls Library                                |6.0.3790.4770    |1051648|2010-09-07 20:00:57|C:\WINDOWS\WinSxS\x86_Microsoft.Windows.Common-Controls_6595b64144ccf1df_6.0.3790.4770_x-ww_05FDF087\|
|77E10000|user32.dll     |Windows USER API Client DLL                                     |5.2.3790.3959    |579072 |2007-02-17 06:54:20|C:\WINDOWS\system32\                                                                                 |
|77EB0000|shlwapi.dll    |Shell Light-weight Utility Library                              |6.0.3790.4603    |318976 |2009-10-16 04:19:43|C:\WINDOWS\system32\                                                                                 |
|77F30000|advapi32.dll   |Advanced Windows 32 Base API                                    |5.2.3790.3959    |685056 |2007-02-17 06:58:56|C:\WINDOWS\system32\                                                                                 |
|7C800000|kernel32.dll   |Windows NT BASE API Client DLL                                  |5.2.3790.5069    |1205248|2012-10-03 15:26:24|C:\WINDOWS\system32\                                                                                 |
|7C930000|ntdll.dll      |NT Layer DLL                                                    |5.2.3790.4937    |843264 |2011-11-23 00:28:30|C:\WINDOWS\system32\                                                                                 |
|7CA10000|shell32.dll    |Windows Shell Common Dll                                        |6.0.3790.5018    |8220672|2012-06-08 23:55:05|C:\WINDOWS\system32\                                                                                 |
|7F000000|lpk.dll        |Language Pack                                                   |5.2.3790.3959    |22016  |2007-02-17 06:43:10|C:\WINDOWS\system32\                                                                                 |
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Processes Information:
----------------------


Assembler Information:
----------------------------------------------------------------------------------------------------
; Base Address: $405000, Allocation Base: $400000, Region Size: 1855488
; Allocation Protect: PAGE_EXECUTE_WRITECOPY, Protect: PAGE_EXECUTE_READ
; State: MEM_COMMIT, Type: MEM_IMAGE
; 
;
; System._LStrAsg (Line=0 - Offset=22)
; ------------------------------------
004057E2  58          POP  EAX
004057E3  52          PUSH EDX
004057E4  8B48FC      MOV  ECX, [EAX-4]
004057E7  E8F0DCFFFF  CALL -$2310            ; ($004034DC) System.Move
004057EC  5A          POP  EDX
004057ED  58          POP  EAX
004057EE  EB04        JMP  +4                ; ($004057F4) System._LStrAsg (Line=0)
004057F0  F0          DB   $F0               ; ???? unknown/invalid instruction
004057F1  FF42F8      INC  DWORD PTR [EDX-8]
004057F4  8710        XCHG EDX, [EAX]
004057F6  85D2        TEST EDX, EDX
004057F8  7414        JZ   +$14              ; ($0040580E) System._LStrAsg (Line=0)
004057FA  8B4AF8      MOV  ECX, [EDX-8]
004057FD  49          DEC  ECX
004057FE  7C0E        JL   +$0E              ; ($0040580E) System._LStrAsg (Line=0)
00405800  F0          DB   $F0               ; ???? unknown/invalid instruction
00405801  FF4AF8      DEC  DWORD PTR [EDX-8]
;
; Line=0 - Offset=56
; ------------------
00405804  7508        JNZ  +8                ; ($0040580E) System._LStrAsg (Line=0)  ; <-- EXCEPTION
00405806  8D42F8      LEA  EAX, [EDX-8]
00405809  E8F6D9FFFF  CALL -$260A            ; ($00403204) System._FreeMem

Registers:
-----------------------------
EAX: ????       EDI: ????    
EBX: ????       ESI: ????    
ECX: ????       EBP: ????    
EDX: ????       ESP: ????    
EIP: ????       FLG: ????    
EXP: 00405804   STK: 0462FE6C

Stack:               Memory Dump:
------------------   ---------------------------------------------------------------------------
0462FEA8: FFFFFFFF   00405804: 75 08 8D 42 F8 E8 F6 D9 FF FF C3 90 85 D2 74 0A  u..B..........t.
0462FEA4: 00000000   00405814: 8B 4A F8 41 7E 04 F0 FF 42 F8 87 10 85 D2 74 14  .J.A~...B.....t.
0462FEA0: 00000000   00405824: 8B 4A F8 49 7C 0E F0 FF 4A F8 75 08 8D 42 F8 E8  .J.I|...J.u..B..
0462FE9C: 0462FECC   00405834: CC D9 FF FF C3 8D 40 00 85 C0 7E 24 50 83 C0 0A  ......@...~$P...
0462FE98: 0059DF9B   00405844: 83 E0 FE 50 E8 9B D9 FF FF 5A 66 C7 44 02 FE 00  ...P.....Zf.D...
0462FE94: 0462FED4   00405854: 00 83 C0 08 5A 89 50 FC C7 40 F8 01 00 00 00 C3  ....Z.P..@......
0462FE90: 0059DF55   00405864: 31 C0 C3 90 53 56 57 89 C3 89 D6 89 CF 89 F8 E8  1...SVW.........
0462FE8C: 0462FECC   00405874: C4 FF FF FF 89 F9 89 C7 85 F6 74 09 89 C2 89 F0  ..........t.....
0462FE88: 00F5E680   00405884: E8 53 DC FF FF 89 D8 E8 E8 FE FF FF 89 3B 5F 5E  .S...........;_^
0462FE84: 01FFFFFF   00405894: 5B C3 8B C0 55 8B EC 6A 00 6A 00 52 50 8B 45 08  [...U..j.j.RP.E.
0462FE80: FFFFFFFF   004058A4: 50 51 6A 00 A1 C4 55 5E 00 50 E8 AD BB FF FF 5D  PQj...U^.P.....]
0462FE7C: 0462FE8C   004058B4: C2 04 00 90 55 8B EC 52 50 8B 45 08 50 51 6A 00  ....U..RP.E.PQj.
0462FE78: 0059E61C   004058C4: A1 C4 55 5E 00 50 E8 61 BB FF FF 5D C2 04 00 90  ..U^.P.a...]....
0462FE74: 0462FE94   004058D4: 53 56 57 55 81 C4 04 F0 FF FF 50 83 C4 FC 8B F1  SVWU......P.....
0462FE70: 0059E603   004058E4: 89 14 24 8B F8 85 F6 7F 09 8B C7 E8 84 FE FF FF  ..$.............
0462FE6C: 0040580E   004058F4: EB 5F 8D 6E 01 81 FD FF 07 00 00 7D 28 56 8D 44  ._.n.......}(V.D



