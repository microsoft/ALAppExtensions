namespace Microsoft.DataMigration.GP;

table 41102 "GP 1099 Migration Log"
{
    Caption = 'GP 1099 Migration Log';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
        }
        field(3; "GP 1099 Type"; Integer)
        {
            Caption = 'GP 1099 Type';
        }
        field(4; "GP 1099 Box No."; Integer)
        {
            Caption = 'GP 1099 Box No.';
        }
        field(5; "BC IRS 1099 Code"; Code[10])
        {
            Caption = 'BC IRS 1099 Code';
        }
        field(6; IsError; Boolean)
        {
            Caption = 'Error';
        }
        field(7; WasSkipped; Boolean)
        {
            Caption = 'Skipped';
        }
        field(8; "Error Code"; Text[100])
        {
            Caption = 'Error Code';
        }
        field(9; "Error Message"; Blob)
        {
            Caption = 'Error Message';
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure SetErrorMessage(ErrorMessageText: Text)
    var
        ErrorMessageOutStream: OutStream;
    begin
        Rec."Error Message".CreateOutStream(ErrorMessageOutStream);
        ErrorMessageOutStream.WriteText(ErrorMessageText);
    end;

    procedure GetErrorMessage(): Text
    var
        ErrorMessageInStream: InStream;
        ReturnText: Text;
    begin
        CalcFields(Rec."Error Message");
        if Rec."Error Message".HasValue() then begin
            Rec."Error Message".CreateInStream(ErrorMessageInStream);
            ErrorMessageInStream.ReadText(ReturnText);
        end;

        exit(ReturnText)
    end;
}