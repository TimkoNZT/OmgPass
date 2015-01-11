unit uCrypt;
interface
uses Windows, SysUtils, Variants, Classes, wCrypt2, ClipBrd, uMd5;
var
//  Prov: HCRYPTPROV;            //Криптопровайдер
//  Stream: TMemoryStream;
//  Hash: HCRYPTHASH;            //Хэш-обьект
//  puKey: HCRYPTKEY;
//  usKey: HCRYPTKEY;
//  jStream: TMemoryStream;
//  BufSize: DWORD;
  Pass, Salt: String;

const
AProvType = PROV_RSA_FULL;
AProvFlag = CRYPT_VERIFYCONTEXT;
AAlgHash  = CALG_MD5;
AAlgCrypt = CALG_RC4;

exPublicKey: array[0..83] of byte = ($06, $02, $00, $00, $00, $A4, $00, $00, $52, $53, $41, $31, $00, $02, $00, $00,
                                    $01, $00, $01, $00, $1F, $7F, $4F, $80, $3A, $B8, $91, $6B, $9F, $9B, $F5, $39, $12,
                                    $45, $A2, $A6, $D0, $3F, $E4, $6A, $58, $F7, $5C, $9B, $88, $7A, $43, $67, $22, $7F,
                                    $12, $92, $CA, $C4, $62, $F3, $1D, $37, $47, $4E, $22, $4F, $9E, $21, $33, $4F, $46,
                                    $D5, $D1, $5B, $6F, $DC, $BE, $6C, $C3, $C8, $C0, $A9, $CC, $56, $ED, $8D, $12, $D6);

exPrivateKey: array[0..307] of byte = ($07, $02, $00, $00, $00, $A4, $00, $00, $52, $53, $41, $32, $00, $02, $00, $00,
                                    $01, $00, $01, $00, $1F, $7F, $4F, $80, $3A, $B8, $91, $6B, $9F, $9B, $F5, $39, $12,
                                    $45, $A2, $A6, $D0, $3F, $E4, $6A, $58, $F7, $5C, $9B, $88, $7A, $43, $67, $22, $7F,
                                    $12, $92, $CA, $C4, $62, $F3, $1D, $37, $47, $4E, $22, $4F, $9E, $21, $33, $4F, $46,
                                    $D5, $D1, $5B, $6F, $DC, $BE, $6C, $C3, $C8, $C0, $A9, $CC, $56, $ED, $8D, $12, $D6,
                                    $DF, $99, $92, $E9, $3E, $9D, $4B, $00, $C7, $FE, $56, $57, $68, $39, $C6, $C5, $4C,
                                    $24, $B0, $B2, $5B, $44, $0D, $A2, $0E, $F5, $CC, $A6, $A8, $E8, $01, $F6, $C1, $42,
                                    $A2, $82, $D4, $7A, $E2, $A2, $03, $96, $AC, $02, $E9, $3F, $5B, $12, $C9, $86, $E2,
                                    $04, $FB, $BF, $8B, $57, $5E, $CF, $68, $16, $6C, $92, $C4, $DE, $9D, $67, $66, $DB,
                                    $2C, $05, $2E, $D5, $ED, $97, $B4, $DE, $16, $55, $7F, $C7, $ED, $0F, $C7, $FE, $2A,
                                    $FD, $BB, $A3, $3A, $5D, $DD, $39, $CD, $AB, $1F, $61, $41, $E2, $06, $EF, $3B, $A9,
                                    $7A, $47, $9C, $72, $41, $D5, $C3, $F5, $AF, $66, $92, $07, $85, $89, $91, $63, $1F,
                                    $FA, $89, $A0, $71, $6D, $E6, $0C, $61, $C1, $5E, $7E, $07, $BE, $73, $28, $48, $3E,
                                    $39, $20, $83, $CE, $A3, $15, $55, $E0, $99, $49, $0A, $02, $63, $30, $C0, $4D, $7F,
                                    $24, $5B, $71, $45, $6E, $3C, $4E, $81, $D9, $4C, $A9, $8B, $E6, $48, $E2, $E4, $3C,
                                    $DA, $BD, $E3, $D2, $38, $54, $4F, $20, $E1, $55, $93, $BE, $51, $66, $C0, $1A, $02,
                                    $33, $73, $2B, $29, $BE, $0F, $27, $4A, $9E, $DB, $FE, $42, $55, $38, $5A, $C7, $BC,
                                    $16, $59, $08, $36, $0B, $C0, $CF, $FD, $34, $A7, $A3, $43, $E8, $34, $14, $88, $E3,
                                    $04, $26, $5E);

sigPublicKey: array[0..83] of byte = ($06, $02, $00, $00, $00, $24, $00, $00, $52, $53, $41, $31, $00, $02, $00, $00,
                                    $01, $00, $01, $00, $43, $2F, $3E, $45, $C4, $99, $75, $5E, $64, $7C, $D0, $4E, $45,
                                    $B7, $D6, $E9, $3D, $E4, $2F, $23, $26, $B4, $B3, $64, $E5, $07, $D3, $18, $B1, $AA,
                                    $D9, $CB, $E5, $2D, $F5, $AE, $C5, $71, $EC, $F8, $6D, $2C, $27, $27, $A2, $D6, $2F,
                                    $84, $4E, $CD, $24, $74, $77, $D0, $59, $B3, $5C, $05, $4D, $CC, $E6, $08, $B9, $C0);

sigPrivateKey: array[0..307] of byte = ($07, $02, $00, $00, $00, $24, $00, $00, $52, $53, $41, $32, $00, $02, $00, $00,
                                    $01, $00, $01, $00, $43, $2F, $3E, $45, $C4, $99, $75, $5E, $64, $7C, $D0, $4E, $45,
                                    $B7, $D6, $E9, $3D, $E4, $2F, $23, $26, $B4, $B3, $64, $E5, $07, $D3, $18, $B1, $AA,
                                    $D9, $CB, $E5, $2D, $F5, $AE, $C5, $71, $EC, $F8, $6D, $2C, $27, $27, $A2, $D6, $2F,
                                    $84, $4E, $CD, $24, $74, $77, $D0, $59, $B3, $5C, $05, $4D, $CC, $E6, $08, $B9, $C0,
                                    $01, $F7, $F5, $B9, $EF, $36, $D3, $4B, $8A, $E7, $8E, $FD, $B3, $F9, $D4, $1B, $E3,
                                    $BF, $78, $AE, $C6, $68, $4A, $C6, $5C, $3D, $E0, $02, $AB, $05, $9A, $F8, $43, $8A,
                                    $B8, $7A, $48, $A6, $4C, $D0, $9D, $BF, $A4, $6B, $72, $97, $3F, $55, $7E, $83, $0B,
                                    $34, $86, $AD, $F1, $B8, $97, $65, $99, $A9, $54, $4C, $75, $C6, $01, $F3, $8A, $C0,
                                    $68, $B8, $8A, $C2, $9B, $0C, $36, $36, $65, $AF, $15, $27, $A3, $C1, $DB, $1F, $7E,
                                    $32, $42, $63, $43, $B9, $64, $A3, $0D, $7D, $A7, $29, $89, $DF, $27, $C2, $E7, $16,
                                    $B9, $D5, $D7, $68, $E6, $60, $C2, $DA, $06, $41, $23, $02, $DD, $DD, $2C, $10, $5A,
                                    $0C, $44, $06, $84, $48, $8F, $30, $F8, $8A, $79, $3C, $11, $DA, $4C, $A0, $5A, $94,
                                    $75, $D5, $2B, $92, $20, $F7, $C9, $4C, $63, $CA, $C4, $4F, $EF, $C6, $56, $A9, $56,
                                    $75, $47, $8F, $41, $12, $76, $06, $01, $B4, $F9, $38, $88, $CE, $F9, $C2, $A3, $77,
                                    $B7, $4F, $ED, $50, $F5, $F2, $30, $9C, $C7, $46, $F3, $B5, $3C, $A6, $9D, $8E, $F6,
                                    $12, $A4, $5D, $65, $0E, $67, $CF, $EB, $95, $06, $55, $4A, $69, $A6, $1D, $57, $B5,
                                    $6A, $1C, $CA, $8C, $4A, $FD, $F9, $A5, $16, $2F, $43, $AD, $2E, $38, $4A, $35, $4B,
                                    $82, $17, $74);

procedure EnumProviders;
procedure LogHashInfo(Hash: HCRYPTHASH);
procedure LogProviderInfo(hProv: HCRYPTPROV);
procedure Init;
function GetHeader(Password: string): TMemoryStream;
function GetSecondHeader(Password: string): TMemoryStream;

function CryptStr(ASourceStr, APassword: string;
                    ABuffSize: integer): string;

function UnCryptStr(ASourceStr, APassword: string;
                    ABuffSize: integer): string;

function CryptStream(ASourceStream, ADestStream: TMemoryStream;
                    APassword: string;
                    ABufferSize: Integer): Boolean;

function UnCryptStream(ASourceStream, ADestStream: TMemoryStream;
                    APassword: string;
                    ABufferSize: Integer): Boolean;

implementation
uses uLog;

function StreamToStr(Stream: TStream): String;
var i: Integer;
    h: Byte;
begin
    for i := 1 to Stream.Size do begin
        Stream.Read(h, 1);
        Result:= Result + '$' + h.ToHexString(2) + ', '
    end;
    Stream.Position:=0;
end;

function ExportPublicKey(Key: HCRYPTKEY; FileName: String) : Boolean;
var
  Stream: TMemoryStream;
  BufSize: DWORD;
begin
  BufSize:=0;
  Stream:=TMemoryStream.Create;
  CryptExportKey(Key, 0, PUBLICKEYBLOB, 0, nil, @BufSize);
  Stream.SetSize(BufSize);
  Result:=CryptExportKey(Key, 0, PUBLICKEYBLOB, 0, PByte(Stream.Memory),@BufSize);
  Stream.SaveToFile(FileName);
  Stream.Free;
end;

function ExportPrivateKey(Key: HCRYPTKEY; FileName: String) : Boolean;
var
  Stream: TMemoryStream;
  BufSize: DWORD;

begin
  BufSize:=0;
  Stream:=TMemoryStream.Create;
  CryptExportKey(Key, 0, PRIVATEKEYBLOB, 0, nil, @BufSize);
  Stream.SetSize(BufSize);
  Result:=CryptExportKey(Key, 0, PRIVATEKEYBLOB, 0, PByte(Stream.Memory),@BufSize);
  Stream.SaveToFile(FileName);
  Stream.Free;
end;

function ExportSessionKey(Key: HCRYPTKEY; pKey: HCRYPTKEY;  FileName: String) : Boolean;
var
  Stream: TMemoryStream;
  BufSize: DWORD;
  ValH: Byte;
  ValHex: String;
  i: Integer;
begin
  BufSize:=0;
  Stream:=TMemoryStream.Create;
  CryptExportKey(Key, pKey, SIMPLEBLOB, 0, nil, @BufSize);
  Stream.SetSize(BufSize);
  Result:=CryptExportKey(Key, pKey, SIMPLEBLOB, 0, PByte(Stream.Memory),@BufSize);
  Stream.SaveToFile(FileName);
  Stream.Position:=25;
  for i:= 0 to 20 do begin
        Stream.Read(ValH,1);
        ValHex := ValHex + ValH.ToHexString(2);
    end;
    Log('     key!: ' + ValHex);
  Stream.Free;
end;

function ImportPublicKey(FileName: String): HCRYPTKEY;
var
  Stream: TMemoryStream;
begin
//try
//  Stream:=TMemoryStream.Create;
//  Stream.LoadFromFile(FileName);
//  if not CryptImportKey(Prov, PByte(Stream.Memory), Stream.Size, 0, 0, @puKey) then RaiseLastOSError;
//  Stream.Free;
//  Except on e: Exception do begin
//        ErrorLog(e, 'ImportPublicKey');
//  end;
//end;
end;

function SignMessage(): String;
var
  Prov: HCRYPTPROV;
  Hash: HCRYPTHASH;
  BufLen, flg: DWORD;
  ExKey, SignKey: HCRYPTKEY;
  Res: array[0..127] of byte;
  h:Byte;
  i: Integer;
begin
try
    Pass :='Password';
    Salt :='1234567890';
    Result:='';
    //CryptAcquireContext(@Prov, nil, nil, PROV_RSA_FULL, CRYPT_DELETEKEYSET);
    CryptAcquireContext(@Prov, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT);
    CryptCreateHash(Prov, CALG_MD5, 0, 0, @Hash);
    CryptHashData(Hash, @Pass[1], Pass.Length, 0);
    if not CryptGenKey(Prov, AT_KEYEXCHANGE, (512 shl 16) or CRYPT_EXPORTABLE, @ExKey) then RaiseLastOSError;
    if not CryptGenKey(Prov, AT_SIGNATURE, (512 shl 16) or CRYPT_EXPORTABLE, @SignKey) then RaiseLastOSError;
    //if not CryptDeriveKey(Prov, CALG_RC2, Hash, 0, @KeyExchKey) then RaiseLastOSError;
//    if not ExportPublicKey(SignKey, 'c:\SigKeyPu.bin') then RaiseLastOSError;
//    if not ExportPublicKey(ExKey, 'c:\ExKeyPu.bin') then RaiseLastOSError;
//    if not ExportPrivateKey(SignKey, 'c:\SigKeyPr.bin') then RaiseLastOSError;
//    if not ExportPrivateKey(ExKey, 'c:\ExKeyPr.bin') then RaiseLastOSError;

    //if not CryptDeriveKey(Prov, CALG_RC4, Hash, 0, @Key) then RaiseLastOSError;
    //ImportPublicKey('c:\SigKey.bin');
    ///Stream:=TMemoryStream.Create;
    //Stream.LoadFromFile('c:\SigKeyPu.bin');
    //if not CryptImportKey(Prov, PByte(Stream.Memory), Stream.Size, 0, 0, @SignKey) then RaiseLastOSError;
    //Stream.LoadFromFile('c:\SigKeyPu.bin');
    //Clipboard.AsText:= StreamToStr(Stream);


//    if not CryptImportKey(Prov, PByte(Stream.Memory), Stream.Size, 0, 0, @SignKey) then RaiseLastOSError;
//    if not CryptGetUserKey(Prov, AT_SIGNATURE, @SignKey) then RaiseLastOSError;
//    BufLen:=0;
//    if not CryptSignHash(Hash, AT_SIGNATURE, nil, 0 , nil, @BufLen) then RaiseLastOSError;
//    if BufLen>0 then begin
//    if not CryptSignHash(Hash, AT_SIGNATURE, nil, 0, @res, @BufLen) then RaiseLastOSError;
//    for i := 0 to BufLen - 1 do Result:=Result + Res[i].ToHexString(2);

  CryptDestroyHash(Hash);
  CryptReleaseContext(Prov,0);
Except on e: Exception do begin
        ErrorLog(e, 'ExportSign');
    end;
end;
end;

procedure LogHashInfo(Hash: HCRYPTHASH);
var
    DataLen: DWORD;
    Data: Dword;
    Val: TMemoryStream;
    ValH: Byte;
    ValHex: String;
    i: Integer;
begin
try
    Log('HashInfo:', (Hash));
    DataLen:=0;
    if not CryptGetHashParam(Hash, HP_HASHSIZE, nil, @DataLen, 0) then RaiseLastOSError;
    if DataLen > 0 then
    if not CryptGetHashParam(Hash, HP_HASHSIZE, @Data, @DataLen, 0) then RaiseLastOSError;
    Log('     HP_HASHSIZE:', IntToStr(Data));
    DataLen:=0;
    if not CryptGetHashParam(Hash, HP_ALGID, nil, @DataLen, 0) then RaiseLastOSError;
    if DataLen > 0 then
    if not CryptGetHashParam(Hash, HP_ALGID, @Data, @DataLen, 0) then RaiseLastOSError;
    Log('     HP_ALGID: ', IntToStr(Data));
    DataLen:=0;
    Val:=TMemoryStream.Create;
    if not CryptGetHashParam(Hash, HP_HASHVAL, nil, @DataLen, 0) then RaiseLastOSError;
    if DataLen > 0 then Val.SetSize(DataLen);
    if not CryptGetHashParam(Hash, HP_HASHVAL, Val.Memory, @DataLen, 0) then RaiseLastOSError;
    Val.Position:=0;
    for i:= 1 to Val.Size do begin
        Val.Read(ValH,1);
        ValHex := ValHex + ValH.ToHexString(2);
    end;
    Log('     HP_HASHVAL: ' + ValHex);
    Val.Free;
except on e: Exception do begin
        ErrorLog(e, 'LogHashInfo');
    end;
end;
end;
procedure LogKeyInfo(Key: HCRYPTKEY);
var
    KeyLen, DataLen: Dword;

begin
    Log('KeyInfo: ', Key);
    DataLen:=4;
    CryptGetKeyParam(Key, KP_KEYLEN, @KeyLen, @DataLen, 0);
    Log('Key_length:', KeyLen);
end;


procedure Init;
var
BufLen, DataLen: DWord;
Buf: TMemoryStream;
Mess: String;
begin
try
//Pass:='Password';
//if not CryptAcquireContext(@Prov, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT) then RaiseLastOSError;
//if not CryptCreateHash(Prov, CALG_MD5, 0, 0, @Hash) then RaiseLastOSError;  //CALG_MAC, CALG_MD2, CALG_MD5, CALG_SHA.
//if not CryptHashData(Hash, PByte(Pass), Length(Pass), 0) then RaiseLastOSError;
//if not CryptDeriveKey(Prov, CALG_DES, Hash, CRYPT_EXPORTABLE or CRYPT_NO_SALT, @usKey) then RaiseLastOSError;
////if not CryptImportKey(Prov, @exPublicKey, SizeOf(exPublicKey), 0, 0, @puKey) then RaiseLastOSError;
//ImportPublicKey('c:\exKeyPu.bin');
//if not ExportSessionKey(usKey, puKey, 'c:\1.bin') then RaiseLastOSError;
//Mess:= umd5.MD5String(Pass).ToHexString;
//BufLen:=Length(Mess);
//DataLen:=Length(Mess);
//CryptEncrypt(usKey, 0,true,0,nil,@BufLen,0);
//SetLength(Mess, BufLen);
//CryptEncrypt(usKey, 0, true, 0, PByte(Mess), @DataLen, BufLen);
//Log(Mess);
//LogKeyInfo(puKey);
////LogKeyInfo(usKey);
//CryptDestroyKey(puKey);
//CryptDestroyKey(usKey);
////LogHashInfo(Hash);
//CryptDestroyHash(Hash);
//CryptReleaseContext(Prov, 0)
//Log(exPrivateKey, 5, 'PubKey');
Log(GetHeader('SH'), 0, '=');
except on e: Exception do begin
        ErrorLog(e, 'Start');
    end;
end;
end;

procedure LogProviderInfo(hProv: HCRYPTPROV);
type
    algInfo = record
    algID: ALG_ID;
    dwBits: DWORD;
    dwNameLen: DWORD;
    szName: array[0..50] of byte;
    end;
var
    ai: algInfo;
    vers: array[0..3] of byte;
    DataLen: Dword;
    pName: array[0..100] of byte;
begin
    Log('');
    Log('Cripto Provider Info:');
    if not CryptGetProvParam(hProv, PP_NAME, nil, @DataLen, 0) then RaiseLastOSError;
    if not CryptGetProvParam(hProv, PP_NAME, @pName, @DataLen, 0) then RaiseLastOSError;
    Log('Name: ', String(PAnsiChar(@pName[0])));
    DataLen:=4;
    if not CryptGetProvParam(hProv, PP_VERSION, (@vers), @DataLen, 0) then RaiseLastOSError;
    Log('Version: ' + vers[1].ToString  + '.' + vers[0].ToString);
    Log('Algs:');
    DataLen:=SizeOf(ai);
    if not CryptGetProvParam(hProv, PP_ENUMALGS, @ai, @DataLen, CRYPT_FIRST) then RaiseLastOSError;
    with ai do begin
        Log('  ---  Alg_name:', String(PAnsiChar(@szName[0])));
        Log('       Alg_key_length: ' + dwBits.ToString + ' bit');
        Log('       ID: '+IntToStr(AlgID));
    end;
    while CryptGetProvParam(hProv, PP_ENUMALGS, @ai, @DataLen, CRYPT_NEXT) do begin
        with ai do begin
            Log('  ---  Alg_name:', String(PAnsiChar(@szName[0])));
            Log('       Alg_key_length:' + dwBits.ToString + ' bit');
            Log('       ID:'+IntToStr(AlgID));
            //DataLen := sizeof(ai);
        end;
    end;
end;

procedure EnumProviders;

var
    dwIndex: Integer;
    dwProvType, DataLen, impType: DWord;
    provName: String;
{вспомогательная функция, преобразующая тип провайдера в строку}
function ProvTypeToStr(provType: DWORD): string;
begin
    case provType of
    PROV_RSA_FULL: ProvTypeToStr := 'RSA full provider';
    PROV_RSA_SIG: ProvTypeToStr := 'RSA signature provider';
    PROV_DSS: ProvTypeToStr := 'DSS provider';
    PROV_DSS_DH: ProvTypeToStr := 'DSS and Diffie-Hellman provider';
    PROV_FORTEZZA: ProvTypeToStr := 'Fortezza provider';
    PROV_MS_EXCHANGE: ProvTypeToStr := 'MS Exchange provider';
    PROV_RSA_SCHANNEL: ProvTypeToStr := 'RSA secure channel provider';
    PROV_SSL: ProvTypeToStr := 'SSL provider';
    PROV_RSA_AES: ProvTypeToStr := 'PROV_RSA_AES';
    else ProvTypeToStr := 'Unknown provider';
    end;
end;

begin
    Log('Founded Cryptoproviders:');
    Log('StartEnum----------------------------------------');
    dwIndex := 0;
try
    while(CryptEnumProviders(dwIndex, nil, 0, @dwProvType, nil{ @provName}, @DataLen)) do begin
        SetLength(provName, DataLen);
        CryptEnumProviders(dwIndex, nil, 0, @dwProvType, @provName[1], @DataLen);
        Log('Index: ' + dwIndex.ToString + '; Type: ' + dwProvType.ToHexString(2) + ' = ', ProvTypeToStr(dwProvType));
        Log('Name:', provName);
        Log('');
        Inc(dwIndex);
    end;
Except on e: Exception do begin
        ErrorLog(e, 'EnumProviders');
    end;
end;
    Log('EndEnum------------------------------------------');
end;

function GetHeader(Password: string): TMemoryStream;
var
    InStream: TMemoryStream;
begin
    try
        try
            InStream:= TMemoryStream.Create;
            InStream.Write(@exPublicKey[20], $40);
            Result:= TMemoryStream.Create;
            if not CryptStream(InStream, Result, Password, $40) then RaiseLastOSError;
        except on e: Exception do begin
            ErrorLog(e, 'GetHeaderFirst');
            end;
        end;
    finally
        InStream.Free;
    end;
end;
function GetSecondHeader(Password: string): TMemoryStream;
var
    data: PByte;
    hProv: HCRYPTPROV;
    hash: HCRYPTHASH;
    pKey, uKey: HCRYPTKEY;
    lBufLen, lDataLen: DWORD;
    Stream: TMemoryStream;
begin
    try
        try
            {получаем контекст криптопровайдера}
            if not CryptAcquireContext(@hProv, nil, nil, AProvType, AProvFlag) then RaiseLastOSError;
            {создаем хеш-объект}
            if not CryptCreateHash(hProv, AAlgHash, 0, 0, @hash)then RaiseLastOSError;
            {хешируем пароль}
            if not CryptHashData(hash, @Password[1], length(Password), 0) then RaiseLastOSError;
            {создаем ключ на основании пароля для потокового шифра}
            if not CryptDeriveKey(hProv, AAlgCrypt, hash, CRYPT_EXPORTABLE or CRYPT_NO_SALT, @uKey) then RaiseLastOSError;
            {импортируем ключ =)}
            if not CryptImportKey(hProv, @exPublicKey, SizeOf(exPublicKey), 0, 0, @pKey) then RaiseLastOSError;
            {готовим потоки, и выделяем место}
            Stream:=TMemoryStream.Create;
            Result:=TMemoryStream.Create;
            if not CryptExportKey(uKey, pKey, SIMPLEBLOB, 0, nil, @lBufLen)  then RaiseLastOSError;
            Stream.SetSize(lBufLen);
            if not CryptExportKey(uKey, pKey, SIMPLEBLOB, 0, PByte(Stream.Memory), @lBufLen) then RaiseLastOSError;
            {обрезаем поток до нужных размеров}
            Stream.Seek(12, TSeekOrigin.soBeginning);
            Result.CopyFrom(Stream, $40);
            Result.Position:=0;
        except on e: Exception do begin
            ErrorLog(e, 'GetHeaderSecond');
            end;
        end;
    finally
        {освобождаем ненужный поток}
        Stream.Free;
    end;
end;

////////////////////////////////////////////////////////////////////////////////

function CryptStream(ASourceStream, ADestStream: TMemoryStream;
                        APassword: string; ABufferSize: Integer): Boolean;
var
    data: PByte;
    hProv: HCRYPTPROV;
    hash: HCRYPTHASH;
    key: HCRYPTKEY;
    lBufLen, lDataLen: DWORD;
    lBufSize: Integer;
    lisEnd: Boolean;
    lStr: string;
begin
    try
        try
            //Log('CryptStream----------------------------------------------------');
            //Log(ASourceStream, 0 , 'SourseStream');
            {получаем контекст криптопровайдера}
            if not CryptAcquireContext(@hProv, nil, nil, AProvType, AProvFlag) then RaiseLastOSError;
            {создаем хеш-объект}
            if not CryptCreateHash(hProv, AAlgHash, 0, 0, @hash)then RaiseLastOSError;
            {хешируем пароль}
            if not CryptHashData(hash, @APassword[1], length(APassword), 0) then RaiseLastOSError;
            //LogHashInfo(hash);
            {создаем ключ на основании пароля для потокового шифра RC4}
            if not CryptDeriveKey(hProv, AAlgCrypt, hash, 0, @key) then RaiseLastOSError;
            {выделяем место для буфера}
            GetMem(data, ABufferSize);
            {шифруем данные}
            lBufSize:= ABufferSize div 2;
            ASourceStream.Position:= 0;
            ADestStream.Position:= 0;
            repeat
                lisEnd:= ASourceStream.Position>= ASourceStream.Size;
                lBufLen:= ASourceStream.Read(data^, lBufSize);
                if not CryptEncrypt(key, 0, lisEnd, 0, (data), @lBufLen, ABufferSize) then RaiseLastOSError;
                ADestStream.Write(data^, lBufLen);
            until (lisEnd);
            //Log(ADestStream, 0, 'OutStream');
            ASourceStream.Position:= 0;
            ADestStream.Position:= 0;
            Result:=True;
        except on e: Exception do begin
            ErrorLog(e, 'CryptStream');
            end;
        end;
    finally
        {очищаем память буфера}
        FreeMem(data, ABufferSize);
        {уничтожаем хеш-объект}
        CryptDestroyHash(hash);
        {освобождаем контекст криптопровайдера}
        CryptReleaseContext(hProv, 0);
    end;
end;

function UnCryptStream(ASourceStream, ADestStream: TMemoryStream;
                        APassword: string; ABufferSize: Integer): Boolean;
var
    data: PByte;
    hProv: HCRYPTPROV;
    hash: HCRYPTHASH;
    key: HCRYPTKEY;
    lBufLen, lDataLen: DWORD;
    lBufSize: Integer;
    lisEnd: Boolean;
begin
    try
        try
        {выделяем место для буфера}
        GetMem(data, ABufferSize);
        {получаем контекст криптопровайдера}
        if not CryptAcquireContext(@hProv, nil, nil, AProvType, AProvFlag) then RaiseLastOSError;
        {создаем хеш-объект}
        if not CryptCreateHash(hProv, AAlgHash, 0, 0, @hash)then RaiseLastOSError;
        {хешируем пароль}
        if not CryptHashData(hash, @APassword[1], length(APassword), 0) then
        RaiseLastOSError;
        {создаем ключ на основании пароля для потокового шифра RC4}
        if not CryptDeriveKey(hProv, AAlgCrypt, hash, 0, @key) then RaiseLastOSError;
        lBufSize:= ABufferSize div 2;
        ASourceStream.Position:= 0; ADestStream.Position:= 0;
        {шифруем данные}
        repeat
            lisEnd:= ASourceStream.Position >= ASourceStream.Size;
            lBufLen:= ASourceStream.Read(data^, lBufSize);
            if not CryptDecrypt(key, 0, lisEnd, 0, (data), @lBufLen) then RaiseLastOSError;
            ADestStream.Write(data^, lBufLen);
        until lisEnd;
        ASourceStream.Position:= 0; ADestStream.Position:= 0;
        Result:=True;
        except on e: Exception do begin
            ErrorLog(e, 'DecryptStream');
            end;
        end;
    finally
        {очишаем память от буфера}
        FreeMem(data, ABufferSize);
        {уничтожаем хеш-объект}
        CryptDestroyHash(hash);
        {освобождаем контекст криптопровайдера}
        CryptReleaseContext(hProv, 0);
    end;
end;

function CryptStr(ASourceStr, APassword: string;  ABuffSize: integer): string;
var
  lInStringStream, lOutStringStream: TMemoryStream;
begin
  lInStringStream:= TMemoryStream.Create;
  lOutStringStream:= TMemoryStream.Create;
  lInStringStream.Write(ASourceStr[1], Length(ASourceStr));
  try
    CryptStream(lInStringStream, lOutStringStream, APassword, ABuffSize);
    lOutStringStream.Position:= 0;
    SetLength(Result, lOutStringStream.Size);
    lOutStringStream.Read(Result[1], lOutStringStream.Size);
  finally
    lInStringStream.Free;
    lOutStringStream.Free;
  end;
end;

function UnCryptStr(ASourceStr, APassword: string; ABuffSize: integer): string;
var
  lInStringStream, lOutStringStream: TMemoryStream;
begin
  lInStringStream:= TMemoryStream.Create;
  lOutStringStream:= TMemoryStream.Create;
  lInStringStream.Write(ASourceStr[1], Length(ASourceStr));
  try
    UnCryptStream(lInStringStream, lOutStringStream, APassword, ABuffSize);
    lOutStringStream.Position:= 0;
    SetLength(Result, lOutStringStream.Size);
    lOutStringStream.Read(Result[1], lOutStringStream.Size);
  finally
    lInStringStream.Free;
    lOutStringStream.Free;
  end;
end;

end.
