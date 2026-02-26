// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 11704 "VAT Stmt. Form. Drill-Down CZL"
{
    Caption = 'VAT Statement Formula Drill-Down';
    PageType = Worksheet;
    SourceTable = "VAT Statement Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            field(Formula; Formula)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Formula';
                Editable = false;
                ToolTip = 'Specifies the formula of VAT statement.';
            }
            repeater(Lines)
            {
                Editable = false;
                ShowCaption = false;
                field("Row No."; Rec."Row No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a number that identifies the VAT statement line.';
                }
                field("Row Totaling"; Rec."Row Totaling")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a row-number interval or a series of row numbers.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the VAT statement line.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT specification of the involved item or resource to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field(Amount; Amount)
                {
                    AutoFormatExpression = '';
                    AutoFormatType = 1;
                    Caption = 'Amount';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the VAT statement line.';

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDown(VATStmtCalcParametersCZL);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        VATStatementCalculationCZL.CalcLineTotal(Rec, VATStmtCalcParametersCZL, Amount);
        Rec.PrepareAmountToShow(Amount);
        Amount := Amount * Rec.GetPrintSign();
    end;

    var
        VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL";
        VATStatementCalculationCZL: Codeunit "VAT Statement Calculation CZL";
        Formula: Text[250];
        Amount: Decimal;

    internal procedure Initialize(VATStatementLine: Record "VAT Statement Line"; NewVATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL")
    begin
        Formula := VATStatementLine."Row Totaling";
        VATStmtCalcParametersCZL := NewVATStmtCalcParametersCZL;
        VATStatementCalculationCZL.GetLinesFromFormula(VATStatementLine, Rec);
    end;
}
