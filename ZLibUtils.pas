unit ZLibUtils;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Zlib;
//Размеры полей в заголовках под количество файлов,
// их длину и длину имени каждого файла
const HEADER_NUMFILES_LEN : Integer = 1;          //максимум 255 файлов
const HEADER_NAMEFILE_LEN : Integer = 1;          //не более 256 символов
const HEADER_LENFILES_LEN : Integer = 4;          //4G - это много

procedure CompressFiles(Files : TStrings; const Filename : String);
procedure DecompressFiles(const SourceFile, DestDirectory : String);
function GetArhFileNames(const SourceStream: TFileStream): TStringList;
//procedure DecompressCustomFile(SourceFile: String; CustomFile: String; outStream: TMemoryStream);

 implementation

 procedure CompressFiles(Files : TStrings; const Filename : String);
 var
inFile, outFile, tmpFile : TStream;
   Compr : TCompressionStream;
   i,l : Integer;
   s : AnsiString;
 begin
   if Files.Count > 0 then
   begin
     outFile := TFileStream.Create(Filename, fmCreate);
     try
       { the number of files }
       l := Files.Count;
       outfile.Write(l, HEADER_NUMFILES_LEN);
       for i := 0 to Files.Count - 1 do
       begin
         infile := TFileStream.Create(Files[i],fmOpenRead);
         try
           { the original filename }
           s := ExtractFilename(Files[i]);
           l := Length(s);
           outfile.Write(l, HEADER_NAMEFILE_LEN);
           outfile.Write(s[1],l);
           { the original filesize }
           l := infile.Size;
           outfile.Write(l,HEADER_LENFILES_LEN);
           { compress and store the file temporary}
           tmpFile := TMemoryStream.Create();
           compr := TCompressionStream.Create(clMax,tmpFile);
           try
             Compr.CopyFrom(inFile,l);
           finally
             compr.Free;
             //tmpFile.Free;
           end;
           { append the compressed file to the destination file }

           try
             outfile.CopyFrom(tmpFile,0);
           finally
             tmpFile.Free;
           end;
         finally
           infile.Free;
         end;
       end;
     finally
       outfile.Free;
     end;
   end;
 end;

function GetArhFileNames(const SourceStream: TFileStream): TStringList;
var
    fileNames: TStringList;
    inStream : TFilestream;
    i, l, c : Integer;
    S: AnsiString;
begin
    try
        { number of files }
        SourceStream.Read(c, HEADER_NUMFILES_LEN);
        for i := 1 to c do begin
            { read filename }
            SourceStream.Read(l, HEADER_NAMEFILE_LEN);
            SetLength(S, l);
            SourceStream.Read(S[1],l);
            fileNames.Add(S);
        end;
    finally
        result := fileNames;
    end;
end;

procedure DecompressFiles(const SourceFile, DestDirectory : String);
var
    dest, S : AnsiString;
    decompr : TDecompressionStream;
    inFile, outFile : TFilestream;
    nLen, fCount: Byte;
    fLen, i: Integer;
begin
    inFile := TFileStream.Create(SourceFile,fmOpenRead);
    try
        inFile.Read(fCount, HEADER_NUMFILES_LEN );
        for i := 1 to fCount do begin
            inFile.Read(nLen, HEADER_NAMEFILE_LEN);
            SetLength(s, nLen);
            inFile.Read(s[1], nLen);
            inFile.Read(fLen, HEADER_LENFILES_LEN);
           { decompress the files and store it }
            s := DestDirectory + s; //include the path
            outFile := TFileStream.Create(s, fmCreate);
            decompr := TDecompressionStream.Create(infile);
            try
                outFile.CopyFrom(decompr, fLen);
            finally
                outFile.Free;
                decompr.Free;
            end;
        end;
    finally
        inFile.Free;
    end;
end;

{procedure DecompressCustomFile(SourceFile, CustomFile: String, outStream: TMemoryStream);
var
    dest, S : AnsiString;
    decompr : TDecompressionStream;
    inFile: TFileStream;
    tmpFile, outFile : TMemoryStream;
    nLen, fCount: Byte;
    fLen, i: Integer;
begin
    inFile := TFileStream.Create(SourceFile,fmOpenRead);
    try
        inFile.Read(fCount, HEADER_NUMFILES_LEN );
        for i := 1 to fCount do begin
            inFile.Read(nLen, HEADER_NAMEFILE_LEN);
            SetLength(S, nLen);
            inFile.Read(S[1], nLen);
            inFile.Read(fLen, HEADER_LENFILES_LEN);
            decompr := TDecompressionStream.Create(inFile);
            try
                outFile:= TMemoryStream.Create();
                outFile.CopyFrom(decompr, fLen);
                outFile.Position:=0;
                if S=CustomFile then outStream.CopyFrom(outFile, 0);
            finally
                decompr.Free;
                outFile:=TMemoryStream.Create();
                outFile.Free;
            end;
        end;
    finally
        inFile.Free;
        //outFile.Free;
    end;
end;}

end.
