// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Finance.GST.Application;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;

codeunit 18006 "GST Statistics"
{
    Access = Internal;
    procedure GetPurchaseStatisticsAmount(
        PurchaseHeader: Record "Purchase Header";
        var GSTAmount: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        Clear(GSTAmount);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document no.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                GSTAmount += GetGSTAmount(PurchaseLine.RecordId());
            until PurchaseLine.Next() = 0;
    end;

    procedure GetStatisticsPostedPurchInvAmount(
        PurchInvHeader: Record "Purch. Inv. Header";
        var GSTAmount: Decimal)
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        Clear(GSTAmount);

        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        if PurchInvLine.FindSet() then
            repeat
                GSTAmount += GetGSTAmount(PurchInvLine.RecordId());
            until PurchInvLine.Next() = 0;
    end;

    procedure GetStatisticsPostedPurchCrMemoAmount(
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        var GSTAmount: Decimal)
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        Clear(GSTAmount);

        PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHeader."No.");
        if PurchCrMemoLine.FindSet() then
            repeat
                GSTAmount += GetGSTAmount(PurchCrMemoLine.RecordId());
            until PurchCrMemoLine.Next() = 0;
    end;

    local procedure GetPurchaseRCMStatisticsAmount(
        PurchaseHeader: Record "Purchase Header";
        var RCMAmount: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        Clear(RCMAmount);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document no.", PurchaseHeader."No.");
        PurchaseLine.SetRange("GST Reverse Charge", true);
        if PurchaseLine.FindSet() then
            repeat
                RCMAmount += GetGSTAmount(PurchaseLine.RecordId());
            until PurchaseLine.Next() = 0;
    end;

    local procedure GetGSTAmount(RecID: RecordID): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Value Type", "Tax Type", Percent);
        TaxTransactionValue.SetRange("Tax Record ID", RecID);
        TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
        if GSTSetup."Cess Tax Type" <> '' then
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type", GSTSetup."Cess Tax Type")
        else
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if not TaxTransactionValue.IsEmpty() then
            TaxTransactionValue.CalcSums(Amount);

        exit(TaxTransactionValue.Amount);
    end;

    procedure GetSalesStatisticsAmount(
        SalesHeader: Record "Sales Header";
        var GSTAmount: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        Clear(GSTAmount);

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document no.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                GSTAmount += GetGSTAmount(SalesLine.RecordId());
            until SalesLine.Next() = 0;
    end;

    procedure GetPartialSalesStatisticsAmount(
        SalesHeader: Record "Sales Header";
        var PartialGSTAmount: Decimal)
    var
        SalesLine: Record "Sales Line";
        GSTBaseValidation: Codeunit "GST Base Validation";
    begin
        Clear(PartialGSTAmount);

        SalesLine.SetLoadFields("Document Type", "Document No.", Quantity, "Qty. to Invoice");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document no.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                if SalesLine.Quantity <> 0 then
                    PartialGSTAmount += (GetGSTAmount(SalesLine.RecordId()) * SalesLine."Qty. to Invoice" / SalesLine.Quantity);
            until SalesLine.Next() = 0;

        PartialGSTAmount := GSTBaseValidation.RoundGSTPrecision(PartialGSTAmount);
    end;

    procedure GetPartialSalesShptStatisticsAmount(
        SalesHeader: Record "Sales Header";
        var PartialGSTAmount: Decimal)
    var
        SalesLine: Record "Sales Line";
        GSTBaseValidation: Codeunit "GST Base Validation";
    begin
        Clear(PartialGSTAmount);

        SalesLine.SetLoadFields("Document Type", "Document No.", Quantity, "Qty. to Ship", "Return Qty. to Receive");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document no.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                if SalesLine.Quantity <> 0 then
                    if SalesLine."Document Type" = SalesLine."Document Type"::Order then
                        PartialGSTAmount += (GetGSTAmount(SalesLine.RecordId()) * SalesLine."Qty. to Ship" / SalesLine.Quantity)
                    else
                        if SalesLine."Document Type" = SalesLine."Document Type"::"Return Order" then
                            PartialGSTAmount += (GetGSTAmount(SalesLine.RecordId()) * SalesLine."Return Qty. to Receive" / SalesLine.Quantity)
            until SalesLine.Next() = 0;

        PartialGSTAmount := GSTBaseValidation.RoundGSTPrecision(PartialGSTAmount);
    end;

    procedure GetStatisticsPostedSalesInvAmount(
        SalesInvHeader: Record "Sales Invoice Header";
        var GSTAmount: Decimal)
    var
        SalesInvLine: Record "Sales Invoice Line";
    begin
        Clear(GSTAmount);

        SalesInvLine.SetRange("Document No.", SalesInvHeader."No.");
        if SalesInvLine.FindSet() then
            repeat
                GSTAmount += GetGSTAmount(SalesInvLine.RecordId());
            until SalesInvLine.Next() = 0;
    end;

    procedure GetStatisticsPostedSalesCrMemoAmount(
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        var GSTAmount: Decimal)
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
    begin
        Clear(GSTAmount);

        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        if SalesCrMemoLine.FindSet() then
            repeat
                GSTAmount += GetGSTAmount(SalesCrMemoLine.RecordId());
            until SalesCrMemoLine.Next() = 0;
    end;

    local procedure GetPurchaseStatisticsAmountExcludingChargeItem(
        PurchaseHeader: Record "Purchase Header";
        var GSTAmount: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        Clear(GSTAmount);

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document no.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                if (not PurchaseLine."GST Reverse Charge") then
                    GSTAmount += GetGSTAmount(PurchaseLine.RecordId());
            until PurchaseLine.Next() = 0;
    end;

    local procedure GetStatisticsPostedPurchInvAmountExcludingChargeItem(
        PurchInvHeader: Record "Purch. Inv. Header";
        var GSTAmount: Decimal)
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        Clear(GSTAmount);

        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        if PurchInvLine.FindSet() then
            repeat
                if (not PurchInvLine."GST Reverse Charge") then
                    GSTAmount += GetGSTAmount(PurchInvLine.RecordId);
            until PurchInvLine.Next() = 0;
    end;

    local procedure GetStatisticsPostedPurchCrMemoAmountExcludingChargeItem(
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        var GSTAmount: Decimal)
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        Clear(GSTAmount);

        PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHeader."No.");
        if PurchCrMemoLine.FindSet() then
            repeat
                if (not PurchCrMemoLine."GST Reverse Charge") then
                    GSTAmount += GetGSTAmount(PurchCrMemoLine.RecordId());
            until PurchCrMemoLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetPurchaseHeaderGSTAmount', '', false, false)]
    local procedure OnGetPurchaseHeaderGSTAmount(PurchaseHeader: Record "Purchase Header"; var GSTAmount: Decimal)
    var
        GSTStatsManagement: Codeunit "GST Stats Management";
        RCMAmount: Decimal;
    begin
        if PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::Import then
            exit;

        GSTAmount := GSTStatsManagement.GetGstStatsAmount();
        GetPurchaseRCMStatisticsAmount(PurchaseHeader, RCMAmount);
        GSTAmount := GSTAmount - RCMAmount;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetPurchaseHeaderCessAmount', '', false, false)]
    local procedure OnGetPurchaseHeaderCessAmount(PurchaseHeader: Record "Purchase Header"; var CessAmount: Decimal)
    var
        GSTStatsManagement: Codeunit "GST Stats Management";
    begin
        CessAmount := GSTStatsManagement.GetGstCessAmount();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetPartialPurchaseHeaderGSTAmount', '', false, false)]
    procedure OnGetPartialPurchaseHeaderGSTAmount(PurchaseHeader: Record "Purchase Header"; var PartialGSTAmount: Decimal)
    var
        PartialRCMAmount: Decimal;
    begin
        GetPartialPurchaseInvStatisticsAmount(PurchaseHeader, PartialGSTAmount);
        GetPartialPurchaseRCMStatisticsAmount(PurchaseHeader, PartialRCMAmount);
        PartialGSTAmount := PartialGSTAmount - PartialRCMAmount;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetPartialPurchaseRcptGSTAmount', '', false, false)]
    procedure OnGetPartialPurchaseRcptGSTAmount(PurchaseHeader: Record "Purchase Header"; var PartialGSTAmount: Decimal)
    var
        PartialRCMAmount: Decimal;
    begin
        GetPartialPurchaseRcptStatisticsAmount(PurchaseHeader, PartialGSTAmount);
        GetPartialPurchaseRcptRCMStatisticsAmount(PurchaseHeader, PartialRCMAmount);
        PartialGSTAmount := PartialGSTAmount - PartialRCMAmount;
    end;

    local procedure GetPartialPurchaseInvStatisticsAmount(
        PurchaseHeader: Record "Purchase Header";
        var PartialGSTAmount: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
        GSTBaseValidation: Codeunit "GST Base Validation";
    begin
        Clear(PartialGSTAmount);

        PurchaseLine.SetLoadFields("Document Type", "Document No.", Quantity, "Qty. to Invoice");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document no.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                if PurchaseLine.Quantity <> 0 then
                    PartialGSTAmount += (GetGSTAmount(PurchaseLine.RecordId()) * PurchaseLine."Qty. to Invoice" / PurchaseLine.Quantity);
            until PurchaseLine.Next() = 0;

        PartialGSTAmount := GSTBaseValidation.RoundGSTPrecision(PartialGSTAmount);
    end;

    local procedure GetPartialPurchaseRcptStatisticsAmount(
        PurchaseHeader: Record "Purchase Header";
        var PartialGSTAmount: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
        GSTBaseValidation: Codeunit "GST Base Validation";
    begin
        Clear(PartialGSTAmount);

        PurchaseLine.SetLoadFields("Document Type", "Document No.", Quantity, "Qty. to Receive", "Return Qty. to Ship");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document no.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                if PurchaseLine.Quantity <> 0 then
                    if PurchaseLine."Document Type" = PurchaseLine."Document Type"::Order then
                        PartialGSTAmount += (GetGSTAmount(PurchaseLine.RecordId()) * PurchaseLine."Qty. to Receive" / PurchaseLine.Quantity)
                    else
                        if PurchaseLine."Document Type" = PurchaseLine."Document Type"::"Return Order" then
                            PartialGSTAmount += (GetGSTAmount(PurchaseLine.RecordId()) * PurchaseLine."Return Qty. to Ship" / PurchaseLine.Quantity);
            until PurchaseLine.Next() = 0;

        PartialGSTAmount := GSTBaseValidation.RoundGSTPrecision(PartialGSTAmount);
    end;

    local procedure GetPartialPurchaseRCMStatisticsAmount(
        PurchaseHeader: Record "Purchase Header";
        var PartialRCMAmount: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
        GSTBaseValidation: Codeunit "GST Base Validation";
    begin
        Clear(PartialRCMAmount);

        PurchaseLine.SetLoadFields("Document Type", "Document No.", Quantity, "Qty. to Invoice");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document no.", PurchaseHeader."No.");
        PurchaseLine.SetRange("GST Reverse Charge", true);
        if PurchaseLine.FindSet() then
            repeat
                if PurchaseLine.Quantity <> 0 then
                    PartialRCMAmount += (GetGSTAmount(PurchaseLine.RecordId()) * PurchaseLine."Qty. to Invoice" / PurchaseLine.Quantity);
            until PurchaseLine.Next() = 0;

        PartialRCMAmount := GSTBaseValidation.RoundGSTPrecision(PartialRCMAmount);
    end;

    local procedure GetPartialPurchaseRcptRCMStatisticsAmount(
        PurchaseHeader: Record "Purchase Header";
        var PartialRCMAmount: Decimal)
    var
        PurchaseLine: Record "Purchase Line";
        GSTBaseValidation: Codeunit "GST Base Validation";
    begin
        Clear(PartialRCMAmount);

        PurchaseLine.SetLoadFields("Document Type", "Document No.", Quantity, "Qty. to Receive", "Return Qty. to Ship");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document no.", PurchaseHeader."No.");
        PurchaseLine.SetRange("GST Reverse Charge", true);
        if PurchaseLine.FindSet() then
            repeat
                if PurchaseLine.Quantity <> 0 then
                    if PurchaseLine."Document Type" = PurchaseLine."Document Type"::Order then
                        PartialRCMAmount += (GetGSTAmount(PurchaseLine.RecordId()) * PurchaseLine."Qty. to Receive" / PurchaseLine.Quantity)
                    else
                        if PurchaseLine."Document Type" = PurchaseLine."Document Type"::"Return Order" then
                            PartialRCMAmount += (GetGSTAmount(PurchaseLine.RecordId()) * PurchaseLine."Return Qty. to Ship" / PurchaseLine.Quantity);
            until PurchaseLine.Next() = 0;

        PartialRCMAmount := GSTBaseValidation.RoundGSTPrecision(PartialRCMAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetPurchInvHeaderGSTAmount', '', false, false)]
    local procedure OnGetPurchInvHeaderGSTAmount(PurchInvHeader: Record "Purch. Inv. Header"; var GSTAmount: Decimal)
    begin
        GetStatisticsPostedPurchInvAmountExcludingChargeItem(PurchInvHeader, GSTAmount)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetPurchCrMemoHeaderGSTAmount', '', false, false)]
    local procedure OnGetPurchCrMemoHeaderGSTAmount(PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr."; var GSTAmount: Decimal)
    begin
        GetStatisticsPostedPurchCrMemoAmountExcludingChargeItem(PurchCrMemoHeader, GSTAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetSalesHeaderGSTAmount', '', false, false)]
    local procedure OnGetSalesHeaderGSTAmount(SalesHeader: Record "Sales Header"; var GSTAmount: Decimal)
    begin
        GetSalesStatisticsAmount(SalesHeader, GSTAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetPartialSalesHeaderGSTAmount', '', false, false)]
    local procedure OnGetPartialSalesHeaderGSTAmount(SalesHeader: Record "Sales Header"; var PartialGSTAmount: Decimal)
    begin
        GetPartialSalesStatisticsAmount(SalesHeader, PartialGSTAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetPartialSalesShptGSTAmount', '', false, false)]
    local procedure OnGetPartialSalesShptGSTAmount(SalesHeader: Record "Sales Header"; var PartialGSTAmount: Decimal)
    begin
        GetPartialSalesShptStatisticsAmount(SalesHeader, PartialGSTAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetSalesInvHeaderGSTAmount', '', false, false)]
    local procedure OnGetSalesInvHeaderGSTAmount(SalesInvHeader: Record "Sales Invoice Header"; var GSTAmount: Decimal)
    begin
        GetStatisticsPostedSalesInvAmount(SalesInvHeader, GSTAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calculate Statistics", 'OnGetSalesCrMemoHeaderGSTAmount', '', false, false)]
    local procedure OnGetSalesCrMemoHeaderGSTAmount(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var GSTAmount: Decimal)
    begin
        GetStatisticsPostedSalesCrMemoAmount(SalesCrMemoHeader, GSTAmount);
    end;
}
