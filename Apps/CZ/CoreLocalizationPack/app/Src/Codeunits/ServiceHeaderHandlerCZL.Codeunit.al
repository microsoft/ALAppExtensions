// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Document;

using Microsoft.Sales.Customer;

codeunit 11745 "Service Header Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterInitRecord', '', false, false)]
    local procedure UpdateVatDateOnAfterInitRecord(var ServiceHeader: Record "Service Header")
    begin
        if ServiceHeader."Document Type" = ServiceHeader."Document Type"::"Credit Memo" then
            ServiceHeader."Credit Memo Type CZL" := ServiceHeader."Credit Memo Type CZL"::"Corrective Tax Document";
        ServiceHeader.Validate("Credit Memo Type CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterCopyCustomerFields', '', false, false)]
    local procedure UpdateRegNoOnAfterCopyCustomerFields(var ServiceHeader: Record "Service Header"; Customer: Record Customer)
    begin
        ServiceHeader."Registration No. CZL" := Customer.GetRegistrationNoTrimmedCZL();
        ServiceHeader."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterCopyBillToCustomerFields', '', false, false)]
    local procedure UpdateUpdateBankInfoAndRegNosOnAfterCopyBillToCustomerFields(var ServiceHeader: Record "Service Header"; Customer: Record Customer)
    begin
        if ServiceHeader."Document Type" <> ServiceHeader."Document Type"::"Credit Memo" then
            ServiceHeader.Validate("Bank Account Code CZL", ServiceHeader.GetDefaulBankAccountNoCZL())
        else
            ServiceHeader.Validate("Bank Account Code CZL", Customer."Preferred Bank Account Code");
        ServiceHeader."Registration No. CZL" := Customer.GetRegistrationNoTrimmedCZL();
        ServiceHeader."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
        ServiceHeader."VAT Registration No." := Customer."VAT Registration No.";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeValidateEvent', 'EU 3-Party Trade', false, false)]
    local procedure UpdateEU3PartyIntermedRoleOnBeforeEU3PartyTradeValidate(var Rec: Record "Service Header")
    begin
        if not Rec."EU 3-Party Trade" then
            Rec."EU 3-Party Intermed. Role CZL" := false;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeValidateEvent', 'Currency Code', false, false)]
    local procedure UpdateVatCurrencyCodeCZLOnBeforeCurrencyCodeValidate(var Rec: Record "Service Header")
    begin
        Rec.Validate("VAT Currency Code CZL", Rec."Currency Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'Currency Code', false, false)]
    local procedure UpdateVatCurrencyfactorCZLOnAfterCurrencyCodeValidate(var Rec: Record "Service Header"; var xRec: Record "Service Header"; CurrFieldNo: Integer)
    begin
        if CurrFieldNo <> Rec.FieldNo("Currency Code") then
            Rec.UpdateVATCurrencyFactorCZL()
        else
            if (Rec."Currency Code" <> xRec."Currency Code") or (Rec."Currency Code" <> '') then
                Rec.UpdateVATCurrencyFactorCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnBeforeValidateEvent', 'Currency Factor', false, false)]
    local procedure UpdateVATCurrencyfactorCZLOnBeforeCurrencyFactorValidate(var Rec: Record "Service Header")
    begin
        Rec.UpdateVATCurrencyFactorCZL();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Header", 'OnAfterValidateEvent', 'VAT Country/Region Code', false, false)]
    local procedure UpdateVATRegistrationNoCodeOnAfterVATCountryRegionCodeValidate(var Rec: Record "Service Header")
    var
        BillToCustomer: Record Customer;
    begin
        if Rec."Bill-to Customer No." <> '' then begin
            BillToCustomer.Get(Rec."Bill-to Customer No.");
            Rec."VAT Registration No." := BillToCustomer."VAT Registration No.";
        end;
    end;
}
