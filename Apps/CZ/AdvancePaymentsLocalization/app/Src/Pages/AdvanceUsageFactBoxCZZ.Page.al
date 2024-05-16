﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;

page 31216 "Advance Usage FactBox CZZ"
{
    Caption = 'Advance Usage';
    PageType = CardPart;
    Editable = false;

    layout
    {
        area(Content)
        {
            field(Advances; GetAdvancesCount())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advances';
                ToolTip = 'Specifies number of advances assigned to the document.';
                DrillDown = true;

                trigger OnDrillDown()
                begin
                    Page.RunModal(Page::"Advance Letter Application CZZ", TempAdvanceLetterApplicationCZZ)
                end;
            }
            field(AmountToUse; GetAmountToUse())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Amount to Use';
                ToolTip = 'Specifies amount to use of assigned advances.';
            }
            field(AmountToUseLCY; GetAmountToUseLCY())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Amount to Use (LCY)';
                ToolTip = 'Specifies amount to use (LCY) of assigned advances.';
                Visible = false;
            }
            field(AmountUsed; GetAmountUsed())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Amount Used';
                ToolTip = 'Specifies amount used by the document.';
            }
            field(AmountUsedLCY; GetAmountUsedLCY())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Amount Used (LCY)';
                ToolTip = 'Specifies amount (LCY) used by the document.';
                Visible = false;
            }
            field(TotalAfterDeduction; GetTotalAfterDeduction())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Total after Deduction';
                ToolTip = 'Specifies total document amount after deduction of used advances.';
                Style = Strong;
            }
            field(AdvanceEntries; GetAdvanceEntriesCount())
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advance Entries';
                ToolTip = 'Specifies number of advance entries.';
                DrillDown = true;

                trigger OnDrillDown()
                begin
                    if not TempPurchAdvLetterEntryCZZ.IsEmpty() then
                        Page.Run(0, TempPurchAdvLetterEntryCZZ);
                    if not TempSalesAdvLetterEntryCZZ.IsEmpty() then
                        Page.Run(0, TempSalesAdvLetterEntryCZZ);
                end;
            }
        }
    }

    var
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        TempSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ" temporary;
        TempPurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ" temporary;
        DocumentTotalAmount: Decimal;

    procedure SetDocument(PurchaseHeader: Record "Purchase Header")
    begin
        ClearBuffers();
        CollectAssignedAdvances(PurchaseHeader.GetAdvLetterUsageDocTypeCZZ(), PurchaseHeader."No.");
        CollectPurchAdvLetterEntries(PurchaseHeader);
        DocumentTotalAmount := CalcDocumentTotalAmount(PurchaseHeader);
        CurrPage.Update();
    end;

    procedure SetDocument(SalesHeader: Record "Sales Header")
    begin
        ClearBuffers();
        CollectAssignedAdvances(SalesHeader.GetAdvLetterUsageDocTypeCZZ(), SalesHeader."No.");
        CollectSalesAdvLetterEntries(SalesHeader);
        DocumentTotalAmount := CalcDocumentTotalAmount(SalesHeader);
        CurrPage.Update();
    end;

    procedure SetDocument(PurchInvHeader: Record "Purch. Inv. Header")
    begin
        ClearBuffers();
        CollectAssignedAdvances("Adv. Letter Usage Doc.Type CZZ"::"Posted Purchase Invoice", PurchInvHeader."No.");
        CollectPurchAdvLetterEntries(PurchInvHeader);
        DocumentTotalAmount := CalcDocumentTotalAmount(PurchInvHeader);
        CurrPage.Update();
    end;

    procedure SetDocument(SalesInvoiceHeader: Record "Sales Invoice Header")
    begin
        ClearBuffers();
        CollectAssignedAdvances("Adv. Letter Usage Doc.Type CZZ"::"Posted Sales Invoice", SalesInvoiceHeader."No.");
        CollectSalesAdvLetterEntries(SalesInvoiceHeader);
        DocumentTotalAmount := CalcDocumentTotalAmount(SalesInvoiceHeader);
        CurrPage.Update();
    end;

    local procedure CollectAssignedAdvances(DocumentType: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20])
    begin
        TempAdvanceLetterApplicationCZZ.GetAssignedAdvance(DocumentType, DocumentNo, TempAdvanceLetterApplicationCZZ);
    end;

    local procedure CollectPurchAdvLetterEntries(PurchaseHeader: Record "Purchase Header")
    var
        PurchAdvLetterManagementCZZ: Codeunit "PurchAdvLetterManagement CZZ";
    begin
        PurchAdvLetterManagementCZZ.PostAdvancePaymentUsagePreview(
            PurchaseHeader,
            TempAdvanceLetterApplicationCZZ.Amount,
            TempAdvanceLetterApplicationCZZ."Amount (LCY)",
            TempPurchAdvLetterEntryCZZ);
        TempPurchAdvLetterEntryCZZ.SetFilter("Entry Type", '<>%1&<>%2&<>%3',
            TempPurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage",
            TempPurchAdvLetterEntryCZZ."Entry Type"::"VAT Rate",
            TempPurchAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment");
        TempPurchAdvLetterEntryCZZ.DeleteAll();
        TempPurchAdvLetterEntryCZZ.Reset();
    end;

    local procedure CollectPurchAdvLetterEntries(PurchInvHeader: Record "Purch. Inv. Header")
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
    begin
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PurchInvHeader."No.");
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if PurchAdvLetterEntryCZZ.FindSet() then
            repeat
                TempPurchAdvLetterEntryCZZ.Init();
                TempPurchAdvLetterEntryCZZ := PurchAdvLetterEntryCZZ;
                TempPurchAdvLetterEntryCZZ.Insert();
            until PurchAdvLetterEntryCZZ.Next() = 0;
    end;

    local procedure CollectSalesAdvLetterEntries(SalesHeader: Record "Sales Header")
    var
        SalesAdvLetterManagementCZZ: Codeunit "SalesAdvLetterManagement CZZ";
    begin
        SalesAdvLetterManagementCZZ.PostAdvancePaymentUsagePreview(
            SalesHeader,
            TempAdvanceLetterApplicationCZZ.Amount,
            TempAdvanceLetterApplicationCZZ."Amount (LCY)",
            TempSalesAdvLetterEntryCZZ);
        TempSalesAdvLetterEntryCZZ.SetFilter("Entry Type", '<>%1&<>%2&<>%3',
            TempSalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage",
            TempSalesAdvLetterEntryCZZ."Entry Type"::"VAT Rate",
            TempSalesAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment");
        TempSalesAdvLetterEntryCZZ.DeleteAll();
        TempSalesAdvLetterEntryCZZ.Reset();
    end;

    local procedure CollectSalesAdvLetterEntries(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
    begin
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if SalesAdvLetterEntryCZZ.FindSet() then
            repeat
                TempSalesAdvLetterEntryCZZ.Init();
                TempSalesAdvLetterEntryCZZ := SalesAdvLetterEntryCZZ;
                TempSalesAdvLetterEntryCZZ.Insert();
            until SalesAdvLetterEntryCZZ.Next() = 0;
    end;

    local procedure CalcDocumentTotalAmount(PurchaseHeader: Record "Purchase Header"): Decimal
    var
        TempPurchaseLine: Record "Purchase Line" temporary;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        PurchPost: Codeunit "Purch.-Post";
    begin
        PurchPost.GetPurchLines(PurchaseHeader, TempPurchaseLine, 1);
        TempPurchaseLine.CalcVATAmountLines(1, PurchaseHeader, TempPurchaseLine, TempVATAmountLine);
        TempPurchaseLine.UpdateVATOnLines(1, PurchaseHeader, TempPurchaseLine, TempVATAmountLine);
        exit(TempVATAmountLine.GetTotalAmountInclVAT());
    end;

    local procedure CalcDocumentTotalAmount(SalesHeader: Record "Sales Header"): Decimal
    var
        TempSalesLine: Record "Sales Line" temporary;
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesPost.GetSalesLines(SalesHeader, TempSalesLine, 1);
        TempSalesLine.CalcVATAmountLines(1, SalesHeader, TempSalesLine, TempVATAmountLine);
        TempSalesLine.UpdateVATOnLines(1, SalesHeader, TempSalesLine, TempVATAmountLine);
        exit(TempVATAmountLine.GetTotalAmountInclVAT());
    end;

    local procedure CalcDocumentTotalAmount(PurchInvHeader: Record "Purch. Inv. Header"): Decimal
    begin
        PurchInvHeader.CalcFields("Amount Including VAT");
        exit(PurchInvHeader."Amount Including VAT");
    end;

    local procedure CalcDocumentTotalAmount(SalesInvoiceHeader: Record "Sales Invoice Header"): Decimal
    begin
        SalesInvoiceHeader.CalcFields("Amount Including VAT");
        exit(SalesInvoiceHeader."Amount Including VAT");
    end;

    local procedure ClearBuffers()
    begin
        TempAdvanceLetterApplicationCZZ.Reset();
        TempAdvanceLetterApplicationCZZ.DeleteAll();
        TempPurchAdvLetterEntryCZZ.Reset();
        TempPurchAdvLetterEntryCZZ.DeleteAll();
        TempSalesAdvLetterEntryCZZ.Reset();
        TempSalesAdvLetterEntryCZZ.DeleteAll();
    end;

    local procedure GetAdvanceEntriesCount(): Integer
    begin
        // one of the following buffers must be empty
        exit(TempPurchAdvLetterEntryCZZ.Count() + TempSalesAdvLetterEntryCZZ.Count());
    end;

    local procedure GetAdvancesCount(): Integer
    begin
        exit(TempAdvanceLetterApplicationCZZ.Count());
    end;

    local procedure GetAmountToUse(): Decimal
    begin
        TempAdvanceLetterApplicationCZZ.CalcSums("Amount to Use");
        exit(TempAdvanceLetterApplicationCZZ."Amount to Use");
    end;

    local procedure GetAmountToUseLCY(): Decimal
    begin
        TempAdvanceLetterApplicationCZZ.CalcSums("Amount to Use (LCY)");
        exit(TempAdvanceLetterApplicationCZZ."Amount to Use (LCY)");
    end;

    local procedure GetAmountUsed(): Decimal
    begin
        TempAdvanceLetterApplicationCZZ.CalcSums(Amount);
        exit(TempAdvanceLetterApplicationCZZ.Amount);
    end;

    local procedure GetAmountUsedLCY(): Decimal
    begin
        TempAdvanceLetterApplicationCZZ.CalcSums("Amount (LCY)");
        exit(TempAdvanceLetterApplicationCZZ."Amount (LCY)");
    end;

    local procedure GetTotalAfterDeduction(): Decimal
    begin
        exit(DocumentTotalAmount - GetAmountUsed());
    end;
}
