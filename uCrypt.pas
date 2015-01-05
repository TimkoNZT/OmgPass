unit uCrypt;
interface
uses Classes, Windows, wCrypt2;
var
  Prov: HCRYPTPROV;            //Криптопровайдер
  Stream: TMemoryStream;
  Hash: HCRYPTHASH;            //Хэш-обьект
  Key: HCRYPTKEY;
procedure Start;

implementation

procedure Start;
begin
CryptAcquireContext(@Prov, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT);
Stream:=TMemoryStream.Create;
CryptCreateHash(Prov, CALG_SHA, 0, 0, @Hash);

//CryptHashData(Hash, PByte('Password'), Length('Password'), 0);

CryptDeriveKey(Prov, CALG_RC2, Hash, 0, @Key);






CryptDestroyHash(Hash);
CryptReleaseContext(Prov, 0)
end;


procedure ExportPublicKey(FileName: String);
var
  Prov: HCRYPTPROV;
  SignKey: HCRYPTKEY;
  Stream: TMemoryStream;
  BufSize: DWORD;
begin
  CryptAcquireContext(@Prov,'My_Container',nil,PROV_RSA_FULL,0);
  CryptGetUserKey(Prov,AT_SIGNATURE,@SignKey);
  Stream:=TMemoryStream.Create;
  CryptExportKey(SignKey,0,PUBLICKEYBLOB,0,nil,@BufSize);
  Stream.SetSize(BufSize);
  CryptExportKey(SignKey,0,PUBLICKEYBLOB,0,PByte(Stream.Memory),@BufSize);
  Stream.SaveToFile(FileName);
  Stream.Free;
  CryptDestroyKey(SignKey);
  CryptReleaseContext(Prov,0);
end;

function ImportPublicKey(FileName: String): HCRYPTKEY;

var
  Prov: HCRYPTPROV;
  Stream: TMemoryStream;
begin
  Stream:=TMemoryStream.Create;
  Stream.LoadFromFile(FileName);
  CryptImportKey(Prov,PByte(Stream.Memory),Stream.Size,0,0,@Result);
  Stream.Free;
end;

{
    procedure Encrypt(var InStream: TMemoryStream; Password: String);
    var
      Hash: HCRYPTHASH;         //дескриптор объекта функции хеширования CSP
      Key: HCRYPTKEY;
      BufLen, DataLen: DWORD;
      Str: String;
    begin
      CryptCreateHash(Prov, CALG_SHA, 0, 0, @Hash);
      CryptHashData(Hash,PByte(Password),Length(Password),0);
      CryptDeriveKey(Prov,CALG_RC2,Hash,0,@Key);
      Stream.Clear;
      Stream.WriteBuffer(Pointer(mmIn.Text)^,Length(mmIn.Text));
      DataLen:=Length(Text);
      BufLen:=Length(Text);
      CryptEncrypt(Key,0,true,0,nil,@BufLen,0);
      Stream.SetSize(BufLen);
      CryptEncrypt(Key,0,true,0,PByte(Stream.Memory),@DataLen,BufLen);
      SetLength(Str,BufLen);
      Stream.Seek(0,soFromBeginning);
      Stream.ReadBuffer(Pointer(Str)^,BufLen);
      Out_:=Str;
      CryptDestroyKey(Key);
      CryptDestroyHash(Hash);
    end;

    procedure TForm1.Button2Click(Sender: TObject);
    var
      Hash: HCRYPTHASH;
      Key: HCRYPTKEY;
      DataLen: DWORD;
      Str: String;
    begin
      Button2.Enabled:=false;
      Button1.Enabled:=true;
      CryptCreateHash(Prov,CALG_SHA,0,0,@Hash);
      CryptHashData(Hash,PByte(Password),Length(Password),0);
      CryptDeriveKey(Prov,CALG_RC2,Hash,0,@Key);
      DataLen:=Stream.Size;
      CryptDecrypt(Key,0,true,0,PByte(Stream.Memory),@DataLen);
      SetLength(Str,DataLen);
      Stream.Seek(0,soFromBeginning);
      Stream.ReadBuffer(Pointer(Str)^,DataLen);
      mmOut.Text:=Str;
      CryptDestroyKey(Key);
      CryptDestroyHash(Hash);
    end;
}
end.
