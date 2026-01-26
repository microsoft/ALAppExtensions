namespace Microsoft.DataMigration.SL;

table 47001 "SL Hist. Source Progress"
{
    Caption = 'SL Hist. Source Progress';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Table Id"; Integer)
        {
            Caption = 'Table Id';
            NotBlank = true;
        }
        field(2; "Last Processed Record Id"; Integer)
        {
            Caption = 'Last Processed Record Id';
        }
    }
    keys
    {
        key(PK; "Table Id")
        {
            Clustered = true;
        }
    }

    procedure InitForTable(TableId: Integer)
    begin
        if not Rec.Get(TableId) then begin
            Rec."Table Id" := TableId;
            Rec."Last Processed Record Id" := 0;
            Rec.Insert();
        end;
    end;

    procedure SetLastProcessedRecId(TableId: Integer; RecId: Integer)
    begin
        InitForTable(TableId);
        Rec."Last Processed Record Id" := RecId;
        Rec.Modify();
    end;

    procedure GetLastProcessedRecId(TableId: Integer): Integer
    begin
        InitForTable(TableId);
        exit(Rec."Last Processed Record Id");
    end;
}