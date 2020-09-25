table 149003 "BCPT Parameter Line"
{
    DataClassification = SystemMetadata;
    Extensible = false;
    Access = Internal;

    fields
    {
        field(1; "Parameter Name"; Text[50])
        {
            Caption = 'Parameter Name';
            DataClassification = CustomerContent;
            NotBlank = true;
            trigger OnValidate()
            begin
                CheckForCommas(Rec."Parameter Name");
            end;
        }
        field(2; "Parameter Value"; Text[250])
        {
            Caption = 'Parameter Value';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CheckForCommas(Rec."Parameter Value");
                Rec."Parameter Value" := copystr(delchr(delchr(CopyStr(rec."Parameter Value", 1, MaxStrLen(rec."Parameter Value"))), '<'), 1, MaxStrLen(Rec."Parameter Value"));
            end;
        }
    }
    keys
    {
        key(Key1; "Parameter Name")
        {
            Clustered = true;
        }
    }

    var
        CommasNotAllowedErr: Label 'Commas are not allowed in parameter names or values.';

    local procedure CheckForCommas(value: Text)
    begin
        if StrPos(value, ',') > 0 then
            Error(CommasNotAllowedErr);
    end;

}