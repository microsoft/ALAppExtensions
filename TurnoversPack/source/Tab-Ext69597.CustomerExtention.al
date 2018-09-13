tableextension 69597 "RUL CustomerExtention" extends Customer
{
    fields
    {
        field(69592; "RUL G/L Account Filter"; Code[20])
        {
            Caption = 'G/L Account Filter';
            Description = 'RUL';
            FieldClass = FlowFilter;
            TableRelation = "G/L Account";
        }
        field(69593; "RUL G/L Starting Date Filter"; Date)
        {
            Caption = 'G/L Starting Date Filter';
            Description = 'RUL';
            FieldClass = FlowFilter;
        }
        field(69594; "RUL G/L Starting Balance"; Decimal)
        {
            CalcFormula = Sum ("G/L Entry".Amount WHERE ("Source Type" = CONST (Customer),
                                                        "Source No." = FIELD ("No."),
                                                        "G/L Account No." = FIELD ("RUL G/L Account Filter"),
                                                        "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                                                        "Posting Date" = FIELD (UPPERLIMIT ("RUL G/L Starting Date Filter"))));
            Caption = 'G/L Starting Balance';
            Description = 'RUL';
            Editable = false;
            FieldClass = FlowField;
        }
        field(69595; "RUL G/L Net Change"; Decimal)
        {
            CalcFormula = Sum ("G/L Entry".Amount WHERE ("Source Type" = CONST (Customer),
                                                        "Source No." = FIELD ("No."),
                                                        "G/L Account No." = FIELD ("RUL G/L Account Filter"),
                                                        "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                                                        "Posting Date" = FIELD ("Date Filter")));
            Caption = 'G/L Net Change';
            Description = 'RUL';
            Editable = false;
            FieldClass = FlowField;
        }
        field(69596; "RUL G/L Debit Amount"; Decimal)
        {
            CalcFormula = Sum ("G/L Entry"."Debit Amount" WHERE ("Source Type" = CONST (Customer),
                                                                "Source No." = FIELD ("No."),
                                                                "G/L Account No." = FIELD ("RUL G/L Account Filter"),
                                                                "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                                "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                                                                "Posting Date" = FIELD ("Date Filter")));
            Caption = 'G/L Debit Amount';
            Description = 'RUL';
            Editable = false;
            FieldClass = FlowField;
        }
        field(69597; "RUL G/L Credit Amount"; Decimal)
        {
            CalcFormula = Sum ("G/L Entry"."Credit Amount" WHERE ("Source Type" = CONST (Customer),
                                                                 "Source No." = FIELD ("No."),
                                                                 "G/L Account No." = FIELD ("RUL G/L Account Filter"),
                                                                 "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                                 "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                                                                 "Posting Date" = FIELD ("Date Filter")));
            Caption = 'G/L Credit Amount';
            Description = 'RUL';
            Editable = false;
            FieldClass = FlowField;
        }
        field(69598; "RUL G/L Balance to Date"; Decimal)
        {
            CalcFormula = Sum ("G/L Entry".Amount WHERE ("Source Type" = CONST (Customer),
                                                        "Source No." = FIELD ("No."),
                                                        "G/L Account No." = FIELD ("RUL G/L Account Filter"),
                                                        "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                                                        "Posting Date" = FIELD (UPPERLIMIT ("Date Filter"))));
            Caption = 'G/L Balance to Date';
            Description = 'RUL';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}

