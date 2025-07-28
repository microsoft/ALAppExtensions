// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Address;

/// <summary>
/// Codeunit Shpfy Company Export (ID 30284).
/// </summary>
codeunit 30284 "Shpfy Company Export"
{
    Access = Internal;
    TableNo = Customer;

    trigger OnRun()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
    begin
        Customer.CopyFilters(Rec);
        if Customer.FindSet(false) then
            repeat
                ShopifyCompany.SetRange("Shop Code", Shop.Code);
                ShopifyCompany.SetRange("Customer SystemId", Customer.SystemId);
                if not ShopifyCompany.FindFirst() then begin
                    if CreateCustomers then
                        CreateShopifyCompany(Customer)
                end else
                    if not CreateCustomers then
                        UpdateShopifyCompany(Customer, ShopifyCompany.Id);
                Commit();
            until Customer.Next() = 0;
    end;

    var
        Shop: Record "Shpfy Shop";
        CompanyAPI: Codeunit "Shpfy Company API";
        CatalogAPI: Codeunit "Shpfy Catalog API";
        MetafieldAPI: Codeunit "Shpfy Metafield API";
        SkippedRecord: Codeunit "Shpfy Skipped Record";
        CreateCustomers: Boolean;
        CountyCodeTooLongLbl: Label 'Can not export customer %1 %2. The length of the string is %3, but it must be less than or equal to %4 characters. Value: %5, field: %6', Comment = '%1 - Customer No., %2 - Customer Name, %3 - Length, %4 - Max Length, %5 - Value, %6 - Field Name';
        EmptyEmailAddressLbl: Label 'Customer (Company) has no e-mail address.';
        CompanyWithPhoneNoOrEmailExistsLbl: Label 'Company already exists with the same e-mail or phone.';

    local procedure CreateShopifyCompany(Customer: Record Customer)
    var
        ShopifyCompany: Record "Shpfy Company";
        ShopifyCustomer: Record "Shpfy Customer";
        CompanyLocation: Record "Shpfy Company Location";
    begin
        if Customer."E-Mail" = '' then begin
            SkippedRecord.LogSkippedRecord(Customer.RecordId, EmptyEmailAddressLbl, Shop);
            exit;
        end;

        if CreateCompanyMainContact(Customer, ShopifyCustomer) then
            if FillInShopifyCompany(Customer, ShopifyCompany) or FillInShopifyCompanyLocation(Customer, CompanyLocation) then
                if CompanyAPI.CreateCompany(ShopifyCompany, CompanyLocation, ShopifyCustomer) then begin
                    ShopifyCompany."Main Contact Customer Id" := ShopifyCustomer.Id;
                    ShopifyCompany."Customer SystemId" := Customer.SystemId;
                    ShopifyCompany."Last Updated by BC" := CurrentDateTime();
                    ShopifyCompany."Shop Id" := Shop."Shop Id";
                    ShopifyCompany."Shop Code" := Shop.Code;
                    ShopifyCompany.Insert();

                    if Shop."Auto Create Catalog" then
                        CatalogAPI.CreateCatalog(ShopifyCompany, Customer);

                    CompanyLocation.Default := true;
                    CompanyLocation."Company SystemId" := ShopifyCompany.SystemId;
                    CompanyLocation.Insert();
                end;
    end;

    local procedure CreateCompanyMainContact(Customer: Record Customer; var ShopifyCustomer: Record "Shpfy Customer"): Boolean
    var
        CustomerExport: Codeunit "Shpfy Customer Export";
    begin
        CustomerExport.SetCreateCustomers(true);
        CustomerExport.SetShop(Shop);
        Customer.SetRange("No.", Customer."No.");
        CustomerExport.Run(Customer);

        ShopifyCustomer.SetRange("Shop Id", Shop."Shop Id");
        ShopifyCustomer.SetRange("Customer SystemId", Customer.SystemId);
        exit(ShopifyCustomer.FindFirst());
    end;

    internal procedure FillInShopifyCompany(Customer: Record Customer; var ShopifyCompany: Record "Shpfy Company"): Boolean
    var
        TempShopifyCompany: Record "Shpfy Company" temporary;
    begin
        TempShopifyCompany := ShopifyCompany;

        ShopifyCompany.Name := Customer.Name;
        ShopifyCompany."External Id" := Customer."No.";

        if HasDiff(ShopifyCompany, TempShopifyCompany) then begin
            ShopifyCompany."Last Updated by BC" := CurrentDateTime;
            exit(true);
        end;
    end;

    internal procedure FillInShopifyCompanyLocation(Customer: Record Customer; var CompanyLocation: Record "Shpfy Company Location"): Boolean
    var
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
        TaxArea: Record "Shpfy Tax Area";
        TempCompanyLocation: Record "Shpfy Company Location" temporary;
        TaxRegistrationIdMapping: Interface "Shpfy Tax Registration Id Mapping";
        CountyCodeTooLongErr: Text;
        PaymentTermsId: BigInteger;
    begin
        TempCompanyLocation := CompanyLocation;

        CompanyLocation.Name := Customer.Address;
        CompanyLocation.Address := Customer.Address;
        CompanyLocation."Address 2" := Customer."Address 2";
        CompanyLocation.Zip := Customer."Post Code";
        CompanyLocation.City := Customer.City;
        CompanyLocation.Recipient := Customer.Name;

        if Customer.County <> '' then begin
            TaxArea.SetRange("Country/Region Code", Customer."Country/Region Code");
            if not TaxArea.IsEmpty() then
                case Shop."County Source" of
                    Shop."County Source"::Code:
                        begin
                            if StrLen(Customer.County) > MaxStrLen(TaxArea."County Code") then begin
                                CountyCodeTooLongErr := StrSubstNo(CountyCodeTooLongLbl, Customer."No.", Customer.Name, StrLen(Customer.County), MaxStrLen(TaxArea."County Code"), Customer.County, Customer.FieldCaption(County));
                                Error(CountyCodeTooLongErr);
                            end;
                            TaxArea.SetRange("Country/Region Code", Customer."Country/Region Code");
                            TaxArea.SetRange("County Code", Customer.County);
                            if TaxArea.FindFirst() then begin
                                CompanyLocation."Province Code" := TaxArea."County Code";
                                CompanyLocation."Province Name" := TaxArea.County;
                            end;
                        end;
                    Shop."County Source"::Name:
                        begin
                            TaxArea.SetRange("Country/Region Code", Customer."Country/Region Code");
                            TaxArea.SetRange(County, Customer.County);
                            if TaxArea.FindFirst() then begin
                                CompanyLocation."Province Code" := TaxArea."County Code";
                                CompanyLocation."Province Name" := TaxArea.County;
                            end else begin
                                TaxArea.SetFilter(County, Customer.County + '*');
                                if TaxArea.FindFirst() then begin
                                    CompanyLocation."Province Code" := TaxArea."County Code";
                                    CompanyLocation."Province Name" := TaxArea.County;
                                end;
                            end;
                        end;
                end;
        end;

        if (Customer."Country/Region Code" = '') and CompanyInformation.Get() then
            Customer."Country/Region Code" := CompanyInformation."Country/Region Code";

        if CountryRegion.Get(Customer."Country/Region Code") then begin
            CountryRegion.TestField("ISO Code");
            CompanyLocation."Country/Region Code" := CountryRegion."ISO Code";
        end;

        CompanyLocation."Phone No." := Customer."Phone No.";

        TaxRegistrationIdMapping := Shop."Shpfy Comp. Tax Id Mapping";
        CompanyLocation."Tax Registration Id" := TaxRegistrationIdMapping.GetTaxRegistrationId(Customer);

        if GetShopifyPaymentTermsIdFromCustomer(Customer, PaymentTermsId) then
            CompanyLocation."Shpfy Payment Terms Id" := PaymentTermsId;

        exit(HasDiff(CompanyLocation, TempCompanyLocation));
    end;

    local procedure HasDiff(RecAsVariant: Variant; xRecAsVariant: Variant): Boolean
    var
        RecordRef: RecordRef;
        xRecordRef: RecordRef;
        Index: Integer;
    begin
        RecordRef.GetTable(RecAsVariant);
        xRecordRef.GetTable(xRecAsVariant);
        if RecordRef.Number = xRecordRef.Number then
            for Index := 1 to RecordRef.FieldCount do
                if RecordRef.FieldIndex(Index).Value <> xRecordRef.FieldIndex(Index).Value then
                    exit(true);
    end;

    internal procedure SetShop(Code: Code[20])
    begin
        Clear(Shop);
        Shop.Get(Code);
        SetShop(Shop);
    end;

    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CompanyAPI.SetShop(Shop);
        CatalogAPI.SetShop(Shop);
        MetafieldAPI.SetShop(Shop);
    end;

    local procedure UpdateShopifyCompany(Customer: Record Customer; CompanyId: BigInteger)
    var
        CurrCustomer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
    begin
        ShopifyCompany.Get(CompanyId);
        if ShopifyCompany."Customer SystemId" <> Customer.SystemId then begin
            SkippedRecord.LogSkippedRecord(ShopifyCompany.Id, Customer.RecordId, CompanyWithPhoneNoOrEmailExistsLbl, Shop);
            exit;
        end;

        if FillInShopifyCompany(Customer, ShopifyCompany) then begin
            CompanyAPI.UpdateCompany(ShopifyCompany);
            ShopifyCompany.Modify();
        end;

        CompanyLocation.SetRange("Company SystemId", ShopifyCompany.SystemId);
        CompanyLocation.FindSet();
        repeat
            if IsNullGuid(CompanyLocation."Customer Id") then
                CurrCustomer := Customer
            else
                CurrCustomer.GetBySystemId(CompanyLocation."Customer Id");

            if FillInShopifyCompanyLocation(CurrCustomer, CompanyLocation) then begin
                CompanyAPI.UpdateCompanyLocation(CompanyLocation);
                CompanyLocation.Modify();
            end;
        until CompanyLocation.Next() = 0;

        if Shop."Company Metafields To Shopify" then
            UpdateMetafields(ShopifyCompany.Id);
    end;

    local procedure UpdateMetafields(ComppanyId: BigInteger)
    begin
        MetafieldAPI.CreateOrUpdateMetafieldsInShopify(Database::"Shpfy Company", ComppanyId);
    end;

    internal procedure SetCreateCompanies(NewCustomers: Boolean)
    begin
        CreateCustomers := NewCustomers;
    end;

    local procedure GetShopifyPaymentTermsIdFromCustomer(Customer: Record Customer; var PaymentTermsId: BigInteger): Boolean
    var
        ShopifyPaymentTerms: Record "Shpfy Payment Terms";
    begin
        ShopifyPaymentTerms.SetRange("Shop Code", Shop.Code);
        ShopifyPaymentTerms.SetRange("Payment Terms Code", Customer."Payment Terms Code");
        if ShopifyPaymentTerms.FindFirst() then begin
            PaymentTermsId := ShopifyPaymentTerms.Id;
            exit(true);
        end;
    end;
}