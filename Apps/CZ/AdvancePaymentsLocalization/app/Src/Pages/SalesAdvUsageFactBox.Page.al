// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;

page 31187 "Sales Adv. Usage FactBox CZZ"
{
    Caption = 'Sales Advance Usage';
    PageType = CardPart;
    SourceTable = "Sales Line";

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
                    SalesAdvLetterManagement: Codeunit "SalesAdvLetterManagement CZZ";
                begin
                    case Rec."Document Type" of
                        Rec."Document Type"::Order:
                            begin
                                SalesAdvLetterManagement.LinkAdvanceLetter("Adv. Letter Usage Doc.Type CZZ"::"Sales Order", SalesHeader."No.", SalesHeader."Bill-to Customer No.", SalesHeader."Posting Date", SalesHeader."Currency Code");
                                CurrPage.Update();
                            end;
                        Rec."Document Type"::Invoice:
                            begin
                                SalesAdvLetterManagement.LinkAdvanceLetter("Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.", SalesHeader."Bill-to Customer No.", SalesHeader."Posting Date", SalesHeader."Currency Code");
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
                Caption = 'Advances Amount';
                ToolTip = 'Specifies advances assigned amount.';
            }
            field(AdvanceAmountLCY; AdvanceAmountAssignedLCY)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advances Amount (LCY)';
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
                    Page.RunModal(Page::"Sal. Adv. Letter Ent.Prev. CZZ", TempSalesAdvLetterEntryCZZ);
                end;
            }
        }
    }

    var
        TempSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ" temporary;
        SalesHeader: Record "Sales Header";
        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
        AdvanceCount, AdvanceVATLineCount : Integer;
        AdvanceAmountAssigned, AdvanceAmountAssignedLCY, AdvanceAmountToUse, AdvanceAmountToUseLCY, TotalAmountInclVAT : Decimal;

    trigger OnAfterGetCurrRecord()
    var
        AdvanceLetterApplication: Record "Advance Letter Application CZZ";
        TempAdvanceLetterApplication: Record "Advance Letter Application CZZ" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        SalesPost: Codeunit "Sales-Post";
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
            if not TempSalesAdvLetterEntryCZZ.IsEmpty() then
                TempSalesAdvLetterEntryCZZ.DeleteAll();
            Clear(SalesHeader);
            exit;
        end;

        SalesHeader.Get(Rec."Document Type", Rec."Document No.");

        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
            AdvanceLetterApplication.GetAssignedAdvance("Adv. Letter Usage Doc.Type CZZ"::"Sales Order", SalesHeader."No.", TempAdvanceLetterApplication)
        else
            AdvanceLetterApplication.GetAssignedAdvance("Adv. Letter Usage Doc.Type CZZ"::"Sales Invoice", SalesHeader."No.", TempAdvanceLetterApplication);

        CurrFactor := SalesHeader."Currency Factor";
        if CurrFactor = 0 then
            CurrFactor := 1;

        SalesPost.GetSalesLines(SalesHeader, TempSalesLine, 1);
        TempSalesLine.CalcVATAmountLines(1, SalesHeader, TempSalesLine, TempVATAmountLine);
        TempSalesLine.UpdateVATOnLines(1, SalesHeader, TempSalesLine, TempVATAmountLine);
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

        SalesAdvLetterManagementCZZ.PostAdvancePaymentUsagePreview(SalesHeader, AdvanceAmountAssigned, AdvanceAmountAssignedLCY, TempSalesAdvLetterEntryCZZ);
        TempSalesAdvLetterEntryCZZ.SetFilter("Entry Type", '<>%1&<>%2&<>%3', TempSalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage",
            TempSalesAdvLetterEntryCZZ."Entry Type"::"VAT Rate", TempSalesAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment");
        TempSalesAdvLetterEntryCZZ.DeleteAll();
        TempSalesAdvLetterEntryCZZ.Reset();
        AdvanceVATLineCount := TempSalesAdvLetterEntryCZZ.Count();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnAfterGetCurrRecord(var SalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;
}
