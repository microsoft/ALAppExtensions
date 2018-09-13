tableextension 69595 "RUL GLAccountExtention" extends "G/L Account"
{
    fields
    {
        field(69587; "RUL Net Change (ACY)"; Decimal)
        {
            //AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 1;
            CalcFormula = Sum ("G/L Entry"."Additional-Currency Amount" WHERE ("G/L Account No." = FIELD ("No."),
                                                                              "G/L Account No." = FIELD (FILTER (Totaling)),
                                                                              "Business Unit Code" = FIELD ("Business Unit Filter"),
                                                                              "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                                              "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                                                                              "Posting Date" = FIELD ("Date Filter"),
                                                                              "Source Type" = FIELD ("RUL Source Type Filter"),
                                                                              "Source No." = FIELD ("RUL Source No. Filter")));
            Caption = 'Additional-Currency Net Change';
            Description = 'RUL';
            Editable = false;
            FieldClass = FlowField;
        }
        field(69588; "RUL Debit Amount (ACY)"; Decimal)
        {
            //AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 1;
            CalcFormula = Sum ("G/L Entry"."Add.-Currency Debit Amount" WHERE ("G/L Account No." = FIELD ("No."),
                                                                              "G/L Account No." = FIELD (FILTER (Totaling)),
                                                                              "Business Unit Code" = FIELD ("Business Unit Filter"),
                                                                              "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                                              "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                                                                              "Posting Date" = FIELD ("Date Filter"),
                                                                              "Source Type" = FIELD ("RUL Source Type Filter"),
                                                                              "Source No." = FIELD ("RUL Source No. Filter")));
            Caption = 'Add.-Currency Debit Amount';
            Description = 'RUL';
            Editable = false;
            FieldClass = FlowField;
        }
        field(69589; "RUL Credit Amount (ACY)"; Decimal)
        {
            //AutoFormatExpression = GetCurrencyCode;
            AutoFormatType = 1;
            CalcFormula = Sum ("G/L Entry"."Add.-Currency Credit Amount" WHERE ("G/L Account No." = FIELD ("No."),
                                                                               "G/L Account No." = FIELD (FILTER (Totaling)),
                                                                               "Business Unit Code" = FIELD ("Business Unit Filter"),
                                                                               "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                                               "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                                                                               "Posting Date" = FIELD ("Date Filter"),
                                                                               "Source Type" = FIELD ("RUL Source Type Filter"),
                                                                               "Source No." = FIELD ("RUL Source No. Filter")));
            Caption = 'Add.-Currency Credit Amount';
            Description = 'RUL';
            Editable = false;
            FieldClass = FlowField;
        }
        field(69590; "RUL Debit Amount"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum ("G/L Entry"."Debit Amount" WHERE ("G/L Account No." = FIELD ("No."),
                                                                "G/L Account No." = FIELD (FILTER (Totaling)),
                                                                "Business Unit Code" = FIELD ("Business Unit Filter"),
                                                                "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                                "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                                                                "Posting Date" = FIELD ("Date Filter"),
                                                                "Source Type" = FIELD (FILTER ("RUL Source Type Filter")),
                                                                "Source No." = FIELD (FILTER ("RUL Source No. Filter"))));
            Caption = 'Debit Amount';
            Description = 'RUL';
            Editable = false;
            FieldClass = FlowField;
        }
        field(69591; "RUL Credit Amount"; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum ("G/L Entry"."Credit Amount" WHERE ("G/L Account No." = FIELD ("No."),
                                                                 "G/L Account No." = FIELD (FILTER (Totaling)),
                                                                 "Business Unit Code" = FIELD ("Business Unit Filter"),
                                                                 "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                                 "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                                                                 "Posting Date" = FIELD ("Date Filter"),
                                                                 "Source Type" = FIELD ("RUL Source Type Filter"),
                                                                 "Source No." = FIELD ("RUL Source No. Filter")));
            Caption = 'Credit Amount';
            Description = 'RUL';
            Editable = false;
            FieldClass = FlowField;
        }
        field(69592; "RUL Credit Amount at Date"; Decimal)
        {
            CalcFormula = Sum ("G/L Entry"."Credit Amount" WHERE ("G/L Account No." = FIELD ("No."),
                                                                 "G/L Account No." = FIELD (FILTER (Totaling)),
                                                                 "Business Unit Code" = FIELD ("Business Unit Filter"),
                                                                 "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                                 "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                                                                 "Posting Date" = FIELD (UPPERLIMIT ("Date Filter")),
                                                                 "Source Type" = FIELD ("RUL Source Type Filter"),
                                                                 "Source No." = FIELD ("RUL Source No. Filter")));
            Caption = 'Credit Amount at Date';
            Description = 'RUL';
            Editable = false;
            FieldClass = FlowField;
        }
        field(69593; "RUL Debit Amount at Date"; Decimal)
        {
            CalcFormula = Sum ("G/L Entry"."Debit Amount" WHERE ("G/L Account No." = FIELD ("No."),
                                                                "G/L Account No." = FIELD (FILTER (Totaling)),
                                                                "Business Unit Code" = FIELD ("Business Unit Filter"),
                                                                "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                                "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                                                                "Posting Date" = FIELD (UPPERLIMIT ("Date Filter")),
                                                                "Source Type" = FIELD ("RUL Source Type Filter"),
                                                                "Source No." = FIELD ("RUL Source No. Filter")));
            Caption = 'Debit Amount at Date';
            Description = 'RUL';
            Editable = false;
            FieldClass = FlowField;
        }
        field(69594; "RUL Source Type"; Option)
        {
            Caption = 'Source Type';
            Description = 'RUL';
            OptionCaption = ' ,Customer,Vendor';
            OptionMembers = " ",Customer,Vendor;
        }
        field(69595; "RUL Source Type Filter"; Option)
        {
            Caption = 'Source Type Filter';
            Description = 'RUL';
            FieldClass = FlowFilter;
            OptionCaption = ' ,Customer,Vendor,Bank Account,Fixed Asset';
            OptionMembers = " ",Customer,Vendor,"Bank Account","Fixed Asset";
        }
        field(69596; "RUL Source No. Filter"; Code[20])
        {
            Caption = 'Source No. Filter';
            Description = 'RUL';
            FieldClass = FlowFilter;
            TableRelation = IF ("RUL Source Type Filter" = FILTER (Customer)) Customer
            ELSE
            IF ("RUL Source Type Filter" = FILTER (Vendor)) Vendor
            ELSE
            IF ("RUL Source Type Filter" = FILTER ("Bank Account")) "Bank Account"
            ELSE
            IF ("RUL Source Type Filter" = FILTER ("Fixed Asset")) "Fixed Asset";
        }
        field(69597; "RUL Balance at Date"; Decimal)
        {
            CalcFormula = Sum ("G/L Entry".Amount WHERE ("G/L Account No." = FIELD ("No."),
                                                        "G/L Account No." = FIELD (FILTER (Totaling)),
                                                        "Business Unit Code" = FIELD ("Business Unit Filter"),
                                                        "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                                                        "Posting Date" = FIELD (UPPERLIMIT ("Date Filter")),
                                                        "Source Type" = FIELD ("RUL Source Type Filter"),
                                                        "Source No." = FIELD ("RUL Source No. Filter")));
            Caption = 'Balance at Date';
            Description = 'RUL';
            Editable = false;
            FieldClass = FlowField;
        }
        field(69598; "RUL Balance at Date (ACY)"; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode;
            CalcFormula = Sum ("G/L Entry"."Additional-Currency Amount" WHERE ("G/L Account No." = FIELD ("No."),
                                                                              "G/L Account No." = FIELD (FILTER (Totaling)),
                                                                              "Business Unit Code" = FIELD ("Business Unit Filter"),
                                                                              "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                                              "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                                                                              "Posting Date" = FIELD (UPPERLIMIT ("Date Filter")),
                                                                              "Source Type" = FIELD ("RUL Source Type Filter"),
                                                                              "Source No." = FIELD ("RUL Source No. Filter")));
            Caption = 'Add.-Currency Balance at Date';
            Description = 'RUL';
            Editable = false;
            FieldClass = FlowField;
        }
        field(69599; "RUL Net Change"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum ("G/L Entry".Amount WHERE ("G/L Account No." = FIELD ("No."),
                                                        "G/L Account No." = FIELD (FILTER (Totaling)),
                                                        "Business Unit Code" = FIELD ("Business Unit Filter"),
                                                        "Global Dimension 1 Code" = FIELD ("Global Dimension 1 Filter"),
                                                        "Global Dimension 2 Code" = FIELD ("Global Dimension 2 Filter"),
                                                        "Posting Date" = FIELD ("Date Filter"),
                                                        "Source Type" = FIELD ("RUL Source Type Filter"),
                                                        "Source No." = FIELD ("RUL Source No. Filter")));
            Caption = 'Net Change';
            Description = 'RUL';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}

