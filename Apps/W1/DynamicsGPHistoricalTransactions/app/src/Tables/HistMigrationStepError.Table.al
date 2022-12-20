table 40911 "Hist. Migration Step Error"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; Step; enum "Hist. Migration Step Type")
        {
            Caption = 'Step';
            DataClassification = SystemMetadata;
            NotBlank = true;
        }
        field(3; Reference; Text[150])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(4; "Error Code"; Text[100])
        {
            Caption = 'Error Code';
            DataClassification = SystemMetadata;
        }
        field(5; "Error Message"; Blob)
        {
            Caption = 'Error Message';
            DataClassification = SystemMetadata;
        }
        field(6; "Error Date"; DateTime)
        {
            Caption = 'Error Date';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
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