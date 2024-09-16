// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Purchases.Vendor;

codeunit 11744 "Purchase Header Handler CZL"
{
    var
        GeneralLedgerSetup: Record "General Ledger Setup";

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterInitRecord', '', false, false)]
    local procedure UpdateVatDateOnAfterInitRecord(var PurchHeader: Record "Purchase Header")
    begin
        PurchHeader."Original Doc. VAT Date CZL" :=
            GeneralLedgerSetup.GetOriginalDocumentVATDateCZL(PurchHeader."Posting Date", PurchHeader."VAT Reporting Date", PurchHeader."Document Date");
        PurchHeader.UpdateAddCurrencyFactorCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Posting Date', false, false)]
    local procedure UpdateVatDateOnBeforePostingDateValidate(var Rec: Record "Purchase Header")
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.UpdateOriginalDocumentVATDateCZL(Rec."Posting Date", Enum::"Default Orig.Doc. VAT Date CZL"::"Posting Date", Rec."Original Doc. VAT Date CZL");
        Rec.Validate("Original Doc. VAT Date CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Document Date', false, false)]
    local procedure UpdateVatDateOnBeforeDocumentDateValidate(var Rec: Record "Purchase Header")
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.UpdateOriginalDocumentVATDateCZL(Rec."Document Date", Enum::"Default Orig.Doc. VAT Date CZL"::"Document Date", Rec."Original Doc. VAT Date CZL");
        Rec.Validate("Original Doc. VAT Date CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterCopyBuyFromVendorFieldsFromVendor', '', false, false)]
    local procedure UpdateOnAfterCopyBuyFromVendorFieldsFromVendor(var PurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    begin
        PurchaseHeader."Registration No. CZL" := Vendor.GetRegistrationNoTrimmedCZL();
        PurchaseHeader."Tax Registration No. CZL" := Vendor."Tax Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnValidatePurchaseHeaderPayToVendorNoOnBeforeCheckDocType', '', false, false)]
    local procedure UpdateBankInfoAndRegNosOnValidatePurchaseHeaderPayToVendorNo(var PurchaseHeader: Record "Purchase Header"; var xPurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    begin
        if PurchaseHeader.IsCreditDocType() then
            PurchaseHeader.Validate("Bank Account Code CZL", PurchaseHeader.GetDefaulBankAccountNoCZL())
        else
            PurchaseHeader.Validate("Bank Account Code CZL", Vendor."Preferred Bank Account Code");
        PurchaseHeader."Registration No. CZL" := Vendor.GetRegistrationNoTrimmedCZL();
        PurchaseHeader."Tax Registration No. CZL" := Vendor."Tax Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Currency Code', false, false)]
    local procedure UpdateVatCurrencyCodeCZLOnBeforeCurrencyCodeValidate(var Rec: Record "Purchase Header")
    begin
        Rec.Validate("VAT Currency Code CZL", Rec."Currency Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Currency Factor', false, false)]
    local procedure UpdateVATCurrencyfactorCZLOnBeforeCurrencyFactorValidate(var Rec: Record "Purchase Header")
    begin
        Rec.UpdateVATCurrencyFactorCZLByCurrencyFactorCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterUpdateCurrencyFactor', '', false, false)]
    local procedure OnAfterUpdateCurrencyFactor(var PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader.UpdateVATCurrencyFactorCZLByCurrencyFactorCZL()
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnInitFromPurchHeader', '', false, false)]
    local procedure UpdateBankAccountOnInitPurchHeader(var PurchaseHeader: Record "Purchase Header"; SourcePurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader."Bank Account Code CZL" := SourcePurchaseHeader."Bank Account Code CZL";
        PurchaseHeader."Bank Name CZL" := SourcePurchaseHeader."Bank Name CZL";
        PurchaseHeader."Bank Account No. CZL" := SourcePurchaseHeader."Bank Account No. CZL";
        PurchaseHeader."Bank Branch No. CZL" := SourcePurchaseHeader."Bank Branch No. CZL";
        PurchaseHeader."IBAN CZL" := SourcePurchaseHeader."IBAN CZL";
        PurchaseHeader."SWIFT Code CZL" := SourcePurchaseHeader."SWIFT Code CZL";
        PurchaseHeader."Transit No. CZL" := SourcePurchaseHeader."Transit No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'VAT Country/Region Code', false, false)]
    local procedure UpdateVATRegistrationNoCodeOnAfterVATCountryRegionCodeValidate(var Rec: Record "Purchase Header")
    var
        PayToVendor: Record Vendor;
    begin
        if Rec."Pay-to Vendor No." <> '' then begin
            PayToVendor.Get(Rec."Pay-to Vendor No.");
            Rec."VAT Registration No." := PayToVendor."VAT Registration No.";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterValidateEvent', 'Buy-from Country/Region Code', false, false)]
    local procedure UpdateVATCountryRegionCodeOnAfterBuyFromCountryRegionCodeValidate(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header")
    begin
        if (Rec."Buy-from Country/Region Code" <> xRec."Buy-from Country/Region Code") and (xRec."Buy-from Country/Region Code" <> '') then
            Rec.Validate("VAT Country/Region Code", Rec."Buy-from Country/Region Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnValidateOrderAddressCodeOnAfterCopyBuyFromVendorAddressFieldsFromVendor', '', false, false)]
    local procedure UpdateVATCountryRegionCodeOnValidateOrderAddressCodeOnAfterCopyBuyFromVendorAddressFieldsFromVendor(var PurchaseHeader: Record "Purchase Header"; Vend: Record Vendor)
    begin
        PurchaseHeader.Validate("VAT Country/Region Code", Vend."Country/Region Code");
    end;
}
