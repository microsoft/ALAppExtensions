// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.CRM.Contact;
using Microsoft.DemoTool;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Foundation;
using Microsoft.Purchases.Vendor;

codeunit 31298 "Create Vendor CZ"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateVendor: Codeunit "Create Vendor";
    begin
        UpdateContact(CreateVendor.DomesticFirstUp(), FirstUpContactLbl);
        UpdateContact(CreateVendor.DomesticWorldImporter(), WorldImporterContactLbl);
        UpdateContact(CreateVendor.DomesticNodPublisher(), NodPublisherContactLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVendor(var Rec: Record Vendor)
    var
        CreateCurrency: Codeunit "Create Currency";
        CreateVendor: Codeunit "Create Vendor";
        CreateLanguage: Codeunit "Create Language";
    begin
        case Rec."No." of
            CreateVendor.ExportFabrikam():
                ValidateVendor(Rec, '', CreateLanguage.ENU(), CreateCurrency.USD(), 'US-GA 31772', '', '');
            CreateVendor.DomesticFirstUp():
                ValidateVendor(Rec, FirstUpAddressLbl, CreateLanguage.CSY(), '', '669 02', 'CZ197548769', 'adam.fisar@contoso.com');
            CreateVendor.EUGraphicDesign():
                ValidateVendor(Rec, '', CreateLanguage.DEU(), CreateCurrency.EUR(), 'DE-72800', '', '');
            CreateVendor.DomesticWorldImporter():
                ValidateVendor(Rec, WorldImporterAddressLbl, CreateLanguage.CSY(), '', '687 71', 'CZ222459523', 'milos.macek@contoso.com');
            CreateVendor.DomesticNodPublisher():
                ValidateVendor(Rec, NodPublisherAddressLbl, CreateLanguage.CSY(), '', '697 01', 'CZ295267495', 'vilem.petrzelka@contoso.com');
        end;
    end;

    local procedure UpdateContact(VendorNo: Code[20]; ContactName: Text[100])
    var
        Contact: Record Contact;
        Vendor: Record Vendor;
    begin
        if not Vendor.Get(VendorNo) then
            exit;
        Contact.Get(Vendor."Primary Contact No.");
        Contact.Validate(Name, ContactName);
        Contact.Modify(true);
    end;

    local procedure ValidateVendor(var Vendor: Record Vendor; Address: Text[100]; LanguageCode: Code[10]; CurrencyCode: Code[20]; PostCode: Code[20]; VatRegistrationNo: Text[20]; Email: Text[80])
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        Vendor."Format Region" := '';
        Vendor."Disable Unreliab. Check CZL" := Vendor."Country/Region Code" = ContosoCoffeeDemoDataSetup."Country/Region Code";
        Vendor.Validate("Language Code", LanguageCode);
        Vendor.Validate("Currency Code", CurrencyCode);
        Vendor.Validate("Post Code", PostCode);
        Vendor.Validate("VAT Registration No.", VatRegistrationNo);
        Vendor.Validate("Address 2", '');
        Vendor.Validate("Disable Unreliab. Check CZL", true);
        if Address <> '' then
            Vendor.Validate(Address, Address);
        if Email <> '' then
            Vendor.Validate("E-Mail", Email);
    end;

    var
        FirstUpContactLbl: Label 'Adam Fisar', Locked = true;
        FirstUpAddressLbl: Label 'Krajinská 125', Locked = true;
        WorldImporterContactLbl: Label 'Miloš Macek', Locked = true;
        WorldImporterAddressLbl: Label 'U Kovárny 15', Locked = true;
        NodPublisherContactLbl: Label 'Vilém Petrželka', Locked = true;
        NodPublisherAddressLbl: Label 'Na hrázi 48', Locked = true;
}
