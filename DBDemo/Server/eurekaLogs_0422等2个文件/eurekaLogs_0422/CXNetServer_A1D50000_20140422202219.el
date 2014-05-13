EurekaLog 7.0.6.27 RC 5  

Exception:
------------------------------------------------------------------
  2.2 Address: 004070A1
  2.5 Type   : EOutOfMemory
  2.6 Message: Out of memory: $00000000 DATA [?] 1195725896 bytes.
  2.7 ID     : A1D50000
  2.11 Sent  : 0

User:
----------------
  3.2 Name : 123
  3.3 Email: 

Steps to reproduce:
------------
  8.1 Text: 


Call Stack Information:
-------------------------------------------------------------------------------------------------------------------------------------------------
|Methods |Details|Stack   |Address |Module         |Offset  |Unit                  |Class                 |Procedure/Method            |Line    |
-------------------------------------------------------------------------------------------------------------------------------------------------
|*Exception Thread: ID=2348; Parent=1200; Priority=0                                                                                            |
|Class=TIOCPWorker; Name= (uIOCPWorker.TIOCPWorker.Execute)                                                                                     |
|DeadLock=0; Wait Chain=?¨°2?¦Ì????¡§¦Ì?3¨¬D¨°?¡ê                                                                                                      |
|Comment=                                                                                                                                       |
|-----------------------------------------------------------------------------------------------------------------------------------------------|
|7FFFFFFE|03     |00000000|004070A1|CXNetServer.exe|000070A1|System                |                      |DynArraySetLength           |        |
|00000020|03     |043CFDF8|0040717D|CXNetServer.exe|0000717D|System                |                      |_DynArraySetLength          |        |
|00000020|04     |043CFE00|0059F602|CXNetServer.exe|0019F602|uIOCPJSonStreamDecoder|TIOCPJSonStreamDecoder|Decode                      |78[41]  |
|00000020|04     |043CFE40|0059E723|CXNetServer.exe|0019E723|uIOCPCentre           |TIOCPClientContext    |RecvBuffer                  |1119[12]|
|00000020|04     |043CFE6C|0059DD71|CXNetServer.exe|0019DD71|uIOCPCentre           |TIOCPObject           |processIOQueued             |736[85] |
|00000020|04     |043CFED0|0059FA4C|CXNetServer.exe|0019FA4C|uIOCPWorker           |TIOCPWorker           |Execute                     |34[7]   |
|00000020|03     |043CFF1C|00441A58|CXNetServer.exe|00041A58|Classes               |                      |ThreadProc                  |        |
|00000020|03     |043CFF4C|004056EC|CXNetServer.exe|000056EC|System                |                      |ThreadWrapper               |        |
|00000020|04     |043CFF60|004FE092|CXNetServer.exe|000FE092|EExceptionManager     |                      |DefaultThreadHandleException|2852[5] |
-------------------------------------------------------------------------------------------------------------------------------------------------

Modules Information:
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|Handle  |Name           |Description                                                     |Version          |Size   |Modified           |Path                                                                                                 |
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|00400000|CXNetServer.exe|                                                                |                 |2284032|2014-04-12 17:35:18|E:\¨°¡Á¡¤?¨¨¨ª?t\CXNetServer\                                                                             |
|00D40000|CDSOperator.dll|                                                                |                 |915456 |2014-02-14 15:57:17|E:\¨°¡Á¡¤?¨¨¨ª?t\CXNetServer\Libs\                                                                        |
|05890000|xpsp2res.dll   |Service Pack 2 Messages                                         |5.2.3790.3959    |5535744|2007-02-17 06:44:18|C:\WINDOWS\system32\                                                                                 |
|06740000|msadcer.dll    |Microsoft Data Access - OLE DB Cursor Engine Resources          |2.82.3959.0      |12288  |2007-02-17 06:58:04|C:\Program Files\Common Files\System\msadc\                                                          |
|06750000|sqloledb.rll   |Microsoft OLE DB Provider for SQL Server                        |2000.86.3959.0   |53248  |2007-02-17 06:57:00|C:\Program Files\Common Files\System\Ole DB\                                                         |
|06AE0000|msader15.dll   |Microsoft Data Access - ActiveX Data Objects Resources          |2.82.3959.0      |16384  |2007-02-17 06:58:04|C:\Program Files\Common Files\System\ado\                                                            |
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
------------------------------------------------------------------------------------------------------
; Base Address: $407000, Allocation Base: $400000, Region Size: 1847296
; Allocation Protect: PAGE_EXECUTE_WRITECOPY, Protect: PAGE_EXECUTE_READ
; State: MEM_COMMIT, Type: MEM_IMAGE
; 
;
; System.DynArraySetLength (Line=0 - Offset=181)
; ----------------------------------------------
004070A1  45            INC    EBP                     ; <-- EXCEPTION
004070A2  E08B          LOOPNE -$75                    ; ($0040702F) System.DynArraySetLength (Line=0)
004070A4  55            PUSH   EBP
004070A5  E4E8          IN     AL, $E8
004070A7  71C1          JNO    -$3F                    ; ($0040706A) System.DynArraySetLength (Line=0)
004070A9  FF            DB     $FF                     ; ???? unknown/invalid instruction
004070AA  FF8B5DE0EB5E  DEC    DWORD PTR [EBX+$5EEBE05D]
004070B0  FF0B          DEC    DWORD PTR [EBX]
004070B2  8B45E4        MOV    EAX, [EBP-$1C]
004070B5  E82EC1FFFF    CALL   -$3ED2                  ; ($004031E8) System._GetMem
004070BA  8BD8          MOV    EBX, EAX
004070BC  8B45F0        MOV    EAX, [EBP-$10]
004070BF  8945EC        MOV    [EBP-$14], EAX
004070C2  3B7DEC        CMP    EDI, [EBP-$14]
004070C5  7D03          JGE    +3                      ; ($004070CA) System.DynArraySetLength (Line=0)
004070C7  897DEC        MOV    [EBP-$14], EDI
004070CA  85F6          TEST   ESI, ESI

Registers:
-----------------------------
EAX: ????       EDI: ????    
EBX: ????       ESI: ????    
ECX: ????       EBP: ????    
EDX: ????       ESP: ????    
EIP: ????       FLG: ????    
EXP: 004070A1   STK: 043CFDC4

Stack:               Memory Dump:
------------------   ---------------------------------------------------------------------------
043CFE00: 0059F607   004070A1: 45 E0 8B 55 E4 E8 71 C1 FF FF 8B 5D E0 EB 5E FF  E..U..q....]..^.
043CFDFC: 043CFE04   004070B1: 0B 8B 45 E4 E8 2E C1 FF FF 8B D8 8B 45 F0 89 45  ..E.........E..E
043CFDF8: 00407182   004070C1: EC 3B 7D EC 7D 03 89 7D EC 85 F6 74 2A 8B 55 EC  .;}.}..}...t*.U.
043CFDF4: 043CFE3C   004070D1: 0F AF 55 E8 8B C3 83 C0 08 33 C9 E8 A7 CC FF FF  ..U......3......
043CFDF0: 043CFE34   004070E1: 8B 45 EC 50 8B 55 FC 8B 12 8B C3 83 C0 08 8B CE  .E.P.U..........
043CFDEC: 00000001   004070F1: E8 D6 FE FF FF EB 16 8B 4D EC 0F AF 4D E8 8B D3  ........M...M...
043CFDE8: 043CFE00   00407101: 83 C2 08 8B 45 FC 8B 00 E8 CE C3 FF FF C7 03 01  ....E...........
043CFDE4: 00000000   00407111: 00 00 00 83 C3 04 89 3B 83 C3 04 8B D7 2B 55 F0  .......;.....+U.
043CFDE0: 043CFE08   00407121: 0F AF 55 E8 8B 45 E8 0F AF 45 F0 03 C3 33 C9 E8  ..U..E...E...3..
043CFDDC: 00000001   00407131: 53 CC FF FF 83 7D F8 01 7E 2E 83 45 08 04 FF 4D  S....}..~..E...M
043CFDD8: 47455428   00407141: F8 4F 85 FF 7C 22 47 C7 45 F4 00 00 00 00 8B 45  .O..|"G.E......E
043CFDD4: 00000000   00407151: 08 50 8B 45 F4 8D 04 83 8B 4D F8 8B D6 E8 89 FE  .P.E.....M......
043CFDD0: 0690D370   00407161: FF FF FF 45 F4 4F 75 E6 8B 45 FC 89 18 5F 5E 5B  ...E.Ou..E..._^[
043CFDCC: 06984FC0   00407171: 8B E5 5D C2 04 00 90 54 83 04 24 04 E8 6A FE FF  ..]....T..$..j..
043CFDC8: 00000000   00407181: FF C3 90 53 85 C0 74 12 8B D8 83 EB 04 8B 1B 53  ...S..t........S
043CFDC4: 004070AB   00407191: 51 33 C9 E8 0B 00 00 00 5B C3 8B C1 E8 F6 00 00  Q3......[.......



