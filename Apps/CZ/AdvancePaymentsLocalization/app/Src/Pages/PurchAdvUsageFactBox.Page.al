// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;

page 31189 "Purch. Adv. Usage FactBox CZZ"
{
    Caption = 'Purchase Advance Usage';
    PageType = CardPart;
    SourceTable = "Purchase Line";

    layout
    {
        area(Content)
        {
            field(AdvanceCount; AdvanceCount)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advances Count';
                ToolTip = 'Specifies advances count.';
                DrillDown = true;

                trigger OnDrillDown()
                var
                    PurchAdvLetterManagement: Codeunit "PurchAdvLetterManagement CZZ";
                begin
                    case Rec."Document Type" of
                        Rec."Document Type"::Order:
                            begin
                                PurchAdvLetterManagement.LinkAdvanceLetter("Adv. Letter Usage Doc.Type CZZ"::"Purchase Order", PurchaseHeader."No.", PurchaseHeader."Pay-to Vendor No.", PurchaseHeader."Posting Date", PurchaseHeader."Currency Code");
                                CurrPage.Update();
                            end;
                        Rec."Document Type"::Invoice:
                            begin
                                PurchAdvLetterManagement.LinkAdvanceLetter("Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.", PurchaseHeader."Pay-to Vendor No.", PurchaseHeader."Posting Date", PurchaseHeader."Currency Code");
                                CurrPage.Update();
                            end;
                    end;
                end;
            }
            field(AdvanceAmountToUse; AdvanceAmountToUse)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advances Amount to Use';
                ToolTip = 'Specifies advances total amount to use.';
            }
            field(AdvanceAmountToUseLCY; AdvanceAmountToUseLCY)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advances Amount to Use (LCY)';
                ToolTip = 'Specifies advances total amount (LCY) to use.';
                Visible = false;
            }
            field(AdvanceAmount; AdvanceAmountAssigned)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advances Amount Assigned';
                ToolTip = 'Specifies advances assigned amount.';
            }
            field(AdvanceAmountLCY; AdvanceAmountAssignedLCY)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advances Amount Assigned (LCY)';
                ToolTip = 'Specifies advances assigned amount (LCY).';
                Visible = false;
            }
            field(DocumentAmount; TotalAmountInclVAT - AdvanceAmountAssigned)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Amount with Advance Letters';
                ToolTip = 'Specifies total amount with advance letters.';
                Style = Strong;
            }
            field(AdvanceVATLineCount; AdvanceVATLineCount)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advances VAT Lines Count';
                ToolTip = 'Specifies advances VAT lines count.';
                DrillDown = true;

                trigger OnDrillDown()
                begin
                    Page.RunModal(Page::"Pur. Adv. Letter Ent.Prev. CZZ", TempPurchAdvLetterEntryCZZ);
                end;
            }
        }
    }

    var
        TempPurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ" temporary;
        PurchaseHeader: Record "Purchase Header";
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
        AdvanceCount, AdvanceVATLineCount : Integer;
        AdvanceAmountAssigned, AdvanceAmountAssignedLCY, AdvanceAmountToUse, AdvanceAmountToUseLCY, TotalAmountInclVAT : Decimal;

    trigger OnAfterGetCurrRecord()
    var
        AdvanceLetterApplication: Record "Advance Letter Application CZZ";
        TempAdvanceLetterApplication: Record "Advance Letter Application CZZ" temporary;
        TempPurchaseLine: Record "Purchase Line" temporary;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        PurchPost: Codeunit "Purch.-Post";
        CurrFactor: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforeOnAfterGetCurrRecord(Rec, IsHandled);
        if IsHandled then
            exit;

        if (not (Rec."Document Type" in [Rec."Document Type"::Order, Rec."Document Type"::Invoice])) or (Rec."Document No." = '') then begin
            AdvanceCount := 0;
            AdvanceVATLineCount := 0;
            AdvanceAmountAssigned := 0;
            AdvanceAmountAssignedLCY := 0;
            TotalAmountInclVAT := 0;
            if not TempPurchAdvLetterEntryCZZ.IsEmpty() then
                TempPurchAdvLetterEntryCZZ.DeleteAll();
            Clear(PurchaseHeader);
            exit;
        end;

        PurchaseHeader.Get(Rec."Document Type", Rec."Document No.");

        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then
            AdvanceLetterApplication.GetAssignedAdvance("Adv. Letter Usage Doc.Type CZZ"::"Purchase Order", PurchaseHeader."No.", TempAdvanceLetterApplication)
        else
            AdvanceLetterApplication.GetAssignedAdvance("Adv. Letter Usage Doc.Type CZZ"::"Purchase Invoice", PurchaseHeader."No.", TempAdvanceLetterApplication);

        CurrFactor := PurchaseHeader."Currency Factor";
        if CurrFactor = 0 then
            CurrFactor := 1;

        PurchPost.GetPurchLines(PurchaseHeader, TempPurchaseLine, 1);
        TempPurchaseLine.CalcVATAmountLines(1, PurchaseHeader, TempPurchaseLine, TempVATAmountLine);
        TempPurchaseLine.UpdateVATOnLines(1, PurchaseHeader, TempPurchaseLine, TempVATAmountLine);
        TotalAmountInclVAT := TempVATAmountLine.GetTotalAmountInclVAT();

        AdvanceCount := TempAdvanceLetterApplication.Count();
        TempAdvanceLetterApplication.CalcSums(Amount, "Amount to Use");
        if TempAdvanceLetterApplication.Amount <= TotalAmountInclVAT then
            AdvanceAmountAssigned := TempAdvanceLetterApplication.Amount
        else
            AdvanceAmountAssigned := TotalAmountInclVAT;
        if TempAdvanceLetterApplication."Amount to Use" <= TotalAmountInclVAT then
            AdvanceAmountToUse := TempAdvanceLetterApplication."Amount to Use"
        else
            AdvanceAmountToUse := TotalAmountInclVAT;
        AdvanceAmountAssignedLCY := Round(AdvanceAmountAssigned / CurrFactor);
        AdvanceAmountToUseLCY := Round(AdvanceAmountToUse / CurrFactor);

        PurchAdvLetterManagementCZZ.PostAdvancePaymentUsagePreview(PurchaseHeader, AdvanceAmountAssigned, AdvanceAmountAssignedLCY, TempPurchAdvLetterEntryCZZ);
        TempPurchAdvLetterEntryCZZ.SetFilter("Entry Type", '<>%1&<>%2&<>%3', TempPurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage",
            TempPurchAdvLetterEntryCZZ."Entry Type"::"VAT Rate", TempPurchAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment");
        TempPurchAdvLetterEntryCZZ.DeleteAll();
        TempPurchAdvLetterEntryCZZ.Reset();
        AdvanceVATLineCount := TempPurchAdvLetterEntryCZZ.Count();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnAfterGetCurrRecord(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;
}
