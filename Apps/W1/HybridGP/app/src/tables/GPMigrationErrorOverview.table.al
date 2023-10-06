table 40141 "GP Migration Error Overview"
{
    ReplicateData = false;
    Extensible = false;
    DataPerCompany = false;

    fields
    {
        field(1; Id; Integer)
        {
            AutoIncrement = true;
            Caption = 'Id';
            DataClassification = SystemMetadata;
        }
        field(2; "Migration Type"; Text[250])
        {
            Caption = 'Migration Type';
            DataClassification = SystemMetadata;
        }
        field(3; "Destination Table ID"; Integer)
        {
            Caption = 'Destination Table ID';
            DataClassification = SystemMetadata;
        }
        field(4; "Source Staging Table Record ID"; RecordID)
        {
            Caption = 'Source Staging Table Record ID';
            DataClassification = CustomerContent;
        }
        field(5; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(6; "Scheduled For Retry"; Boolean)
        {
            Caption = 'Scheduled For Retry';
            DataClassification = SystemMetadata;
        }
        field(9; "Error Dismissed"; Boolean)
        {
            Caption = 'Error Dismissed';
            DataClassification = SystemMetadata;
        }
        field(11; "Exception Information"; BLOB)
        {
            DataClassification = CustomerContent;
        }
        field(12; "Last Record Under Processing"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Last record under processing';
        }
        field(50; "Company Name"; Text[30])
        {
            Caption = 'Company';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Id", "Company Name")
        {
            Clustered = true;
        }
    }

    procedure GetFullExceptionMessage(): Text
    var
        ExceptionMessageInStream: InStream;
        ExceptionMessage: Text;
    begin
        Rec.CalcFields("Exception Information");
        if not Rec."Exception Information".HasValue() then
            exit('');

        Rec."Exception Information".CreateInStream(ExceptionMessageInStream, GetDefaultTextEncoding());
        ExceptionMessageInStream.ReadText(ExceptionMessage);
        exit(ExceptionMessage);
    end;

    procedure SetFullExceptionMessage(ExceptionMessage: Text)
    var
        ExceptionMessageOutStream: OutStream;
    begin
        Rec."Exception Information".CreateOutStream(ExceptionMessageOutStream, GetDefaultTextEncoding());
        ExceptionMessageOutStream.WriteText(ExceptionMessage);
        Rec.Modify(true);
    end;

    local procedure GetDefaultTextEncoding(): TextEncoding
    begin
        exit(TEXTENCODING::UTF16);
    end;
}