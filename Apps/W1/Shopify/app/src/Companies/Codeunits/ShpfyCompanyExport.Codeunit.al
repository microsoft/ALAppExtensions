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
        CreateCustomers: Boolean;
        CountyCodeTooLongLbl: Label 'Can not export customer %1 %2. The length of the string is %3, but it must be less than or equal to %4 characters. Value: %5, field: %6', Comment = '%1 - Customer No., %2 - Customer Name, %3 - Length, %4 - Max Length, %5 - Value, %6 - Field Name';

    local procedure CreateShopifyCompany(Customer: Record Customer)
    var
        ShopifyCompany: Record "Shpfy Company";
        ShopifyCustomer: Record "Shpfy Customer";
        CompanyLocation: Record "Shpfy Company Location";
    begin
        if Customer."E-Mail" = '' then
            exit;

        if CreateCompanyMainContact(Customer, ShopifyCustomer) then
            if FillInShopifyCompany(Customer, ShopifyCompany, CompanyLocation) then
                if CompanyAPI.CreateCompany(ShopifyCompany, CompanyLocation, ShopifyCustomer) then begin
                    ShopifyCompany."Main Contact Customer Id" := ShopifyCustomer.Id;
                    ShopifyCompany."Customer SystemId" := Customer.SystemId;
                    ShopifyCompany."Last Updated by BC" := CurrentDateTime();
                    ShopifyCompany."Shop Id" := Shop."Shop Id";
                    ShopifyCompany."Shop Code" := Shop.Code;
                    ShopifyCompany.Insert();

                    if Shop."Auto Create Catalog" then
                        CatalogAPI.CreateCatalog(ShopifyCompany);

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

    internal procedure FillInShopifyCompany(Customer: Record Customer; var ShopifyCompany: Record "Shpfy Company"; var CompanyLocation: Record "Shpfy Company Location"): Boolean
    var
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
        TaxArea: Record "Shpfy Tax Area";
        TempShopifyCompany: Record "Shpfy Company" temporary;
        TempCompanyLocation: Record "Shpfy Company Location" temporary;
        CountyCodeTooLongErr: Text;
    begin
        TempShopifyCompany := ShopifyCompany;
        TempCompanyLocation := CompanyLocation;

        ShopifyCompany.Name := Customer.Name;

        CompanyLocation.Name := Customer.Address;
        CompanyLocation.Address := Customer.Address;
        CompanyLocation."Address 2" := Customer."Address 2";
        CompanyLocation.Zip := Customer."Post Code";
        CompanyLocation.City := Customer.City;

        if Customer.County <> '' then
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

        if (Customer."Country/Region Code" = '') and CompanyInformation.Get() then
            Customer."Country/Region Code" := CompanyInformation."Country/Region Code";

        if CountryRegion.Get(Customer."Country/Region Code") then begin
            CountryRegion.TestField("ISO Code");
            CompanyLocation."Country/Region Code" := CountryRegion."ISO Code";
        end;

        CompanyLocation."Phone No." := Customer."Phone No.";

        if HasDiff(ShopifyCompany, TempShopifyCompany) or HasDiff(CompanyLocation, TempCompanyLocation) then begin
            ShopifyCompany."Last Updated by BC" := CurrentDateTime;
            exit(true);
        end;
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
    end;

    local procedure UpdateShopifyCompany(Customer: Record Customer; CompanyId: BigInteger)
    var
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
    begin
        ShopifyCompany.Get(CompanyId);
        if ShopifyCompany."Customer SystemId" <> Customer.SystemId then
            exit;

        CompanyLocation.SetRange("Company SystemId", ShopifyCompany.SystemId);
        CompanyLocation.FindFirst();

        if FillInShopifyCompany(Customer, ShopifyCompany, CompanyLocation) then begin
            CompanyAPI.UpdateCompany(ShopifyCompany, CompanyLocation);
            ShopifyCompany.Modify();
            CompanyLocation.Modify();
        end;
    end;

    internal procedure SetCreateCompanies(NewCustomers: Boolean)
    begin
        CreateCustomers := NewCustomers;
    end;
}