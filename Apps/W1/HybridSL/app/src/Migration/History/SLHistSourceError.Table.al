namespace Microsoft.DataMigration.SL;

using Microsoft.DataMigration.SL.HistoricalData;

table 47003 "SL Hist. Source Error"
{
    Caption = 'SL Hist. Source Error';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Table Id"; Integer)
        {
            Caption = 'Table Id';
            NotBlank = true;
        }
        field(2; "Record Id"; Integer)
        {
            Caption = 'Record Id';
            NotBlank = true;
        }
        field(3; Step; enum "SL Hist. Migration Step Type")
        {
            Caption = 'Step';
        }
        field(4; Reference; Text[150])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(5; "Error Code"; Text[100])
        {
            Caption = 'Error Code';
        }
        field(6; "Error Message"; Blob)
        {
            Caption = 'Error Message';
        }
    }
    keys
    {
        key(PK; "Table Id", "Record Id")
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