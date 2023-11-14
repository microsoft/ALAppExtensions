// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;

codeunit 31064 "Advance Letter Doc. Totals CZZ"
{
    var
        TotalsUpToDate: Boolean;

    procedure SalesCheckAndClearTotals(var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; var xSalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; var TotalSalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ")
    begin
        SalesAdvLetterLineCZZ.FilterGroup(4);
        if SalesAdvLetterLineCZZ.GetFilter("Document No.") <> '' then
            if SalesAdvLetterLineCZZ.GetRangeMin("Document No.") <> xSalesAdvLetterLineCZZ."Document No." then begin
                TotalsUpToDate := false;
                Clear(TotalSalesAdvLetterLineCZZ);
            end;
        SalesAdvLetterLineCZZ.FilterGroup(0);
    end;

    procedure GetTotalSalesHeaderAndCurrency(var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var Currency: Record Currency)
    begin
        if SalesAdvLetterHeaderCZZ."No." <> SalesAdvLetterLineCZZ."Document No." then begin
            Clear(SalesAdvLetterHeaderCZZ);
            if SalesAdvLetterLineCZZ."Document No." <> '' then
                if SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterLineCZZ."Document No.") then;
        end;
        if Currency.Code <> SalesAdvLetterHeaderCZZ."Currency Code" then begin
            Clear(Currency);
            Currency.Initialize(SalesAdvLetterHeaderCZZ."Currency Code");
        end;
    end;

    procedure SalesCheckIfDocumentChanged(var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; var xSalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ")
    begin
        if (SalesAdvLetterLineCZZ."Document No." <> xSalesAdvLetterLineCZZ."Document No.") or
           (SalesAdvLetterLineCZZ.Amount <> xSalesAdvLetterLineCZZ.Amount) or
           (SalesAdvLetterLineCZZ."Amount Including VAT" <> xSalesAdvLetterLineCZZ."Amount Including VAT")
        then
            TotalsUpToDate := false;
    end;

    procedure CalculateSalesSubPageTotals(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ")
    var
        SalesAdvLetterLine2: Record "Sales Adv. Letter Line CZZ";
    begin
        if TotalsUpToDate then
            exit;
        TotalsUpToDate := true;

        SalesAdvLetterLine2.SetRange("Document No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterLine2.CalcSums(Amount, "Amount Including VAT", "Amount (LCY)", "Amount Including VAT (LCY)");
        SalesAdvLetterLineCZZ := SalesAdvLetterLine2;
    end;

    procedure SalesDeltaUpdateTotals(var SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; var xSalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; var TotalSalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ")
    begin
        TotalSalesAdvLetterLineCZZ."Amount Including VAT" += SalesAdvLetterLineCZZ."Amount Including VAT" - xSalesAdvLetterLineCZZ."Amount Including VAT";
        TotalSalesAdvLetterLineCZZ.Amount += SalesAdvLetterLineCZZ.Amount - xSalesAdvLetterLineCZZ.Amount;
        TotalSalesAdvLetterLineCZZ."Amount Including VAT (LCY)" += SalesAdvLetterLineCZZ."Amount Including VAT (LCY)" - xSalesAdvLetterLineCZZ."Amount Including VAT (LCY)";
        TotalSalesAdvLetterLineCZZ."Amount (LCY)" += SalesAdvLetterLineCZZ."Amount (LCY)" - xSalesAdvLetterLineCZZ."Amount (LCY)";
    end;

    procedure SalesDocTotalsNotUpToDate()
    begin
        TotalsUpToDate := false;
    end;

    procedure PurchCheckAndClearTotals(var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; var xPurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; var TotalPurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ")
    begin
        PurchAdvLetterLineCZZ.FilterGroup(4);
        if PurchAdvLetterLineCZZ.GetFilter("Document No.") <> '' then
            if PurchAdvLetterLineCZZ.GetRangeMin("Document No.") <> xPurchAdvLetterLineCZZ."Document No." then begin
                TotalsUpToDate := false;
                Clear(TotalPurchAdvLetterLineCZZ);
            end;
        PurchAdvLetterLineCZZ.FilterGroup(0);
    end;

    procedure GetTotalPurchHeaderAndCurrency(var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var Currency: Record Currency)
    begin
        if PurchAdvLetterHeaderCZZ."No." <> PurchAdvLetterLineCZZ."Document No." then begin
            Clear(PurchAdvLetterHeaderCZZ);
            if PurchAdvLetterLineCZZ."Document No." <> '' then
                if PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterLineCZZ."Document No.") then;
        end;
        if Currency.Code <> PurchAdvLetterHeaderCZZ."Currency Code" then begin
            Clear(Currency);
            Currency.Initialize(PurchAdvLetterHeaderCZZ."Currency Code");
        end;
    end;

    procedure PurchCheckIfDocumentChanged(var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; var xPurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ")
    begin
        if (PurchAdvLetterLineCZZ."Document No." <> xPurchAdvLetterLineCZZ."Document No.") or
           (PurchAdvLetterLineCZZ.Amount <> xPurchAdvLetterLineCZZ.Amount) or
           (PurchAdvLetterLineCZZ."Amount Including VAT" <> xPurchAdvLetterLineCZZ."Amount Including VAT")
        then
            TotalsUpToDate := false;
    end;

    procedure CalculatePurchSubPageTotals(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ")
    var
        PurchAdvLetterLine2: Record "Purch. Adv. Letter Line CZZ";
    begin
        if TotalsUpToDate then
            exit;
        TotalsUpToDate := true;

        PurchAdvLetterLine2.SetRange("Document No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterLine2.CalcSums(Amount, "Amount Including VAT", "Amount (LCY)", "Amount Including VAT (LCY)");
        PurchAdvLetterLineCZZ := PurchAdvLetterLine2;
    end;

    procedure PurchDeltaUpdateTotals(var PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; var xPurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; var TotalPurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ")
    begin
        TotalPurchAdvLetterLineCZZ."Amount Including VAT" += PurchAdvLetterLineCZZ."Amount Including VAT" - xPurchAdvLetterLineCZZ."Amount Including VAT";
        TotalPurchAdvLetterLineCZZ.Amount += PurchAdvLetterLineCZZ.Amount - xPurchAdvLetterLineCZZ.Amount;
        TotalPurchAdvLetterLineCZZ."Amount Including VAT (LCY)" += PurchAdvLetterLineCZZ."Amount Including VAT (LCY)" - xPurchAdvLetterLineCZZ."Amount Including VAT (LCY)";
        TotalPurchAdvLetterLineCZZ."Amount (LCY)" += PurchAdvLetterLineCZZ."Amount (LCY)" - xPurchAdvLetterLineCZZ."Amount (LCY)";
    end;

    procedure PurchDocTotalsNotUpToDate()
    begin
        TotalsUpToDate := false;
    end;
}
