// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.ExcelReports;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Consolidation;

table 4402 "EXR Trial Balance Buffer"
{
    Caption = 'Trial Balance Buffer';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
        }
        field(2; "Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Dimension 1 Code';
        }
        field(3; "Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Dimension 2 Code';
        }
        field(4; "Period Start"; Date)
        {
            Caption = 'Period Start';
        }
        field(5; "Period End"; Date)
        {
            Caption = 'Period End';
        }
        field(10; "Net Change"; Decimal)
        {
            Caption = 'Net Change';

            trigger OnValidate()
            begin
                if ("Net Change" > 0) then begin
                    Validate("Net Change (Debit)", "Net Change");
                    Validate("Net Change (Credit)", 0);
                end
                else begin
                    Validate("Net Change (Credit)", -"Net Change");
                    Validate("Net Change (Debit)", 0);
                end;
            end;
        }
        field(11; "Net Change (Debit)"; Decimal)
        {
            Caption = 'Net Change (Debit)';
        }
        field(12; "Net Change (Credit)"; Decimal)
        {
            Caption = 'Net Change (Credit)';
        }
        field(13; Balance; Decimal)
        {
            Caption = 'Balance';

            trigger OnValidate()
            begin
                if ("Balance" > 0) then begin
                    Validate("Balance (Debit)", "Balance");
                    Validate("Balance (Credit)", 0);
                end
                else begin
                    Validate("Balance (Credit)", -"Balance");
                    Validate("Balance (Debit)", 0);
                end;
            end;
        }
        field(14; "Balance (Debit)"; Decimal)
        {
            Caption = 'Balance (Debit)';
        }
        field(15; "Balance (Credit)"; Decimal)
        {
            Caption = 'Balance (Credit)';
        }
        field(20; "Budget (Net)"; Decimal)
        {
            Caption = 'Budget';
        }
        field(21; "% of Budget Net"; Decimal)
        {
            Caption = '% of Budget Net';
        }
        field(22; "Budget (Bal. at Date)"; Decimal)
        {
            Caption = 'Budget (Bal. at Date)';
        }
        field(23; "% of Budget Bal."; Decimal)
        {
            Caption = '% of Budget Bal.';
        }
        field(50; "Last Period Net"; Decimal)
        {
            Caption = 'Last Period Net';

            trigger OnValidate()
            begin
                if ("Last Period Net" > 0) then begin
                    Validate("Last Period Net (Debit)", "Last Period Net");
                    Validate("Last Period Net (Credit)", 0);
                end
                else begin
                    Validate("Last Period Net (Credit)", -"Last Period Net");
                    Validate("Last Period Net (Debit)", 0);
                end;
            end;
        }
        field(51; "Last Period Net (Debit)"; Decimal)
        {
            Caption = 'Last Period Net (Debit)';
        }
        field(52; "Last Period Net (Credit)"; Decimal)
        {
            Caption = 'Last Period Net (Credit)';
        }
        field(60; "Last Period Bal."; Decimal)
        {
            Caption = 'Last Period Bal.';

            trigger OnValidate()
            begin
                if ("Last Period Bal." > 0) then begin
                    Validate("Last Period Bal. (Debit)", "Last Period Bal.");
                    Validate("Last Period Bal. (Credit)", 0);
                end
                else begin
                    Validate("Last Period Bal. (Credit)", -"Last Period Bal.");
                    Validate("Last Period Bal. (Debit)", 0);
                end;
            end;
        }
        field(61; "Last Period Bal. (Debit)"; Decimal)
        {
            Caption = 'Last Period Bal. (Debit)';
        }
        field(62; "Last Period Bal. (Credit)"; Decimal)
        {
            Caption = 'Last Period Bal. (Credit)';
        }
        field(70; "Net Variance"; Decimal)
        {
            Caption = 'Net Variance';
        }
        field(71; "% of Net Variance"; Decimal)
        {
            Caption = '% of Net Variance';
        }
        field(80; "Bal. Variance"; Decimal)
        {
            Caption = 'Bal. Variance';
        }
        field(81; "% of Bal. Variance"; Decimal)
        {
            Caption = '% of Bal. Variance';
        }
        field(110; "Net Change (ACY)"; Decimal)
        {
            Caption = 'Net Change';

            trigger OnValidate()
            begin
                if ("Net Change" > 0) then begin
                    Validate("Net Change (Debit) (ACY)", "Net Change (ACY)");
                    Validate("Net Change (Credit) (ACY)", 0);
                end
                else begin
                    Validate("Net Change (Credit) (ACY)", -"Net Change (ACY)");
                    Validate("Net Change (Debit) (ACY)", 0);
                end;
            end;
        }
        field(111; "Net Change (Debit) (ACY)"; Decimal)
        {
            Caption = 'Net Change (Debit)';
        }
        field(112; "Net Change (Credit) (ACY)"; Decimal)
        {
            Caption = 'Net Change (Credit)';
        }
        field(113; "Balance (ACY)"; Decimal)
        {
            Caption = 'Balance';

            trigger OnValidate()
            begin
                if ("Balance" > 0) then begin
                    Validate("Balance (Debit) (ACY)", "Balance (ACY)");
                    Validate("Balance (Credit) (ACY)", 0);
                end
                else begin
                    Validate("Balance (Credit) (ACY)", -"Balance (ACY)");
                    Validate("Balance (Debit) (ACY)", 0);
                end;
            end;
        }
        field(114; "Balance (Debit) (ACY)"; Decimal)
        {
            Caption = 'Balance (Debit)';
        }
        field(115; "Balance (Credit) (ACY)"; Decimal)
        {
            Caption = 'Balance (Credit)';
        }
        field(150; "Last Period Net (ACY)"; Decimal)
        {
            Caption = 'Last Period Net';

            trigger OnValidate()
            begin
                if ("Last Period Net" > 0) then begin
                    Validate("Last Period Net (Debit) (ACY)", "Last Period Net (ACY)");
                    Validate("Last Period Net (Credit) (ACY)", 0);
                end
                else begin
                    Validate("Last Period Net (Credit) (ACY)", -"Last Period Net (ACY)");
                    Validate("Last Period Net (Debit) (ACY)", 0);
                end;
            end;
        }
        field(151; "Last Period Net (Debit) (ACY)"; Decimal)
        {
            Caption = 'Last Period Net (Debit)';
        }
        field(152; "Last Period Net (Credit) (ACY)"; Decimal)
        {
            Caption = 'Last Period Net (Credit)';
        }
        field(160; "Last Period Bal. (ACY)"; Decimal)
        {
            Caption = 'Last Period Bal.';

            trigger OnValidate()
            begin
                if ("Last Period Bal." > 0) then begin
                    Validate("Last Period Bal. (Debit) (ACY)", "Last Period Bal. (ACY)");
                    Validate("Last Period Bal. (Cred.) (ACY)", 0);
                end
                else begin
                    Validate("Last Period Bal. (Cred.) (ACY)", -"Last Period Bal. (ACY)");
                    Validate("Last Period Bal. (Debit) (ACY)", 0);
                end;
            end;
        }
        field(161; "Last Period Bal. (Debit) (ACY)"; Decimal)
        {
            Caption = 'Last Period Bal. (Debit)';
        }
        field(162; "Last Period Bal. (Cred.) (ACY)"; Decimal)
        {
            Caption = 'Last Period Bal. (Credit)';
        }
        field(170; "Net Variance (ACY)"; Decimal)
        {
            Caption = 'Net Variance';
        }
        field(171; "% of Net Variance (ACY)"; Decimal)
        {
            Caption = '% of Net Variance';
        }
        field(180; "Bal. Variance (ACY)"; Decimal)
        {
            Caption = 'Bal. Variance';
        }
        field(181; "% of Bal. Variance (ACY)"; Decimal)
        {
            Caption = '% of Bal. Variance';
        }
        field(200; "All Zero"; Boolean)
        {
            Caption = 'All Zero';
        }
        field(201; "Business Unit Code"; Code[20])
        {
            Caption = 'Business Unit Code';
            TableRelation = "Business Unit";
            ValidateTableRelation = false;
        }
        field(1000; "Account Type"; Enum "G/L Account Type")
        {
            CalcFormula = lookup("G/L Account"."Account Type" where("No." = field("G/L Account No.")));
            Caption = 'Account Type';
            Editable = false;
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(PK; "G/L Account No.", "Dimension 1 Code", "Dimension 2 Code", "Business Unit Code", "Period Start")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        CheckAllZero();
    end;

    trigger OnModify()
    begin
        CheckAllZero();
    end;

    internal procedure CalculateVariances()
    begin
        if ("Net Change" <> 0) and ("Last Period Net" <> 0) then begin
            "Net Variance" := "Net Change" - "Last Period Net";
            "% of Net Variance" := "Net Variance" / "Last Period Net";
        end;
        if ("Balance" <> 0) and ("Last Period Bal." <> 0) then begin
            "Bal. Variance" := "Balance" - "Last Period Bal.";
            "% of Bal. Variance" := "Bal. Variance" / "Last Period Bal.";
        end;
        if ("Net Change (ACY)" <> 0) and ("Last Period Net (ACY)" <> 0) then begin
            "Net Variance (ACY)" := "Net Change (ACY)" - "Last Period Net (ACY)";
            "% of Net Variance (ACY)" := "Net Variance (ACY)" / "Last Period Net (ACY)";
        end;
        if ("Balance (ACY)" <> 0) and ("Last Period Bal. (ACY)" <> 0) then begin
            "Bal. Variance (ACY)" := "Balance (ACY)" - "Last Period Bal. (ACY)";
            "% of Bal. Variance (ACY)" := "Bal. Variance (ACY)" / "Last Period Bal. (ACY)";
        end;
    end;

    internal procedure CalculateBudgetComparisons()
    begin
        // and budget % comparison
        if ("Budget (Net)" <> 0) and ("Net Change" <> 0) then
            "% of Budget Net" := "Net Change" / "Budget (Net)";
        if ("Budget (Bal. at Date)" <> 0) and ("Balance" <> 0) then
            "% of Budget Bal." := "Balance" / "Budget (Bal. at Date)";
    end;

    internal procedure CalculatePriorComparisons()
    begin
        if ("Net Change" <> 0) and ("Last Period Net" <> 0) then
            "% of Net Variance" := "Net Change" / "Last Period Net";
        if ("Balance" <> 0) and ("Last Period Bal." <> 0) then
            "% of Bal. Variance" := "Balance" / "Last Period Bal.";
        if ("Net Change (ACY)" <> 0) and ("Last Period Net (ACY)" <> 0) then
            "% of Net Variance (ACY)" := "Net Change (ACY)" / "Last Period Net (ACY)";
        if ("Balance (ACY)" <> 0) and ("Last Period Bal. (ACY)" <> 0) then
            "% of Bal. Variance (ACY)" := "Balance (ACY)" / "Last Period Bal. (ACY)";
    end;

    internal procedure CheckAllZero()
    begin
        // if all the key values are zero, then set the All Zero field to true
        "All Zero" := ("Net Change" = 0) and
            ("Balance" = 0) and
            ("Budget (Net)" = 0) and
            ("Last Period Net" = 0) and
            ("Last Period Bal." = 0) and
            ("Net Variance" = 0) and
            ("Bal. Variance" = 0) and
            ("Net Change (ACY)" = 0) and
            ("Balance (ACY)" = 0) and
            ("Last Period Net (ACY)" = 0) and
            ("Last Period Bal. (ACY)" = 0) and
            ("Net Variance (ACY)" = 0) and
            ("Bal. Variance (ACY)" = 0);
    end;
}
