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
            Caption = 'Purchase This Month';
            DecimalPlaces = 0 : 0;
            FieldClass = FlowField;
            CalcFormula =
                Sum("Vendor Ledger Entry"."Purchase (LCY)"
                    where(
                    "Document Type" = filter(Invoice | "Credit Memo"),
                    "Posting Date" = field("Posting Date Filter"),
                    Open = const(true)));
        }
        field(3; "Posting Date Filter"; Date)
        {
            Caption = 'Posting Date Filter';
            FieldClass = FlowFilter;
        }
        field(5; "Overdue Purchase Documents"; Integer)
        {
            CalcFormula =
                count("Vendor Ledger Entry"
                where(
                    "Document Type" = filter(Invoice | "Credit Memo"),
                    "Due Date" = field("Overdue Date Filter"),
                    Open = const(true)));
            Caption = 'Overdue Purchase Documents';
            FieldClass = FlowField;
        }
        field(6; "Overdue Date Filter"; Date)
        {
            Caption = 'Overdue Date Filter';
            FieldClass = FlowFilter;
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

    internal procedure GetAmountFormat(): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(TypeHelper.GetAmountFormatLCYWithUserLocale());
    end;

    internal procedure GetDefaultWorkDate(): Date
    var
        LogInManagement: Codeunit LogInManagement;
    begin
        // TODO uncomment
        // if this.DefaultWorkDate = 0D then
        //     this.DefaultWorkDate := LogInManagement.GetDefaultWorkDate();
        // exit(this.DefaultWorkDate);
        exit(WorkDate());
    end;

    var
        DefaultWorkDate: Date;
}
