// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.Currency;
using Microsoft.Finance.VAT.Calculation;

page 31164 "Cash Document Statistics CZP"
{
    Caption = 'Cash Document Statistics';
    Editable = false;
    PageType = ListPlus;
    SourceTable = "Cash Document Line CZP";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(Document)
            {
                Caption = 'Document';
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Lookup = false;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                }
                field(AmountExclVAT; AmountExclVAT)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount Excluding VAT';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies cash document amount. The amount is excluding VAT.';
                }
                field(VATAmount; VATAmount)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    Caption = 'VAT amount';
                    Editable = false;
                    ToolTip = 'Specifies cash document amount.';
                }
                field(AmountInclVAT; AmountInclVAT)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount Including VAT';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies cash document amount. The amount is including VAT.';
                }
                field(AmountExclVATLCY; AmountExclVATLCY)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount Excluding VAT (LCY)';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies cash document amount. The amount is excluding VAT in the local currency.';
                }
                field(VATAmountLCY; VATAmountLCY)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    Caption = 'VAT amount (LCY)';
                    Editable = false;
                    ToolTip = 'Specifies cash document amount. The amount is in the local currency.';
                }
                field(AmountInclVATLCY; AmountInclVATLCY)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount Including VAT (LCY)';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies cash document amount. The amount is including VAT in the local currency.';
                }
                field(NoOfVATLines_Document; TempVATAmountLine.Count)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'No. of VAT Lines';
                    DrillDown = true;
                    ToolTip = 'Specifies the number of VAT lines.';

                    trigger OnDrillDown()
                    begin
                        VATLinesDrillDown(TempVATAmountLine, false);
                        UpdateHeaderInfo();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CashDocumentHeaderCZP.Get(Rec."Cash Desk No.", Rec."Cash Document No.");
        UpdateLine(TempVATAmountLine);
        UpdateHeaderInfo();
    end;

    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        Currency: Record Currency;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        VATAmountLines: Page "VAT Amount Lines";
        AllowVATDifference: Boolean;
        AmountExclVAT: Decimal;
        VATAmount: Decimal;
        AmountInclVAT: Decimal;
        AmountExclVATLCY: Decimal;
        VATAmountLCY: Decimal;
        AmountInclVATLCY: Decimal;

    local procedure UpdateHeaderInfo()
    var
        TotalCashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        TotalCashDocumentLineCZP.Reset();
        TotalCashDocumentLineCZP.SetRange("Cash Desk No.", Rec."Cash Desk No.");
        TotalCashDocumentLineCZP.SetRange("Cash Document No.", Rec."Cash Document No.");

        TotalCashDocumentLineCZP.CalcSums(
          TotalCashDocumentLineCZP."VAT Base Amount",
          TotalCashDocumentLineCZP."Amount Including VAT",
          TotalCashDocumentLineCZP."VAT Base Amount (LCY)",
          TotalCashDocumentLineCZP."Amount Including VAT (LCY)");

        AmountExclVAT := TotalCashDocumentLineCZP."VAT Base Amount";
        AmountInclVAT := TotalCashDocumentLineCZP."Amount Including VAT";
        VATAmount := AmountInclVAT - AmountExclVAT;
        AmountExclVATLCY := TotalCashDocumentLineCZP."VAT Base Amount (LCY)";
        AmountInclVATLCY := TotalCashDocumentLineCZP."Amount Including VAT (LCY)";
        VATAmountLCY := AmountInclVATLCY - AmountExclVATLCY;
    end;

    procedure UpdateLine(var VATAmountLine: Record "VAT Amount Line")
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        if CashDocumentHeaderCZP."Currency Code" = '' then
            Currency.InitRoundingPrecision()
        else
            Currency.Get(CashDocumentHeaderCZP."Currency Code");

        VATAmountLine.DeleteAll();

        CashDocumentLineCZP.SetRange(CashDocumentLineCZP."Cash Desk No.", Rec."Cash Desk No.");
        CashDocumentLineCZP.SetRange(CashDocumentLineCZP."Cash Document No.", Rec."Cash Document No.");
        CashDocumentLineCZP.SetFilter(CashDocumentLineCZP."Account Type", '>0');
        if CashDocumentLineCZP.FindSet() then
            repeat
                if CashDocumentLineCZP."VAT Calculation Type" in [CashDocumentLineCZP."VAT Calculation Type"::"Reverse Charge VAT", CashDocumentLineCZP."VAT Calculation Type"::"Sales Tax"] then
                    CashDocumentLineCZP."VAT %" := 0;
                if not VATAmountLine.Get(CashDocumentLineCZP."VAT Identifier", CashDocumentLineCZP."VAT Calculation Type", '', false, CashDocumentLineCZP.Amount >= 0) then begin
                    VATAmountLine.Init();
                    VATAmountLine."VAT Identifier" := CashDocumentLineCZP."VAT Identifier";
                    VATAmountLine."VAT Calculation Type" := CashDocumentLineCZP."VAT Calculation Type";
                    VATAmountLine."VAT %" := CashDocumentLineCZP."VAT %";
                    VATAmountLine.Modified := true;
                    VATAmountLine.Positive := CashDocumentLineCZP.Amount >= 0;
                    VATAmountLine.Insert();
                end;

                VATAmountLine."Line Amount" += CashDocumentLineCZP.Amount;
                VATAmountLine."VAT Base" += CashDocumentLineCZP."VAT Base Amount";
                VATAmountLine."VAT Amount" += CashDocumentLineCZP."Amount Including VAT" - CashDocumentLineCZP."VAT Base Amount";
                VATAmountLine."Amount Including VAT" += CashDocumentLineCZP."Amount Including VAT";
                VATAmountLine."VAT Difference" += CashDocumentLineCZP."VAT Difference";
                VATAmountLine."VAT Base (LCY) CZL" += CashDocumentLineCZP."VAT Base Amount (LCY)";
                VATAmountLine."VAT Amount (LCY) CZL" += CashDocumentLineCZP."Amount Including VAT (LCY)" - CashDocumentLineCZP."VAT Base Amount (LCY)";
                VATAmountLine.Modify();
            until CashDocumentLineCZP.Next() = 0;
        CashDocumentLineCZP.SetRange(CashDocumentLineCZP."Account Type");

        if VATAmountLine.FindSet() then
            repeat
                VATAmountLine."Calculated VAT Amount" := VATAmountLine."VAT Amount" - VATAmountLine."VAT Difference";
                VATAmountLine.Modify();
            until VATAmountLine.Next() = 0;
    end;

    procedure VATLinesDrillDown(var DrillDownVATAmountLine: Record "VAT Amount Line"; ThisTabAllowsVATEditing: Boolean)
    begin
        AllowVATDifference := false;
        Clear(VATAmountLines);
        VATAmountLines.SetTempVATAmountLine(DrillDownVATAmountLine);
        VATAmountLines.InitGlobals(
          Rec."Currency Code", AllowVATDifference, AllowVATDifference and ThisTabAllowsVATEditing,
          CashDocumentHeaderCZP."Amounts Including VAT", false, 0);
        VATAmountLines.RunModal();
        VATAmountLines.GetTempVATAmountLine(DrillDownVATAmountLine);
    end;
}
