unit uFileIO;
interface

type TCryptedFileHeader = record
    theMagic:String[4];
    fVersion:Byte;
    CryData: array[0..127] of Byte;
end;

implementation

end.
