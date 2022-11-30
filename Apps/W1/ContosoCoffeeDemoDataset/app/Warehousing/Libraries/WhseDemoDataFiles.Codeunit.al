codeunit 4798 "Whse. Demo Data Files"
{
    // This object a placeholder for adding images to master data
    procedure GetFileStream(var TempBlob: Codeunit "Temp Blob"; FileBase64: Text)
    var
        Base64Convert: Codeunit "Base64 Convert";
        ObjOutStream: OutStream;
    begin
        TempBlob.CreateOutStream(ObjOutStream);
        Base64Convert.FromBase64(FileBase64, ObjOutStream);
    end;

    procedure GetNoPicture(): Codeunit "Temp Blob"
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        exit(TempBlob);
    end;
}