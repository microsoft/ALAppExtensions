// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Document;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
#if not CLEAN22
using Microsoft.Purchases.Setup;
#endif
using Microsoft.Purchases.Vendor;

codeunit 11744 "Purchase Header Handler CZL"
{
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
#if not CLEAN22
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
#endif

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterInitRecord', '', false, false)]
    local procedure UpdateVatDateOnAfterInitRecord(var PurchHeader: Record "Purchase Header")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        if not PurchHeader.IsReplaceVATDateEnabled() then begin
            PurchasesPayablesSetup.Get();
            case PurchasesPayablesSetup."Default VAT Date CZL" of
                PurchasesPayablesSetup."Default VAT Date CZL"::"Posting Date":
                    PurchHeader."VAT Date CZL" := PurchHeader."Posting Date";
                PurchasesPayablesSetup."Default VAT Date CZL"::"Document Date":
                    PurchHeader."VAT Date CZL" := PurchHeader."Document Date";
                PurchasesPayablesSetup."Default VAT Date CZL"::Blank:
                    PurchHeader."VAT Date CZL" := 0D;
            end
        end else
            PurchHeader."VAT Date CZL" := GeneralLedgerSetup.GetVATDate(PurchHeader."Posting Date", PurchHeader."Document Date");
        if PurchHeader."VAT Reporting Date" = 0D then
            PurchHeader."VAT Reporting Date" := PurchHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        PurchHeader."Original Doc. VAT Date CZL" :=
            GeneralLedgerSetup.GetOriginalDocumentVATDateCZL(PurchHeader."Posting Date", PurchHeader."VAT Reporting Date", PurchHeader."Document Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Posting Date', false, false)]
    local procedure UpdateVatDateOnBeforePostingDateValidate(var Rec: Record "Purchase Header")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        PurchasesPayablesSetup.Get();
        if not Rec.IsReplaceVATDateEnabled() then
            if PurchasesPayablesSetup."Default VAT Date CZL" = PurchasesPayablesSetup."Default VAT Date CZL"::"Posting Date" then
                Rec.Validate("VAT Date CZL", Rec."Posting Date");
#pragma warning restore AL0432
#endif
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.UpdateOriginalDocumentVATDateCZL(Rec."Posting Date", Enum::"Default Orig.Doc. VAT Date CZL"::"Posting Date", Rec."Original Doc. VAT Date CZL");
        Rec.Validate("Original Doc. VAT Date CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Document Date', false, false)]
    local procedure UpdateVatDateOnBeforeDocumentDateValidate(var Rec: Record "Purchase Header")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        PurchasesPayablesSetup.Get();
        if not Rec.IsReplaceVATDateEnabled() then
            if PurchasesPayablesSetup."Default VAT Date CZL" = PurchasesPayablesSetup."Default VAT Date CZL"::"Document Date" then
                Rec.Validate("VAT Date CZL", Rec."Document Date");
#pragma warning restore AL0432
#endif
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.UpdateOriginalDocumentVATDateCZL(Rec."Document Date", Enum::"Default Orig.Doc. VAT Date CZL"::"Document Date", Rec."Original Doc. VAT Date CZL");
        Rec.Validate("Original Doc. VAT Date CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterCopyBuyFromVendorFieldsFromVendor', '', false, false)]
    local procedure UpdateOnAfterCopyBuyFromVendorFieldsFromVendor(var PurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    begin
        PurchaseHeader."Registration No. CZL" := Vendor.GetRegistrationNoTrimmedCZL();
        PurchaseHeader."Tax Registration No. CZL" := Vendor."Tax Registration No. CZL";
#if not CLEAN22
#pragma warning disable AL0432
        if (Vendor."Transaction Type CZL" <> '') and
           (Vendor."Transaction Type CZL" <> PurchaseHeader."Transaction Type")
        then
            PurchaseHeader.Validate("Transaction Type", Vendor."Transaction Type CZL");
        if Vendor."Transaction Specification CZL" <> PurchaseHeader."Transaction Specification" then
            PurchaseHeader.Validate("Transaction Specification", Vendor."Transaction Specification CZL");
        if Vendor."Transport Method CZL" <> PurchaseHeader."Transport Method" then
            PurchaseHeader.Validate("Transport Method", Vendor."Transport Method CZL");
#pragma warning restore AL0432
#endif
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

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Currency Code', false, false)]
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
#if not CLEAN22
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnUpdatePurchLinesByChangedFieldName', '', false, false)]
    local procedure UpdatePurchLinesByChangedFieldName(PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; ChangedFieldName: Text[100]; ChangedFieldNo: Integer)
    begin
        case ChangedFieldNo of
#pragma warning disable AL0432
            PurchHeader.FieldNo("Physical Transfer CZL"):
                if (PurchLine.Type = PurchLine.Type::Item) and (PurchLine."No." <> '') then
                    PurchLine."Physical Transfer CZL" := PurchHeader."Physical Transfer CZL";
#pragma warning restore AL0432
        end;
    end;
#endif

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
