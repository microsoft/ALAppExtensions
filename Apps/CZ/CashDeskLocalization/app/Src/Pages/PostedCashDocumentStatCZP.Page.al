// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.Currency;
using Microsoft.Finance.VAT.Calculation;

page 31168 "Posted Cash Document Stat. CZP"
{
    Caption = 'Posted Cash Document Statistics';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;
    SourceTable = "Posted Cash Document Line CZP";
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
                field("AmountExclVAT[1]"; AmountExclVAT[1])
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount Excluding VAT';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies cash document amount. The amount is excluding VAT.';
                }
                field("VATAmount[1]"; VATAmount[1])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    Caption = 'VAT amount';
                    Editable = false;
                    ToolTip = 'Specifies cash document amount.';
                }
                field("AmountInclVAT[1]"; AmountInclVAT[1])
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount Including VAT';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies cash document amount. The amount is including VAT.';
                }
                field("AmountExclVATLCY[1]"; AmountExclVATLCY[1])
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount Excluding VAT (LCY)';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies cash document amount. The amount is excluding VAT in the local currency.';
                }
                field("VATAmountLCY[1]"; VATAmountLCY[1])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    Caption = 'VAT amount (LCY)';
                    Editable = false;
                    ToolTip = 'Specifies cash document amount. The amount is in the local currency.';
                }
                field("AmountInclVATLCY[1]"; AmountInclVATLCY[1])
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount Including VAT (LCY)';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies cash document amount. The amount is including VAT in the local currency.';
                }
                field(NoOfVATLines_Document; Temp1VATAmountLine.Count)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'No. of VAT Lines';
                    DrillDown = true;
                    ToolTip = 'Specifies the number of VAT lines.';

                    trigger OnDrillDown()
                    begin
                        VATLinesDrillDown(Temp1VATAmountLine, false);
                        UpdateHeaderInfo(1);
                    end;
                }
            }
            group("External Document")
            {
                Caption = 'External Document';
                field(ExternalCurrencyCode; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Lookup = false;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                }
                field("AmountExclVAT[2]"; AmountExclVAT[2])
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount Excluding VAT';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies cash document amount. The amount is excluding VAT.';
                }
                field("VATAmount[2]"; VATAmount[2])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    Caption = 'VAT amount';
                    Editable = false;
                    ToolTip = 'Specifies cash document amount.';
                }
                field("AmountInclVAT[2]"; AmountInclVAT[2])
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount Including VAT';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies cash document amount. The amount is including VAT.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the number that the vendor uses on the invoice they sent to you or number of receipt.';
                }
                field("AmountExclVATLCY[2]"; AmountExclVATLCY[2])
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount Excluding VAT (LCY)';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies cash document amount. The amount is excluding VAT in the local currency.';
                }
                field("VATAmountLCY[2]"; VATAmountLCY[2])
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = Rec."Currency Code";
                    AutoFormatType = 1;
                    Caption = 'VAT amount (LCY)';
                    Editable = false;
                    ToolTip = 'Specifies cash document amount. The amount is in the local currency.';
                }
                field("AmountInclVATLCY[2]"; AmountInclVATLCY[2])
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Amount Including VAT (LCY)';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies cash document amount. The amount is including VAT in the local currency.';
                }
                field(NoOfVATLines_External; Temp2VATAmountLine.Count)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'No. of VAT Lines';
                    DrillDown = true;
                    ToolTip = 'Specifies the number of VAT lines.';

                    trigger OnDrillDown()
                    begin
                        VATLinesDrillDown(Temp2VATAmountLine, false);
                        UpdateHeaderInfo(2);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        PostedCashDocumentHdrCZP.Get(Rec."Cash Desk No.", Rec."Cash Document No.");
        UpdateLine(1, Temp1VATAmountLine);
        UpdateLine(2, Temp2VATAmountLine);
        UpdateHeaderInfo(1);
        UpdateHeaderInfo(2);
    end;

    var
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        Currency: Record Currency;
        Temp1VATAmountLine: Record "VAT Amount Line" temporary;
        Temp2VATAmountLine: Record "VAT Amount Line" temporary;
        VATAmountLines: Page "VAT Amount Lines";
        AllowVATDifference: Boolean;
        AmountExclVAT: array[2] of Decimal;
        VATAmount: array[2] of Decimal;
        AmountInclVAT: array[2] of Decimal;
        AmountExclVATLCY: array[2] of Decimal;
        VATAmountLCY: array[2] of Decimal;
        AmountInclVATLCY: array[2] of Decimal;

    local procedure UpdateHeaderInfo(IndexNo: Integer)
    var
        TotalPostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
    begin
        TotalPostedCashDocumentLineCZP.Reset();
        TotalPostedCashDocumentLineCZP.SetCurrentKey("Cash Desk No.", "Cash Document No.", "External Document No.");
        TotalPostedCashDocumentLineCZP.SetRange("Cash Desk No.", Rec."Cash Desk No.");
        TotalPostedCashDocumentLineCZP.SetRange("Cash Document No.", Rec."Cash Document No.");
        if IndexNo = 2 then
            TotalPostedCashDocumentLineCZP.SetRange("External Document No.", Rec."External Document No.");

        TotalPostedCashDocumentLineCZP.CalcSums(
          TotalPostedCashDocumentLineCZP."VAT Base Amount",
          TotalPostedCashDocumentLineCZP."Amount Including VAT",
          TotalPostedCashDocumentLineCZP."VAT Base Amount (LCY)",
          TotalPostedCashDocumentLineCZP."Amount Including VAT (LCY)");

        AmountExclVAT[IndexNo] := TotalPostedCashDocumentLineCZP."VAT Base Amount";
        AmountInclVAT[IndexNo] := TotalPostedCashDocumentLineCZP."Amount Including VAT";
        VATAmount[IndexNo] := AmountInclVAT[IndexNo] - AmountExclVAT[IndexNo];
        AmountExclVATLCY[IndexNo] := TotalPostedCashDocumentLineCZP."VAT Base Amount (LCY)";
        AmountInclVATLCY[IndexNo] := TotalPostedCashDocumentLineCZP."Amount Including VAT (LCY)";
        VATAmountLCY[IndexNo] := AmountInclVATLCY[IndexNo] - AmountExclVATLCY[IndexNo];
    end;

    procedure UpdateLine(IndexNo: Integer; var VATAmountLine: Record "VAT Amount Line")
    var
        PostedCashDocumentLineCZP: Record "Posted Cash Document Line CZP";
    begin
        if PostedCashDocumentHdrCZP."Currency Code" = '' then
            Currency.InitRoundingPrecision()
        else
            Currency.Get(PostedCashDocumentHdrCZP."Currency Code");

        VATAmountLine.DeleteAll();

        PostedCashDocumentLineCZP.SetRange(PostedCashDocumentLineCZP."Cash Desk No.", Rec."Cash Desk No.");
        PostedCashDocumentLineCZP.SetRange(PostedCashDocumentLineCZP."Cash Document No.", Rec."Cash Document No.");
        PostedCashDocumentLineCZP.SetFilter(PostedCashDocumentLineCZP."Account Type", '>0');
        if IndexNo = 2 then
            PostedCashDocumentLineCZP.SetRange(PostedCashDocumentLineCZP."External Document No.", Rec."External Document No.");
        if PostedCashDocumentLineCZP.FindSet() then
            repeat
                if PostedCashDocumentLineCZP."VAT Calculation Type" in [PostedCashDocumentLineCZP."VAT Calculation Type"::"Reverse Charge VAT", PostedCashDocumentLineCZP."VAT Calculation Type"::"Sales Tax"] then
                    PostedCashDocumentLineCZP."VAT %" := 0;
                if not VATAmountLine.Get(PostedCashDocumentLineCZP."VAT Identifier", PostedCashDocumentLineCZP."VAT Calculation Type", '', false, PostedCashDocumentLineCZP.Amount >= 0) then begin
                    VATAmountLine.Init();
                    VATAmountLine."VAT Identifier" := PostedCashDocumentLineCZP."VAT Identifier";
                    VATAmountLine."VAT Calculation Type" := PostedCashDocumentLineCZP."VAT Calculation Type";
                    VATAmountLine.Positive := PostedCashDocumentLineCZP.Amount >= 0;
                    VATAmountLine."VAT %" := PostedCashDocumentLineCZP."VAT %";
                    VATAmountLine.Modified := true;
                    VATAmountLine.Insert();
                end;

                VATAmountLine."Line Amount" += PostedCashDocumentLineCZP.Amount;
                VATAmountLine."Amount Including VAT" += PostedCashDocumentLineCZP."Amount Including VAT";
                VATAmountLine."VAT Base" += PostedCashDocumentLineCZP."VAT Base Amount";
                VATAmountLine."VAT Amount" += PostedCashDocumentLineCZP."Amount Including VAT" - PostedCashDocumentLineCZP."VAT Base Amount";
                VATAmountLine."Amount Including VAT" += PostedCashDocumentLineCZP."Amount Including VAT";
                VATAmountLine."VAT Difference" += PostedCashDocumentLineCZP."VAT Difference";
                VATAmountLine."VAT Base (LCY) CZL" += PostedCashDocumentLineCZP."VAT Base Amount (LCY)";
                VATAmountLine."VAT Amount (LCY) CZL" += PostedCashDocumentLineCZP."Amount Including VAT (LCY)" - PostedCashDocumentLineCZP."VAT Base Amount (LCY)";
                VATAmountLine.Modify();
            until PostedCashDocumentLineCZP.Next() = 0;
        PostedCashDocumentLineCZP.SetRange(PostedCashDocumentLineCZP."Account Type");

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
          PostedCashDocumentHdrCZP."Amounts Including VAT", false, 0);
        VATAmountLines.RunModal();
        VATAmountLines.GetTempVATAmountLine(DrillDownVATAmountLine);
    end;
}
