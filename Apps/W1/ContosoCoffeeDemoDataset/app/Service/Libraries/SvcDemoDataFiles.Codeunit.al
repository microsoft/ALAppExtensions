codeunit 5108 "Svc Demo Data Files"
{
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

    procedure GetMachine1Picture(): Codeunit "Temp Blob"
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        GetFileStream(TempBlob, Machine1Lbl);
        exit(TempBlob);
    end;

    procedure GetMachine2Picture(): Codeunit "Temp Blob"
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        GetFileStream(TempBlob, Machine2Lbl);
        exit(TempBlob);
    end;


    var
        Machine1Lbl: Label 'Machine 1', Locked = true;  //TODO: Image Base64
        Machine2Lbl: Label 'Machine 2', Locked = true;  //TODO: Image Base64
}