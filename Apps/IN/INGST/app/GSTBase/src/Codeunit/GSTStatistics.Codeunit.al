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
        GSTAmount := GSTStatsManagement.GetGstStatsAmount();
        GetPurchaseRCMStatisticsAmount(PurchaseHeader, RCMAmount);
        GSTAmount := GSTAmount - RCMAmount;
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
