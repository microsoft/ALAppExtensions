// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Utilities;

using Microsoft.Purchases.Archive;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;

codeunit 11740 "Copy Document Mgt. Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterTransfldsFromSalesToPurchLine', '', false, false)]
    local procedure TariffNoOnAfterTransfldsFromSalesToPurchLine(var FromSalesLine: Record "Sales Line"; var ToPurchaseLine: Record "Purchase Line")
    begin
        ToPurchaseLine."Tariff No. CZL" := FromSalesLine."Tariff No. CZL";
#if not CLEAN22
#pragma warning disable AL0432
        ToPurchaseLine."Country/Reg. of Orig. Code CZL" := FromSalesLine."Country/Reg. of Orig. Code CZL";
#pragma warning restore AL0432
#endif
        ToPurchaseLine."Net Weight" := FromSalesLine."Net Weight";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopyFieldsFromOldSalesHeader', '', false, false)]
    local procedure CopyCreditMemoTypeFromOldSalesHeader(var ToSalesHeader: Record "Sales Header"; OldSalesHeader: Record "Sales Header")
    begin
        if ToSalesHeader.IsCreditDocType() then
            ToSalesHeader."Credit Memo Type CZL" := OldSalesHeader."Credit Memo Type CZL"
        else
            Clear(ToSalesHeader."Credit Memo Type CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopySalesDocUpdateHeaderOnBeforeUpdateCustLedgerEntry', '', false, false)]
    local procedure UpdateBankInfoOnCopySalesDocUpdateHeaderOnBeforeUpdateCustLedgerEntry(var ToSalesHeader: Record "Sales Header"; FromDocType: Option)
    var
        Customer: Record Customer;
    begin
        if (ToSalesHeader.IsCreditDocType() and not
                (FromDocType in ["Sales Document Type From"::"Return Order".AsInteger(),
                                "Sales Document Type From"::"Credit Memo".AsInteger(),
                                "Sales Document Type From"::"Posted Credit Memo".AsInteger()])) or
           (not ToSalesHeader.IsCreditDocType() and
                (FromDocType in ["Sales Document Type From"::"Return Order".AsInteger(),
                                "Sales Document Type From"::"Credit Memo".AsInteger(),
                                "Sales Document Type From"::"Posted Credit Memo".AsInteger()]))
        then begin
            ToSalesHeader."Specific Symbol CZL" := '';
            ToSalesHeader."Variable Symbol CZL" := '';
            ToSalesHeader."Constant Symbol CZL" := '';
            if not ToSalesHeader.IsCreditDocType() then
                ToSalesHeader.Validate("Bank Account Code CZL", ToSalesHeader.GetDefaulBankAccountNoCZL())
            else begin
                Customer.Get(ToSalesHeader."Bill-to Customer No.");
                ToSalesHeader.Validate("Bank Account Code CZL", Customer."Preferred Bank Account Code");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopyPurchDocUpdateHeaderOnBeforeUpdateVendLedgerEntry', '', false, false)]
    local procedure UpdateBankInfoOnCopyPurchDocUpdateHeaderOnBeforeUpdateVendLedgerEntry(var ToPurchaseHeader: Record "Purchase Header"; FromDocType: Option)
    var
        Vendor: Record Vendor;
    begin
        if (ToPurchaseHeader.IsCreditDocType() and not
                (FromDocType in ["Purchase Document Type From"::"Return Order".AsInteger(),
                                "Purchase Document Type From"::"Credit Memo".AsInteger(),
                                "Purchase Document Type From"::"Posted Credit Memo".AsInteger()])) or
           (not ToPurchaseHeader.IsCreditDocType() and
                (FromDocType in ["Purchase Document Type From"::"Return Order".AsInteger(),
                                "Purchase Document Type From"::"Credit Memo".AsInteger(),
                                "Purchase Document Type From"::"Posted Credit Memo".AsInteger()]))
        then begin
            ToPurchaseHeader."Specific Symbol CZL" := '';
            ToPurchaseHeader."Variable Symbol CZL" := '';
            ToPurchaseHeader."Constant Symbol CZL" := '';
            if ToPurchaseHeader.IsCreditDocType() then
                ToPurchaseHeader.Validate("Bank Account Code CZL", ToPurchaseHeader.GetDefaulBankAccountNoCZL())
            else begin
                Vendor.Get(ToPurchaseHeader."Pay-to Vendor No.");
                ToPurchaseHeader.Validate("Bank Account Code CZL", Vendor."Preferred Bank Account Code");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopySalesHeaderArchive', '', false, false)]
    local procedure UpdatePostingDateOnAfterCopySalesHeaderArchive(var ToSalesHeader: Record "Sales Header"; OldSalesHeader: Record "Sales Header"; FromSalesHeaderArchive: Record "Sales Header Archive")
    begin
        if FromSalesHeaderArchive."Document Type" = FromSalesHeaderArchive."Document Type"::Quote then
            if OldSalesHeader."Posting Date" = 0D then
                ToSalesHeader."Posting Date" := WorkDate()
            else
                ToSalesHeader."Posting Date" := OldSalesHeader."Posting Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopyPurchHeaderArchive', '', false, false)]
    local procedure UpdatePostingDateOnAfterCopyPurchHeaderArchive(var ToPurchaseHeader: Record "Purchase Header"; OldPurchaseHeader: Record "Purchase Header"; FromPurchaseHeaderArchive: Record "Purchase Header Archive")
    begin
        if FromPurchaseHeaderArchive."Document Type" = FromPurchaseHeaderArchive."Document Type"::Quote then
            if OldPurchaseHeader."Posting Date" = 0D then
                ToPurchaseHeader."Posting Date" := WorkDate()
            else
                ToPurchaseHeader."Posting Date" := OldPurchaseHeader."Posting Date";
    end;
#if not CLEAN22

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterUpdatePurchLine', '', false, false)]
    local procedure UpdatePurchLineOnAfterUpdatePurchLine(var ToPurchHeader: Record "Purchase Header"; var ToPurchLine: Record "Purchase Line")
    begin
#pragma warning disable AL0432
        ToPurchLine."Physical Transfer CZL" := ToPurchHeader."Physical Transfer CZL";
#pragma warning restore AL0432
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterUpdateSalesLine', '', false, false)]
    local procedure UpdateSalesLineOnAfterUpdateSalesLine(var ToSalesHeader: Record "Sales Header"; var ToSalesLine: Record "Sales Line")
    begin
#pragma warning disable AL0432
        ToSalesLine."Physical Transfer CZL" := ToSalesHeader."Physical Transfer CZL";
#pragma warning restore AL0432
    end;
#endif
}
