EurekaLog 7.0.6.27 RC 5  

Exception:
----------------------------------------------------------------------------------------------------------------------
  2.2 Address: 00404713
  2.5 Type   : EInvalidPointer
  2.6 Message: Application made attempt to free invalid or unknown memory block: $070DDB40 DATA [TBufferLink] 0 bytes.
  2.7 ID     : 14380000
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
|*Exception Thread: ID=552; Parent=4236; Priority=0                                                                                     |
|Class=TIOCPWorker; Name= (uIOCPWorker.TIOCPWorker.Execute)                                                                             |
|DeadLock=0; Wait Chain=?¨°2?¦Ì????¡§¦Ì?3¨¬D¨°?¡ê                                                                                              |
|Comment=                                                                                                                               |
|---------------------------------------------------------------------------------------------------------------------------------------|
|7FFFFFFE|03     |00000000|00404713|CXNetServer.exe|00004713|System           |TObject           |FreeInstance                |         |
|00000020|03     |049CFE58|00404B0E|CXNetServer.exe|00004B0E|System           |                  |_ClassDestroy               |         |
|00000020|04     |049CFE5C|0051248F|CXNetServer.exe|0011248F|uBuffer          |TBufferLink       |Destroy                     |123[3]   |
|00000020|03     |049CFE6C|00404760|CXNetServer.exe|00004760|System           |TObject           |Free                        |         |
|00000020|04     |049CFE70|00513CA0|CXNetServer.exe|00113CA0|uIOCPCentre      |TIOCPClientContext|checkPostWSASendCache       |1089[41] |
|00000020|04     |049CFE90|00513618|CXNetServer.exe|00113618|uIOCPCentre      |TIOCPObject       |processIOQueued             |818[129] |
|00000020|04     |049CFED0|00514B9C|CXNetServer.exe|00114B9C|uIOCPWorker      |TIOCPWorker       |Execute                     |34[7]    |
|00000020|03     |049CFF1C|00441A58|CXNetServer.exe|00041A58|Classes          |                  |ThreadProc                  |         |
|00000020|03     |049CFF4C|004056EC|CXNetServer.exe|000056EC|System           |                  |ThreadWrapper               |         |
|00000020|04     |049CFF60|004FE092|CXNetServer.exe|000FE092|EExceptionManager|                  |DefaultThreadHandleException|2852[5]  |
-----------------------------------------------------------------------------------------------------------------------------------------

Modules Information:
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|Handle  |Name           |Description                                                     |Version          |Size   |Modified           |Path                                                                                                 |
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|00400000|CXNetServer.exe|                                                                |                 |2281472|2014-04-09 17:26:16|E:\¨°¡Á¡¤?¨¨¨ª?t\CXNetServer\                                                                             |
|05870000|xpsp2res.dll   |Service Pack 2 Messages                                         |5.2.3790.3959    |5535744|2007-02-17 06:44:18|C:\WINDOWS\system32\                                                                                 |
|06540000|msadcer.dll    |Microsoft Data Access - OLE DB Cursor Engine Resources          |2.82.3959.0      |12288  |2007-02-17 06:58:04|C:\Program Files\Common Files\System\msadc\                                                          |
|06DD0000|sqloledb.rll   |Microsoft OLE DB Provider for SQL Server                        |2000.86.3959.0   |53248  |2007-02-17 06:57:00|C:\Program Files\Common Files\System\Ole DB\                                                         |
|07210000|CDSOperator.dll|                                                                |                 |915456 |2014-02-14 15:57:17|E:\¨°¡Á¡¤?¨¨¨ª?t\CXNetServer\Libs\                                                                        |
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
|70200000|safemon.dll    |360¡ã2¨¨??¨¤¨º? ¨ª??¨¹¡¤¨¤?¡è?¡ê?¨¦                                        |8.4.0.1300       |1599360|2014-04-10 21:44:06|D:\Program Files\360\360Safe\safemon\                                                                |
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
|7C800000|kernel32.dll   |Windows NT BASE API Client DLL                                  |5.2.3790.5295    |1211392|2014-02-06 17:26:14|C:\WINDOWS\system32\                                                                                 |
|7C930000|ntdll.dll      |NT Layer DLL                                                    |5.2.3790.4937    |843264 |2011-11-23 00:28:30|C:\WINDOWS\system32\                                                                                 |
|7CA10000|shell32.dll    |Windows Shell Common Dll                                        |6.0.3790.5018    |8220672|2012-06-08 23:55:05|C:\WINDOWS\system32\                                                                                 |
|7F000000|lpk.dll        |Language Pack                                                   |5.2.3790.3959    |22016  |2007-02-17 06:43:10|C:\WINDOWS\system32\                                                                                 |
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Processes Information:
----------------------


Assembler Information:
------------------------------------------------------------------------------------
; Base Address: $404000, Allocation Base: $400000, Region Size: 1855488
; Allocation Protect: PAGE_EXECUTE_WRITECOPY, Protect: PAGE_EXECUTE_READ
; State: MEM_COMMIT, Type: MEM_IMAGE
; 
;
; System.TObject.FreeInstance (Line=0 - Offset=6)
; -----------------------------------------------
00404712  A6            CMPSB
;
; Line=0 - Offset=7
; -----------------
00404713  0000          ADD  [EAX], AL            ; <-- EXCEPTION
00404715  008BC3E8E7EA  ADD  [EBX-$1518173D], CL
0040471B  FF            DB   $FF                  ; ???? unknown/invalid instruction
0040471C  FF5BC3        CALL DWORD PTR [EBX-$3D]
0040471F  90            NOP
00404720  83C0D8        ADD  EAX, -$28
00404723  8B00          MOV  EAX, [EAX]

Registers:
-----------------------------
EAX: ????       EDI: ????    
EBX: ????       ESI: ????    
ECX: ????       EBP: ????    
EDX: ????       ESP: ????    
EIP: ????       FLG: ????    
EXP: 00404713   STK: 049CFE50

Stack:               Memory Dump:
------------------   ---------------------------------------------------------------------------
049CFE8C: 049CFECC   00404713: 00 00 00 8B C3 E8 E7 EA FF FF 5B C3 90 83 C0 D8  ..........[.....
049CFE88: 00F5D1E0   00404723: 8B 00 C3 8B C0 84 D2 74 08 83 C4 F0 E8 88 03 00  .......t........
049CFE84: 00FFFFFF   00404733: 00 84 D2 74 0F E8 D7 03 00 00 64 8F 05 00 00 00  ...t......d.....
049CFE80: FFFFFFFF   00404743: 00 83 C4 0C C3 E8 17 04 00 00 84 D2 7E 05 E8 B6  ............~...
049CFE7C: 049CFE8C   00404753: 03 00 00 C3 90 85 C0 74 07 B2 01 8B 08 FF 51 FC  .......t......Q.
049CFE78: 00513CE4   00404763: C3 53 56 57 89 C3 89 D7 AB 8B 4B D8 31 C0 51 C1  .SVW......K.1.Q.
049CFE74: 049CFE94   00404773: E9 02 49 F3 AB 59 83 E1 03 F3 AA 89 D0 89 E2 8B  ..I..Y..........
049CFE70: 00513CA5   00404783: 4B B8 85 C9 74 01 51 8B 5B DC 85 DB 74 04 8B 1B  K...t.Q.[...t...
049CFE6C: 00404763   00404793: EB ED 39 D4 74 1D 5B 8B 0B 83 C3 04 8B 73 10 85  ..9.t.[......s..
049CFE68: 049CFE8C   004047A3: F6 74 06 8B 7B 14 89 34 07 83 C3 1C 49 75 ED 39  .t..{..4....Iu.9
049CFE64: 070DDB40   004047B3: D4 75 E3 5F 5E 5B C3 8B C0 53 56 89 C3 89 C6 8B  .u._^[...SV.....
049CFE60: 00000000   004047C3: 36 8B 56 C0 8B 76 DC 85 D2 74 07 E8 CD 1D 00 00  6.V..v...t......
049CFE5C: 00512494   004047D3: 89 D8 85 F6 75 E9 5E 5B C3 87 D1 81 F9 00 00 00  ....u.^[........
049CFE58: 00404B11   004047E3: FF 73 11 81 F9 00 00 00 FE 72 07 0F BF C9 03 08  .s.......r......
049CFE54: 070DDB01   004047F3: FF 21 FF E1 81 E1 FF FF FF 00 01 C1 89 D0 8B 11  .!..............
049CFE50: 0040471D   00404803: E9 8C 31 00 00 C3 8D 40 00 55 8B EC 83 C4 F8 53  ..1....@.U.....S



