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
        field(11; "Exception Information"; Blob)
        {
            DataClassification = CustomerContent;
        }
        field(12; "Last Record Under Processing"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Last record under processing';
        }
        field(15; "Records Under Processing Log"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'List of last processed records';
        }
        field(16; "Exception Callstack"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'List of last processed records';
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
        ExceptionMessageInStream.Read(ExceptionMessage);
        exit(ExceptionMessage);
    end;

    procedure GetExceptionCallStack(): Text
    var
        ExceptionCallStackInStream: InStream;
        ExceptionMessage: Text;
    begin
        Rec.CalcFields("Exception Callstack");
        if not Rec."Exception Callstack".HasValue() then
            exit('');

        Rec."Exception Callstack".CreateInStream(ExceptionCallStackInStream, GetDefaultTextEncoding());
        ExceptionCallStackInStream.Read(ExceptionMessage);
        exit(ExceptionMessage);
    end;

    procedure SetFullExceptionMessage(ExceptionMessage: Text)
    var
        ExceptionMessageOutStream: OutStream;
    begin
        Rec."Exception Information".CreateOutStream(ExceptionMessageOutStream, GetDefaultTextEncoding());
        ExceptionMessageOutStream.Write(ExceptionMessage);
        Rec.Modify(true);
    end;

    procedure SetExceptionCallStack(ExceptionMessage: Text)
    var
        ExceptionMessageOutStream: OutStream;
    begin
        Rec."Exception Callstack".CreateOutStream(ExceptionMessageOutStream, GetDefaultTextEncoding());
        ExceptionMessageOutStream.Write(ExceptionMessage);
        Rec.Modify(true);
    end;

    procedure SetLastRecordUnderProcessingLog(RecordsUnderProcessingLog: Text)
    var
        RecordsUnderProcessingOutStreamLog: OutStream;
    begin
        Rec."Records Under Processing Log".CreateOutStream(RecordsUnderProcessingOutStreamLog, GetDefaultTextEncoding());
        RecordsUnderProcessingOutStreamLog.Write(RecordsUnderProcessingLog);
        Rec.Modify(true);
    end;

    procedure GetLastRecordsUnderProcessingLog(): Text
    var
        RecordsUnderProcessingLogInStream: InStream;
        RecordsUnderProcessingLog: Text;
    begin
        Rec.CalcFields("Records Under Processing Log");
        if not Rec."Records Under Processing Log".HasValue() then
            exit('');

        Rec."Records Under Processing Log".CreateInStream(RecordsUnderProcessingLogInStream, GetDefaultTextEncoding());
        RecordsUnderProcessingLogInStream.Read(RecordsUnderProcessingLog);
        exit(RecordsUnderProcessingLog);
    end;

    local procedure GetDefaultTextEncoding(): TextEncoding
    begin
        exit(TEXTENCODING::UTF16);
    end;
}