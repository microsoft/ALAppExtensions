table 30114 "Shpfy Data Capture"
{
    Access = Internal;
    Caption = 'Shopify Data Capture';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Linked To Table"; Integer)
        {
            Caption = 'Linked To Table';
            DataClassification = SystemMetadata;
        }
        field(3; "Linked To Id"; Guid)
        {
            Caption = 'Linked To Id';
            DataClassification = SystemMetadata;
        }
        field(4; Data; Blob)
        {
            Caption = 'Data';
            DataClassification = SystemMetadata;
        }
        field(5; "Hash No."; Integer)
        {
            Caption = 'Hash No.';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Indx01; "Linked To Table", "Linked To Id") { }
    }

    internal procedure GetData(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Rec.CalcFields(Data);
        if Rec.Data.HasValue then begin
            Rec.Data.CreateInStream(InStream, TextEncoding::UTF8);
            exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator()));
        end;
    end;

    internal procedure Add(TableNo: Integer; SystemId: Guid; Data: Text)
    var
        DataCapture: Record "Shpfy Data Capture";
        Hash: Codeunit "Shpfy Hash";
        HashNumber: Integer;
        OutStream: OutStream;
    begin
        HashNumber := Hash.CalcHash(Data);
        DataCapture.SetRange("Linked To Table", TableNo);
        DataCapture.SetRange("Linked To Id", SystemId);
        if DataCapture.FindLast() and (DataCapture."Hash No." = HashNumber) then
            exit;
        Clear(DataCapture);
        DataCapture."Linked To Table" := TableNo;
        DataCapture."Linked To Id" := SystemId;
        DataCapture."Hash No." := HashNumber;
        DataCapture.Data.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(Data);
        DataCapture.Insert();
    end;

    internal procedure Add(TableNo: Integer; SystemId: Guid; Data: JsonToken)
    begin
        Add(TableNo, SystemId, Format(Data));
    end;

}
