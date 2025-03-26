table 6108 "E-Doc. Account Payable Cue"
{
    Caption = 'E-Doc. Account Payable Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            AllowInCustomizations = Never;
            Caption = 'Primary Key';
        }
        field(2; "Purchase This Month"; Decimal)
        {
            AutoFormatExpression = GetAmountFormat();
            AutoFormatType = 11;
            Caption = 'Sales This Month';
            DecimalPlaces = 0 : 0;
        }
        field(110; "Last Date/Time Modified"; DateTime)
        {
            Caption = 'Last Date/Time Modified';
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetAmountFormat(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.GetAmountFormatLCYWithUserLocale());
    end;
}
