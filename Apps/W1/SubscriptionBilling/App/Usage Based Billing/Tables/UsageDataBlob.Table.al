namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using System.Security.Encryption;

table 8011 "Usage Data Blob"
{
    Caption = 'Usage Data Blob';
    DataClassification = CustomerContent;
    LookupPageId = "Usage Data Blobs";
    DrillDownPageId = "Usage Data Blobs";
    Access = Internal;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Usage Data Import Entry No."; Integer)
        {
            Caption = 'Usage Data Import Entry No.';
            TableRelation = "Usage Data Import";
        }
        field(3; Description; Text[250])
        {
            Caption = 'Description';
        }
        field(4; "Import Date"; Date)
        {
            Caption = 'Import Date';
        }
        field(5; "Import Status"; Enum "Processing Status")
        {
            Caption = 'Import Status';

            trigger OnValidate()
            begin
                if "Import Status" = Enum::"Processing Status"::None then begin
                    Clear(Reason);
                    Clear("Reason (Preview)");
                end;
            end;
        }
        field(6; "Reason (Preview)"; Text[80])
        {
            Caption = 'Reason (Preview)';
            Editable = false;

            trigger OnLookup()
            begin
                ShowReason();
            end;
        }
        field(7; Reason; Blob)
        {
            Caption = 'Reason';
            Compressed = false;
        }
        field(8; Source; Text[250])
        {
            Caption = 'Source';
        }
        field(9; "Data Hash Value"; Text[50])
        {
            Caption = 'Data Hash Value';
        }
        field(10; Data; Blob)
        {
            Caption = 'Data';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
    internal procedure ComputeHashValue()
    var
        CryptographyMgmt: Codeunit "Cryptography Management";
        InStream: InStream;
    begin
        Rec.Data.CreateInStream(InStream);
        Rec."Data Hash Value" := CopyStr(CryptographyMgmt.GenerateHash(InStream, 0), 1, MaxStrLen(Rec."Data Hash Value")); //HMACMD5
    end;

    internal procedure InsertFromUsageDataImport(UsageDataImport: Record "Usage Data Import")
    begin
        Rec.Init();
        Rec."Entry No." := 0;
        Rec."Usage Data Import Entry No." := UsageDataImport."Entry No.";
        Rec.Insert(false);
    end;

    internal procedure ImportFromFile(InStream: InStream; FilePath: Text)
    var
        OutStream: OutStream;
    begin
        Rec.Data.CreateOutStream(OutStream);
        CopyStream(OutStream, InStream);
        Rec.ComputeHashValue();
        Rec.Source := CopyStr(FilePath, 1, MaxStrLen(Rec.Source));
        Rec."Import Date" := Today();
        Rec."Import Status" := "Processing Status"::Ok;
        Rec.Modify(false);
    end;

    internal procedure SetDataFieldFromBlob(TempBlob: Codeunit "Temp Blob")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecordRef, FieldNo(Rec.Data));
        RecordRef.SetTable(Rec);
    end;

    internal procedure ShowReason()
    var
        TextManagement: Codeunit "Text Management";
        RRef: RecordRef;
    begin
        CalcFields(Reason);
        RRef.GetTable(Rec);
        TextManagement.ShowFieldText(RRef, FieldNo(Reason));
    end;
}
