// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup.ChargeOnPurchase;

using Microsoft.Finance.ChargeGroup.ChargeGroupBase;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;

codeunit 18518 "Third Party Purchase Mgmt."
{
    procedure GenerateThirdPartyInvoice(PurchaseHeader: Record "Purchase Header")
    var
        IsHandled: Boolean;
    begin
        OnBeforeGenerateThirdpartyInvoice(PurchaseHeader, IsHandled);
        If IsHandled then
            exit;

        if not ThirdPartyInvoiceDetailsExistOnChargeGroup(PurchaseHeader."Charge Group Code") then
            exit;

        CreateThirdPartyInvoice(PurchaseHeader);
    end;

    procedure PostThirdPartyPurchaseInvoice(PurchaseHeader: Record "Purchase Header")
    var
        IsHandled: Boolean;
    begin
        OnBeforePostThirdpartyInvoice(PurchaseHeader, IsHandled);

        If IsHandled then
            exit;

        if not CheckThirdPartyInvoiceToPost(PurchaseHeader) then
            exit;

        PostThirdPartyInvoice(PurchaseHeader);
    end;

    local procedure CheckThirdPartyInvoiceToPost(PurchaseHeader: Record "Purchase Header"): Boolean
    var
        ChargeGroupHeader: Record "Charge Group Header";
    begin
        if not ChargeGroupHeader.Get(PurchaseHeader."Charge Group Code") then
            exit;

        if ChargeGroupHeader."Post Third Party Inv." then
            exit(true);
    end;

    local procedure CreateThirdPartyInvoice(PurchaseHeader: Record "Purchase Header")
    var
        ChargeGroupHeader: Record "Charge Group Header";
        ChargeGroupLines: Record "Charge Group Line";
    begin
        ChargeGroupHeader.Get(PurchaseHeader."Charge Group Code");
        RemoveThirdPartyInvoiceIfExist(PurchaseHeader);

        ChargeGroupLines.SetRange("Charge Group Code", PurchaseHeader."Charge Group Code");
        ChargeGroupLines.SetRange("Third Party Invoice", true);
        if ChargeGroupLines.Findset() then
            repeat
                ChargeGroupLines.TestField("Vendor No.");
                ChargeGroupLines.TestField("G/L Account No.");
                CreateSeperateAndCombineInvoices(PurchaseHeader, ChargeGroupLines);
            until ChargeGroupLines.Next() = 0;
    end;

    local procedure CreateSeperateAndCombineInvoices(PurchaseHeader: Record "Purchase Header"; ChargeGroupLines: Record "Charge Group Line")
    begin
        CreateSeperateInvoice(PurchaseHeader, ChargeGroupLines);
        CreateCombineInvoice(PurchaseHeader, ChargeGroupLines);
    end;

    local procedure CreateSeperateInvoice(PurchaseHeader: Record "Purchase Header"; ChargeGroupLines: Record "Charge Group Line")
    var
        ChargeGroupHeader: Record "Charge Group Header";
    begin
        ChargeGroupHeader.Get(PurchaseHeader."Charge Group Code");
        If ChargeGroupHeader."Invoice Combination" = ChargeGroupHeader."Invoice Combination"::"Separate Invoice" then
            CreatePurchaseInvoice(PurchaseHeader, ChargeGroupLines);
    end;

    local procedure CreateCombineInvoice(PurchaseHeader: Record "Purchase Header"; ChargeGroupLines: Record "Charge Group Line")
    var
        ChargeGroupHeader: Record "Charge Group Header";
    begin
        ChargeGroupHeader.Get(PurchaseHeader."Charge Group Code");
        If ChargeGroupHeader."Invoice Combination" = ChargeGroupHeader."Invoice Combination"::"Combine Invoice" then
            If not CheckThirdPartyVendorInvoiceExist(PurchaseHeader, ChargeGroupLines) then
                CreatePurchaseInvoice(PurchaseHeader, ChargeGroupLines)
            else
                UpdatePurchaseInvoice(PurchaseHeader, ChargeGroupLines);
    end;

    local procedure RemoveThirdPartyInvoiceIfExist(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseHeader2: Record "Purchase Header";
    begin
        PurchaseHeader2.SetCurrentKey("Charge Refernce Invoice No.");
        PurchaseHeader2.SetRange("Third Party", true);
        PurchaseHeader2.SetRange("Charge Refernce Invoice No.", PurchaseHeader."No.");
        If PurchaseHeader2.FindSet() then
            PurchaseHeader2.DeleteAll();
    end;

    local procedure ThirdPartyInvoiceDetailsExistOnChargeGroup(ChargeGroupCode: code[20]): Boolean
    var
        ChargeGroupLine: record "Charge Group Line";
    begin
        ChargeGroupLine.SetRange("Charge Group Code", ChargeGroupCode);
        ChargeGroupLine.SetRange("Third Party Invoice", true);
        if not ChargeGroupLine.IsEmpty then
            exit(true);
    end;

    local procedure CreatePurchaseInvoice(MainPurchaseHeader: Record "Purchase Header"; ChargeGroupLines: Record "Charge Group Line")
    Var
        InsertPurchaseHeader: Record "Purchase Header";
        ChargeGroupHeader: Record "Charge Group Header";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        IsHandled: Boolean;
    begin
        OnBeforeInsertPurchaseHeaderWithChargeGroup(MainPurchaseHeader, ChargeGroupLines, IsHandled);
        if IsHandled then
            exit;

        InsertPurchaseHeader.Init();
        InsertPurchaseHeader."Document Type" := InsertPurchaseHeader."Document Type"::Invoice;
        InsertPurchaseHeader."No." := NoSeriesManagement.GetNextNo(InsertPurchaseHeader.GetNoSeriesCode(), MainPurchaseHeader."Posting Date", true);
        InsertPurchaseHeader.Validate("Buy-from Vendor No.", ChargeGroupLines."Vendor No.");
        InsertPurchaseHeader.Validate("Posting Date", MainPurchaseHeader."Posting Date");
        InsertPurchaseHeader.Validate("Location Code", MainPurchaseHeader."Location Code");

        if ChargeGroupHeader.Get(MainPurchaseHeader."Charge Group Code") then
            if ChargeGroupHeader."Post Third Party Inv." then
                InsertPurchaseHeader.Validate("Vendor Invoice No.", InsertPurchaseHeader."No.");

        InsertPurchaseHeader.Validate("Third Party", true);
        InsertPurchaseHeader.Validate("Charge Refernce Invoice No.", MainPurchaseHeader."No.");
        InsertPurchaseHeader.Insert(true);


        OnAfterInsertPurchHeaderOnBeforeInsertLine(InsertPurchaseHeader, MainPurchaseHeader, ChargeGroupLines);
        CreatePurchaseLine(InsertPurchaseHeader, MainPurchaseHeader, ChargeGroupLines);
    end;

    local procedure CreatePurchaseLine(InsertPurchaseHeader: Record "Purchase Header"; MainPurchaseHeader: Record "Purchase Header"; ChargeGroupLines: Record "Charge Group Line")
    var
        InsertPurchaseLine: Record "Purchase Line";
        ChargeGroupMgmt: Codeunit "Charge Group Management";
        LineAmount: Decimal;
        TotalItemPurchaseAmt: Decimal;
        TotalItemQty: Decimal;
        LineNo: Integer;
        IsHandled: Boolean;
    begin
        OnBeforeCreatePurchaseLineWithHeader(InsertPurchaseHeader, MainPurchaseHeader, ChargeGroupLines, IsHandled);
        if IsHandled then
            exit;
        ChargeGroupMgmt.GetLineNo(InsertPurchaseHeader, LineNo);

        InsertPurchaseLine.Init();
        InsertPurchaseLine."Document Type" := InsertPurchaseHeader."Document Type";
        InsertPurchaseLine."Document No." := InsertPurchaseHeader."No.";
        InsertPurchaseLine."Line No." := LineNo;
        InsertPurchaseLine.Validate(Type, InsertPurchaseLine.Type::"G/L Account");
        InsertPurchaseLine.Validate("No.", ChargeGroupLines."G/L Account No.");
        InsertPurchaseLine.Validate(Quantity, 1);
        ChargeGroupMgmt.GetTotalAmount(MainPurchaseHeader, TotalItemPurchaseAmt, TotalItemQty);
        ChargeGroupMgmt.CalcLineAmount(ChargeGroupLines, TotalItemPurchaseAmt, TotalItemQty, LineAmount);
        InsertPurchaseLine.Validate("Direct Unit Cost", LineAmount);
        InsertPurchaseLine.Insert(true);
    end;

    local procedure CheckThirdPartyVendorInvoiceExist(PurchaseHeader: Record "Purchase Header"; ChargeGroupLines: Record "Charge Group Line"): Boolean
    var
        ThirdPartyPurchaseHeader: Record "Purchase Header";
    begin
        ThirdPartyPurchaseHeader.SetRange("Charge Refernce Invoice No.", PurchaseHeader."No.");
        ThirdPartyPurchaseHeader.SetRange("Buy-from Vendor No.", ChargeGroupLines."Vendor No.");
        if not ThirdPartyPurchaseHeader.IsEmpty then
            exit(true);
    end;

    local procedure UpdatePurchaseInvoice(PurchaseHeader: Record "Purchase Header"; ChargeGroupLines: Record "Charge Group Line")
    var
        ThirdPartyPurchaseHeader: Record "Purchase Header";
        IsHandled: Boolean;
    begin
        OnBeforeUpdatePurchaseInvoice(PurchaseHeader, ChargeGroupLines, IsHandled);
        if IsHandled then
            exit;

        ThirdPartyPurchaseHeader.SetRange("Charge Refernce Invoice No.", PurchaseHeader."No.");
        ThirdPartyPurchaseHeader.SetRange("Buy-from Vendor No.", ChargeGroupLines."Vendor No.");
        if ThirdPartyPurchaseHeader.FindFirst() then
            CreatePurchaseLine(ThirdPartyPurchaseHeader, PurchaseHeader, ChargeGroupLines);
    end;

    local procedure PostThirdPartyInvoice(PurchaseHeader: Record "Purchase Header")
    var
        ThirdPartyPurchaseHeader: Record "Purchase Header";
    begin
        ThirdPartyPurchaseHeader.SetRange("Charge Refernce Invoice No.", PurchaseHeader."No.");
        If ThirdPartyPurchaseHeader.FindSet() then
            repeat
                ThirdPartyPurchaseHeader.Invoice := true;
                ThirdPartyPurchaseHeader.SendToPosting(CodeUnit::"Purch.-Post");
            until ThirdPartyPurchaseHeader.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGenerateThirdpartyInvoice(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostThirdpartyInvoice(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertPurchaseHeaderWithChargeGroup(var MainPurchaseHeader: Record "Purchase Header"; var ChargeGroupLines: Record "Charge Group Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertPurchHeaderOnBeforeInsertLine(var CurrentPurchaseHeader: Record "Purchase Header"; var PreviousPurchaseHeader: Record "Purchase Header"; var ChargeGroupLines: Record "Charge Group Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreatePurchaseLineWithHeader(var NewPurchaseHeader: Record "Purchase Header"; var OldPurchaseHeader: Record "Purchase Header"; var ChargeGroupLines: Record "Charge Group Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdatePurchaseInvoice(var PurchaseHeader: Record "Purchase Header"; var ChargeGroupLines: Record "Charge Group Line"; var IsHandled: Boolean)
    begin
    end;

}
