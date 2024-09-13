// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

using Microsoft.CRM.Contact;
using Microsoft.Sales.Customer;

codeunit 11743 "Sales Header Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterInitRecord', '', false, false)]
    local procedure UpdateVatDateOnAfterInitRecord(var SalesHeader: Record "Sales Header")
    begin
        if SalesHeader.IsCreditDocType() then
            SalesHeader."Credit Memo Type CZL" := SalesHeader."Credit Memo Type CZL"::"Corrective Tax Document";
        SalesHeader.Validate("Credit Memo Type CZL");
        SalesHeader.UpdateAddCurrencyFactorCZL();
    end;

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

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Currency Code', false, false)]
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

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterUpdateShipToAddress', '', false, false)]
    local procedure UpdateVATCountryRegionCodeOnAfterUpdateShipToAddress(var SalesHeader: Record "Sales Header")
    begin
        if SalesHeader.IsCreditDocType() then
            SalesHeader.Validate("VAT Country/Region Code", SalesHeader."Sell-to Country/Region Code");
    end;
}
