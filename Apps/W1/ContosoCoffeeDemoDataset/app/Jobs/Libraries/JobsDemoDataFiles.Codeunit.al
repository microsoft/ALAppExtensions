codeunit 5123 "Jobs Demo Data Files"
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

    procedure GetMachinePicture(): Codeunit "Temp Blob"
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        GetFileStream(TempBlob, MachineLbl);
        exit(TempBlob);
    end;

    procedure GetConsumablePicture(): Codeunit "Temp Blob"
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        GetFileStream(TempBlob, ConsumableLbl);
        exit(TempBlob);
    end;


    var
        MachineLbl: Label '', Locked = true;  //TODO: Image Base64
        ConsumableLbl: Label '', Locked = true;  //TODO: Image Base64
}