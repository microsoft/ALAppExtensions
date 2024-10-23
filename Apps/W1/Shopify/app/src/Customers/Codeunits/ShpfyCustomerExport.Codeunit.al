namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Address;

/// <summary>
/// Codeunit Shpfy Customer Export (ID 30116).
/// </summary>
codeunit 30116 "Shpfy Customer Export"
{
    Access = Internal;
    TableNo = Customer;

    trigger OnRun()
    var
        Customer: Record Customer;
        CustomerMapping: Codeunit "Shpfy Customer Mapping";
        CustomerId: BigInteger;
    begin
        CustomerAPI.FillInMissingShopIds();
        Customer.CopyFilters(Rec);
        if Customer.FindSet(false) then begin
            CustomerMapping.SetShop(Shop);
            repeat
                CustomerId := CustomerMapping.FindMapping(Customer, CreateCustomers);
                if CustomerId = 0 then begin
                    if CreateCustomers then
                        CreateShopifyCustomer(Customer);
                end else
                    if Shop."Can Update Shopify Customer" then
                        UpdateShopifyCustomer(Customer, CustomerId);

                Commit();
            until Customer.Next() = 0;
        end;
    end;

    var
        Shop: Record "Shpfy Shop";
        CustomerApi: Codeunit "Shpfy Customer API";
        CreateCustomers: Boolean;
        CountyCodeTooLongLbl: Label 'Can not export customer %1 %2. The length of the string is %3, but it must be less than or equal to %4 characters. Value: %5, field: %6', Comment = '%1 - Customer No., %2 - Customer Name, %3 - Length, %4 - Max Length, %5 - Value, %6 - Field Name';

    /// <summary> 
    /// Add Or Update Metadata.
    /// </summary>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="MetadataFieldRef">Parameter of type FieldRef.</param>
    internal procedure AddOrUpdateMetadata(ShopifyCustomer: Record "Shpfy Customer"; MetadataFieldRef: FieldRef)
    var
        Metafield: Record "Shpfy Metafield";
        Name: Text;
    begin
        Metafield.SetRange("Parent Table No.", Database::"Shpfy Customer");
        Metafield.SetRange("Owner Id", ShopifyCustomer.Id);
        Metafield.SetRange(Namespace, 'Microsoft.Dynamics365.BusinessCentral');
        Name := CleanName(MetadataFieldRef);
        Metafield.SetRange(Name, Name);
        if Metafield.FindFirst() then begin
            if Metafield.Value <> Format(MetadataFieldRef.Value) then;
        end else begin
            Clear(Metafield);
            Metafield.Namespace := 'Microsoft.Dynamics365.BusinessCentral';
            Metafield.Validate("Parent Table No.", Database::"Shpfy Customer");
            Metafield."Owner Id" := ShopifyCustomer.Id;
            Metafield.Type := Metafield.Type::single_line_text_field;
            Metafield.Value := Format(MetadataFieldRef.Value);
        end;
    end;

    /// <summary> 
    /// Clean Name.
    /// </summary>
    /// <param name="FieldRef">Parameter of type FieldRef.</param>
    /// <returns>Return value of type Text.</returns>
    local procedure CleanName(FieldRef: FieldRef): Text
    begin
        exit(DelChr(FieldRef.Record().Name, '=', ' %.-+') + '.' + DelChr(FieldRef.Name, '=', ' %-+'));
    end;

    /// <summary> 
    /// Create Shopify Customer.
    /// </summary>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    local procedure CreateShopifyCustomer(Customer: Record Customer)
    var
        ShopifyCustomer: Record "Shpfy Customer";
        CustomerAddress: Record "Shpfy Customer Address";
    begin
        if Customer."E-Mail" = '' then
            exit;

        Clear(ShopifyCustomer);
        Clear(CustomerAddress);
        if FillInShopifyCustomerData(Customer, ShopifyCustomer, CustomerAddress) then
            if CustomerApi.CreateCustomer(ShopifyCustomer, CustomerAddress) then begin
                ShopifyCustomer."Customer SystemId" := Customer.SystemId;
                ShopifyCustomer."Last Updated by BC" := CurrentDateTime;
                ShopifyCustomer."Shop Id" := Shop."Shop Id";
                ShopifyCustomer.Insert();
                CustomerAddress.Insert();
            end;
        MetadataFields(Customer, ShopifyCustomer);
    end;

    /// <summary> 
    /// Fill In Shopify Customer Data.
    /// </summary>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="CustomerAddress">Parameter of type Record "Shopify Customer Address".</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure FillInShopifyCustomerData(Customer: Record Customer; var ShopifyCustomer: Record "Shpfy Customer"; var CustomerAddress: Record "Shpfy Customer Address"): Boolean
    var
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
#pragma warning disable AA0073
        xShopifyCustomer: Record "Shpfy Customer" temporary;
        xCustomerAddress: Record "Shpfy Customer Address" temporary;
#pragma warning restore AA0073
        TaxArea: Record "Shpfy Tax Area";
        CountyCodeTooLongErr: Text;
    begin
        xShopifyCustomer := ShopifyCustomer;
        xCustomerAddress := CustomerAddress;

        if (Customer.Contact <> '') and (Shop."Contact Source" <> Shop."Contact Source"::None) then
            SpiltNameIntoFirstAndLastName(Customer.Contact, ShopifyCustomer."First Name", ShopifyCustomer."Last Name", Shop."Contact Source")
        else
            if (Customer."Name 2" <> '') and (Shop."Name 2 Source" in [Shop."Name 2 Source"::FirstAndLastName, Shop."Name 2 Source"::LastAndFirstName]) then
                SpiltNameIntoFirstAndLastName(Customer."Name 2", ShopifyCustomer."First Name", ShopifyCustomer."Last Name", Shop."Name 2 Source")
            else
                SpiltNameIntoFirstAndLastName(Customer.Name, ShopifyCustomer."First Name", ShopifyCustomer."Last Name", Shop."Name Source");

#pragma warning disable AA0139
        if Customer."E-Mail".Contains(';') then
            Customer."E-Mail".Split(';').Get(1, ShopifyCustomer.Email)
        else
            if Customer."E-Mail".Contains(',') then
                Customer."E-Mail".Split(',').Get(1, ShopifyCustomer.Email)
            else
                ShopifyCustomer.Email := Customer."E-Mail";
#pragma warning restore AA0139
        ShopifyCustomer."Phone No." := Customer."Phone No.";

        if Shop."Name Source" = Shop."Name Source"::CompanyName then
            CustomerAddress.Company := Customer.Name
        else
            if Shop."Name 2 Source" = Shop."Name 2 Source"::CompanyName then
                CustomerAddress.Company := Customer."Name 2";
        CustomerAddress."First Name" := CopyStr(ShopifyCustomer."First Name", 1, MaxStrLen(CustomerAddress."First Name"));
        CustomerAddress."Last Name" := CopyStr(ShopifyCustomer."Last Name", 1, MaxStrLen(CustomerAddress."Last Name"));
        CustomerAddress."Address 1" := Customer.Address;
        CustomerAddress."Address 2" := Customer."Address 2";
        CustomerAddress.Zip := Customer."Post Code";
        CustomerAddress.City := Customer.City;

        if (Customer."Country/Region Code" = '') and CompanyInformation.Get() then
            Customer."Country/Region Code" := CompanyInformation."Country/Region Code";

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
                            CustomerAddress."Province Code" := TaxArea."County Code";
                            CustomerAddress."Province Name" := TaxArea.County;
                        end;
                    end;
                Shop."County Source"::Name:
                    begin
                        TaxArea.SetRange("Country/Region Code", Customer."Country/Region Code");
                        TaxArea.SetRange(County, Customer.County);
                        if TaxArea.FindFirst() then begin
                            CustomerAddress."Province Code" := TaxArea."County Code";
                            CustomerAddress."Province Name" := TaxArea.County;
                        end else begin
                            TaxArea.SetFilter(County, Customer.County + '*');
                            if TaxArea.FindFirst() then begin
                                CustomerAddress."Province Code" := TaxArea."County Code";
                                CustomerAddress."Province Name" := TaxArea.County;
                            end;
                        end;
                    end;
            end;

        if CountryRegion.Get(Customer."Country/Region Code") then begin
            CountryRegion.TestField("ISO Code");
            CustomerAddress."Country/Region Code" := CountryRegion."ISO Code";
        end;

        CustomerAddress.Phone := Customer."Phone No.";

        if HasDiff(ShopifyCustomer, xShopifyCustomer) or HasDiff(CustomerAddress, xCustomerAddress) then begin
            ShopifyCustomer."Last Updated by BC" := CurrentDateTime;
            exit(true);
        end;
    end;

    /// <summary> 
    /// Has Diff.
    /// </summary>
    /// <param name="RecAsVariant">Parameter of type Variant.</param>
    /// <param name="xRecAsVariant">Parameter of type Variant.</param>
    /// <returns>Return value of type Boolean.</returns>
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

    /// <summary> 
    /// Metadata Fields.
    /// </summary>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    local procedure MetadataFields(Customer: Record Customer; ShopifyCustomer: Record "Shpfy Customer")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Customer);
        AddOrUpdateMetadata(ShopifyCustomer, RecordRef.Field(Customer.FieldNo("No.")));
        AddOrUpdateMetadata(ShopifyCustomer, RecordRef.Field(Customer.FieldNo("VAT Bus. Posting Group")));
        AddOrUpdateMetadata(ShopifyCustomer, RecordRef.Field(Customer.FieldNo("VAT Registration No.")));
        AddOrUpdateMetadata(ShopifyCustomer, RecordRef.Field(Customer.FieldNo(SystemId)));
        AddOrUpdateMetadata(ShopifyCustomer, RecordRef.Field(Customer.FieldNo("Customer Disc. Group")));
        AddOrUpdateMetadata(ShopifyCustomer, RecordRef.Field(Customer.FieldNo("Customer Price Group")));
        AddOrUpdateMetadata(ShopifyCustomer, RecordRef.Field(Customer.FieldNo("Customer Posting Group")));
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    begin
        Clear(Shop);
        Shop.Get(Code);
        SetShop(Shop);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CustomerApi.SetShop(Shop);
    end;

    /// <summary> 
    /// Spilt Name Into First And Last Name.
    /// </summary>
    /// <param name="Name">Parameter of type Text.</param>
    /// <param name="FirstName">Parameter of type Text.</param>
    /// <param name="LastName">Parameter of type Text.</param>
    /// <param name="NameSource">Parameter of type enum "Shopify Name Source".</param>
    internal procedure SpiltNameIntoFirstAndLastName(Name: Text; var FirstName: Text[100]; var LastName: Text[100]; NameSource: enum "Shpfy Name Source")
    begin
        Name := Name.Trim();
        if Name <> '' then begin
            case Namesource of
                NameSource::FirstAndLastName:
                    FirstName := CopyStr(Name.Split(' ').Get(1), 1, MaxStrLen(FirstName));
                NameSource::LastAndFirstName:
                    FirstName := CopyStr(Name.Split(' ').Get(Name.Split(' ').Count), 1, MaxStrLen(FirstName));
                else
                    exit;
            end;
            LastName := CopyStr(Name.Remove(StrPos(Name, FirstName), StrLen(FirstName)).Trim(), 1, MaxStrLen(LastName));
        end;
    end;

    /// <summary> 
    /// Update Shopify Customer.
    /// </summary>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    /// <param name="CustomerId">Parameter of type BigInteger.</param>
    local procedure UpdateShopifyCustomer(Customer: Record Customer; CustomerId: BigInteger)
    var
        ShopifyCustomer: Record "Shpfy Customer";
        CustomerAddress: Record "Shpfy Customer Address";
    begin
        ShopifyCustomer.Get(CustomerID);
        if ShopifyCustomer."Customer SystemId" <> Customer.SystemId then
            exit;  // An other customer with the same e-mail or phone is the source of it.

        CustomerAddress.SetRange("Customer Id", CustomerId);
        CustomerAddress.SetRange(Default, true);
        if not CustomerAddress.FindFirst() then begin
            CustomerAddress.SetRange(Default);
            CustomerAddress.FindFirst();
        end;

        if FillInShopifyCustomerData(Customer, ShopifyCustomer, CustomerAddress) then begin
            CustomerApi.UpdateCustomer(ShopifyCustomer, CustomerAddress);
            ShopifyCustomer.Modify();
            CustomerAddress.Modify();
        end;
    end;

    internal procedure SetCreateCustomers(NewCustomers: Boolean)
    begin
        CreateCustomers := NewCustomers;
    end;
}