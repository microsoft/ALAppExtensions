// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;
#if not CLEAN22
using Microsoft.Sales.Setup;
#endif

codeunit 11743 "Sales Header Handler CZL"
{
#if not CLEAN22
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
#endif
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInitRecord', '', false, false)]
    local procedure UpdateVatDateOnAfterInitRecord(var SalesHeader: Record "Sales Header")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        if not SalesHeader.IsReplaceVATDateEnabled() then begin
            SalesReceivablesSetup.Get();
            case SalesReceivablesSetup."Default VAT Date CZL" of
                SalesReceivablesSetup."Default VAT Date CZL"::"Posting Date":
                    SalesHeader."VAT Date CZL" := SalesHeader."Posting Date";
                SalesReceivablesSetup."Default VAT Date CZL"::"Document Date":
                    SalesHeader."VAT Date CZL" := SalesHeader."Document Date";
                SalesReceivablesSetup."Default VAT Date CZL"::Blank:
                    SalesHeader."VAT Date CZL" := 0D;
            end;
        end;
#pragma warning restore AL0432
#endif
        if SalesHeader.IsCreditDocType() then
            SalesHeader."Credit Memo Type CZL" := SalesHeader."Credit Memo Type CZL"::"Corrective Tax Document";
        SalesHeader.Validate("Credit Memo Type CZL");
    end;
#if not CLEAN22
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Posting Date', false, false)]
    local procedure UpdateVatDateOnBeforePostingDateValidate(var Rec: Record "Sales Header")
    begin
        if Rec.IsReplaceVATDateEnabled() then
            exit;
        SalesReceivablesSetup.Get();
        if SalesReceivablesSetup."Default VAT Date CZL" = SalesReceivablesSetup."Default VAT Date CZL"::"Posting Date" then
            Rec.Validate("VAT Date CZL", Rec."Posting Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Document Date', false, false)]
    local procedure UpdateVatDateOnBeforeDocumentDateValidate(var Rec: Record "Sales Header")
    begin
        if Rec.IsReplaceVATDateEnabled() then
            exit;
        SalesReceivablesSetup.Get();
        if SalesReceivablesSetup."Default VAT Date CZL" = SalesReceivablesSetup."Default VAT Date CZL"::"Document Date" then
            Rec.Validate("VAT Date CZL", Rec."Document Date");
    end;
#pragma warning restore AL0432
#endif

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnUpdateBillToCustOnAfterSalesQuote', '', false, false)]
    local procedure UpdateRegNoOnUpdateBillToCustOnAfterSalesQuote(var SalesHeader: Record "Sales Header"; Contact: Record Contact)
    begin
        SalesHeader."Registration No. CZL" := Contact.GetRegistrationNoTrimmedCZL();
        SalesHeader."Tax Registration No. CZL" := Contact."Tax Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterSetFieldsBilltoCustomer', '', false, false)]
    local procedure UpdateBankInfoAndRegNosOnAfterSetFieldsBilltoCustomer(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; Customer: Record Customer)
    begin
        if not SalesHeader.IsCreditDocType() then
            SalesHeader.Validate("Bank Account Code CZL", SalesHeader.GetDefaulBankAccountNoCZL())
        else
            SalesHeader.Validate("Bank Account Code CZL", Customer."Preferred Bank Account Code");
        SalesHeader."Registration No. CZL" := Customer.GetRegistrationNoTrimmedCZL();
        SalesHeader."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCopySellToCustomerAddressFieldsFromCustomer', '', false, false)]
    local procedure UpdateOnAfterCopySellToCustomerAddressFieldsFromCustomer(var SalesHeader: Record "Sales Header"; SellToCustomer: Record Customer)
    begin
        SalesHeader."Registration No. CZL" := SellToCustomer.GetRegistrationNoTrimmedCZL();
        SalesHeader."Tax Registration No. CZL" := SellToCustomer."Tax Registration No. CZL";
#if not CLEAN22
#pragma warning disable AL0432
        if SellToCustomer."Transaction Type CZL" <> '' then
            SalesHeader."Transaction Type" := SellToCustomer."Transaction Type CZL";
        SalesHeader."Transaction Specification" := SellToCustomer."Transaction Specification CZL";
        SalesHeader."Transport Method" := SellToCustomer."Transport Method CZL";
#pragma warning restore AL0432
#endif
        if SalesHeader.IsCreditDocType() then
            SalesHeader.Validate("Shipment Method Code", SellToCustomer."Shipment Method Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterCopyShipToCustomerAddressFieldsFromCustomer', '', false, false)]
    local procedure UpdateOnAfterCopyShipToCustomerAddressFieldsFromCustomer(var SalesHeader: Record "Sales Header"; SellToCustomer: Record Customer)
    begin
        SalesHeader."VAT Country/Region Code" := SellToCustomer."Country/Region Code";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'EU 3-Party Trade', false, false)]
    local procedure UpdateEU3PartyIntermedRoleOnBeforeEU3PartyTradeValidate(var Rec: Record "Sales Header")
    begin
        if not Rec."EU 3-Party Trade" then
            Rec."EU 3-Party Intermed. Role CZL" := false;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeValidateEvent', 'Currency Code', false, false)]
    local procedure UpdateVatCurrencyCodeCZLOnBeforeCurrencyCodeValidate(var Rec: Record "Sales Header")
    begin
        Rec.Validate("VAT Currency Code CZL", Rec."Currency Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Currency Factor', false, false)]
    local procedure UpdateVATCurrencyfactorCZLOnBeforeCurrencyFactorValidate(var Rec: Record "Sales Header")
    begin
        Rec.UpdateVATCurrencyFactorCZLByCurrencyFactorCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterUpdateCurrencyFactor', '', false, false)]
    local procedure OnAfterUpdateCurrencyFactor(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.UpdateVATCurrencyFactorCZLByCurrencyFactorCZL()
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInitFromSalesHeader', '', false, false)]
    local procedure UpdateBankAccountOnAfterInitFromSalesHeader(var SalesHeader: Record "Sales Header"; SourceSalesHeader: Record "Sales Header")
    begin
        SalesHeader."Bank Account Code CZL" := SourceSalesHeader."Bank Account Code CZL";
        SalesHeader."Bank Name CZL" := SourceSalesHeader."Bank Name CZL";
        SalesHeader."Bank Account No. CZL" := SourceSalesHeader."Bank Account No. CZL";
        SalesHeader."Bank Branch No. CZL" := SourceSalesHeader."Bank Branch No. CZL";
        SalesHeader."IBAN CZL" := SourceSalesHeader."IBAN CZL";
        SalesHeader."SWIFT Code CZL" := SourceSalesHeader."SWIFT Code CZL";
        SalesHeader."Transit No. CZL" := SourceSalesHeader."Transit No. CZL";
    end;
#if not CLEAN22
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnUpdateSalesLineByChangedFieldName', '', false, false)]
    local procedure UpdateSalesLineByChangedFieldName(SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; ChangedFieldName: Text[100]; ChangedFieldNo: Integer)
    begin
        case ChangedFieldNo of
#pragma warning disable AL0432
            SalesHeader.FieldNo("Physical Transfer CZL"):
                if (SalesLine.Type = SalesLine.Type::Item) and (SalesLine."No." <> '') then
                    SalesLine."Physical Transfer CZL" := SalesHeader."Physical Transfer CZL";
#pragma warning restore AL0432
        end;
    end;
#endif

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterUpdateShipToAddress', '', false, false)]
    local procedure UpdateVATCountryRegionCodeOnAfterUpdateShipToAddress(var SalesHeader: Record "Sales Header")
    begin
        if SalesHeader.IsCreditDocType() then
            SalesHeader.Validate("VAT Country/Region Code", SalesHeader."Sell-to Country/Region Code");
    end;
}
