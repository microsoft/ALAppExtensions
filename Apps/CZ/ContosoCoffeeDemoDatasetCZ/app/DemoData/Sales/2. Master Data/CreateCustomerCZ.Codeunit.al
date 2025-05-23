// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.CRM.Contact;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Foundation;
using Microsoft.Sales.Customer;

codeunit 31293 "Create Customer CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateCustomer: Codeunit "Create Customer";
    begin
        UpdateContact(CreateCustomer.DomesticAdatumCorporation(), AdatumCorporationContactLbl);
        UpdateContact(CreateCustomer.DomesticTreyResearch(), TreyResearchContactLbl);
        UpdateContact(CreateCustomer.DomesticRelecloud(), RelecloudContactLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertCustomer(var Rec: Record Customer)
    var
        CreateCurrency: Codeunit "Create Currency";
        CreateCustomer: Codeunit "Create Customer";
        CreateLanguage: Codeunit "Create Language";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        case Rec."No." of
            CreateCustomer.DomesticAdatumCorporation():
                ValidateCustomer(Rec, AdatumCorporationAddressLbl, CreateLanguage.CSY(), CreatePaymentTerms.PaymentTermsM8D(), '', '696 42', 'CZ789456278', 'jiri.lehnert@contoso.com');
            CreateCustomer.DomesticTreyResearch():
                ValidateCustomer(Rec, TreyResearchAddressLbl, CreateLanguage.CSY(), CreatePaymentTerms.PaymentTermsDAYS14(), '', '696 42', 'CZ733495789', 'nela.hrdlickova@contoso.com');
            CreateCustomer.ExportSchoolofArt():
                ValidateCustomer(Rec, '', CreateLanguage.ENU(), CreatePaymentTerms.PaymentTermsM8D(), CreateCurrency.USD(), 'FL 37125', '', '');
            CreateCustomer.EUAlpineSkiHouse():
                ValidateCustomer(Rec, '', CreateLanguage.DEU(), CreatePaymentTerms.PaymentTermsM8D(), CreateCurrency.EUR(), 'DE-80807', '582048936', '');
            CreateCustomer.DomesticRelecloud():
                ValidateCustomer(Rec, RelecloudAddressLbl, CreateLanguage.CSY(), CreatePaymentTerms.PaymentTermsCOD(), '', '669 02', '', 'jakub.pajer@contoso.com');
        end;
    end;

    local procedure UpdateContact(CustomerNo: Code[20]; ContactName: Text[100])
    var
        Contact: Record Contact;
        Customer: Record Customer;
    begin
        if not Customer.Get(CustomerNo) then
            exit;
        Contact.Get(Customer."Primary Contact No.");
        Contact.Validate(Name, ContactName);
        Contact.Modify(true);
    end;

    local procedure ValidateCustomer(var Customer: Record Customer; Address: Text[100]; LanguageCode: Code[10]; PaymentTermCode: Code[10]; CurrencyCode: Code[20]; PostCode: Code[20]; VatRegistraionNo: Text[20]; Email: Text[80])
    begin
        Customer."Format Region" := '';
        Customer.Validate("Language Code", LanguageCode);
        Customer.Validate("Payment Terms Code", PaymentTermCode);
        Customer.Validate("Currency Code", CurrencyCode);
        Customer.Validate("Post Code", PostCode);
        Customer.Validate("VAT Registration No.", VatRegistraionNo);
        Customer.Validate("Address 2", '');
        if Address <> '' then
            Customer.Validate(Address, Address);
        if Email <> '' then
            Customer.Validate("E-Mail", Email);
    end;

    var
        AdatumCorporationContactLbl: Label 'Jiří Lehnert', Locked = true;
        AdatumCorporationAddressLbl: Label 'Vrchlického 5', Locked = true;
        TreyResearchContactLbl: Label 'Nela Hrdličková', Locked = true;
        TreyResearchAddressLbl: Label 'Komenského 12', Locked = true;
        RelecloudContactLbl: Label 'Jakub Pajer', Locked = true;
        RelecloudAddressLbl: Label 'Vodární 25', Locked = true;
}
