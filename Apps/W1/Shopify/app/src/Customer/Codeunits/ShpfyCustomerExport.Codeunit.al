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
        Customer.CopyFilters(Rec);
        if Shop."Export Customer To Shopify" and Customer.FindSet(false, false) then begin
            CustomerMapping.SetShop(Shop);
            repeat
                CustomerId := CustomerMapping.FindMapping(Customer);
                if CustomerId = 0 then
                    CreateShopifyCustomer(Customer)
                else
                    if Shop."Can Update Shopify Customer" then
                        UpdateShopifyCustomer(Customer, CustomerId);
                Commit();
            until Customer.Next() = 0;
        end;
    end;

    var
        Shop: Record "Shpfy Shop";
        CustomerApi: Codeunit "Shpfy Customer API";

    /// <summary> 
    /// Add Or Update Metadata.
    /// </summary>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="MetadataField">Parameter of type FieldRef.</param>
    internal procedure AddOrUpdateMetadata(ShopifyCustomer: Record "Shpfy Customer"; MetadataField: FieldRef)
    var
        Metafield: Record "Shpfy Metafield";
        Name: Text;
    begin
        Metafield.SetRange("Parent Table No.", Database::"Shpfy Customer");
        Metafield.SetRange("Owner Id", ShopifyCustomer.Id);
        Metafield.SetRange(Namespace, 'Microsoft.Dynamics365.BusinessCentral');
        Name := CleanName(MetadataField);
        Metafield.SetRange(Name, Name);
        if Metafield.FindFirst() then begin
            if Metafield.Value <> Format(MetadataField.Value) then;
        end else begin
            Clear(Metafield);
            Metafield.Namespace := 'Microsoft.Dynamics365.BusinessCentral';
            Metafield.Validate("Parent Table No.", Database::"Shpfy Customer");
            Metafield."Owner Id" := ShopifyCustomer.Id;
            Metafield."Value Type" := Metafield."Value Type"::String;
            Metafield.Value := Format(MetadataField.Value);
        end;
    end;

    /// <summary> 
    /// Clean Name.
    /// </summary>
    /// <param name="Field">Parameter of type FieldRef.</param>
    /// <returns>Return value of type Text.</returns>
    local procedure CleanName(Field: FieldRef): Text
    begin
        exit(DelChr(Field.Record().Name, '=', ' %.-+') + '.' + DelChr(Field.Name, '=', ' %-+'));
    end;

    /// <summary> 
    /// Create Shopify Customer.
    /// </summary>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    local procedure CreateShopifyCustomer(Customer: Record Customer)
    var
        ShopifyCustomer: Record "Shpfy Customer";
        ShopifyAddress: Record "Shpfy Customer Address";
    begin
        if Customer."E-Mail" = '' then
            exit;

        Clear(ShopifyCustomer);
        Clear(ShopifyAddress);
        if FillInShopifyCustomerData(Customer, ShopifyCustomer, ShopifyAddress) then begin
            if CustomerApi.CreateCustomer(ShopifyCustomer, ShopifyAddress) then begin
                ShopifyCustomer."Customer SystemId" := Customer.SystemId;
                ShopifyCustomer."Last Updated by BC" := CurrentDateTime;
                ShopifyCustomer.Insert();
                ShopifyAddress.Insert();
            end;
            MetadataFields(Customer, ShopifyCustomer);
        end;
    end;

    /// <summary> 
    /// Fill In Shopify Customer Data.
    /// </summary>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="ShopAddress">Parameter of type Record "Shopify Customer Address".</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure FillInShopifyCustomerData(Customer: Record Customer; var ShopifyCustomer: Record "Shpfy Customer"; var ShopAddress: Record "Shpfy Customer Address"): Boolean
    var
        CompanyInfo: Record "Company Information";
        Country: Record "Country/Region";
#pragma warning disable AA0073
        xShopifyCustomer: Record "Shpfy Customer" temporary;
        xShopAddress: Record "Shpfy Customer Address" temporary;
#pragma warning restore AA0073
        Province: Record "Shpfy Province";
    begin
        xShopifyCustomer := ShopifyCustomer;
        xShopAddress := ShopAddress;

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
            ShopAddress.Company := Customer.Name
        else
            if Shop."Name 2 Source" = Shop."Name 2 Source"::CompanyName then
                ShopAddress.Company := Customer."Name 2";
        ShopAddress."First Name" := CopyStr(ShopifyCustomer."First Name", 1, MaxStrLen(ShopAddress."First Name"));
        ShopAddress."Last Name" := CopyStr(ShopifyCustomer."Last Name", 1, MaxStrLen(ShopAddress."Last Name"));
        ShopAddress."Address 1" := Customer.Address;
        ShopAddress."Address 2" := Customer."Address 2";
        ShopAddress.Zip := Customer."Post Code";
        ShopAddress.City := Customer.City;
        if Customer.County <> '' then
            case Shop."County Source" of
                Shop."County Source"::Code:
                    ShopAddress."Province Code" := CopyStr(Customer.County, 1, MaxStrLen(ShopAddress."Province Code"));
                Shop."County Source"::Name:
                    begin
                        Province.SetRange(Name, Customer.County);
                        if Province.FindFirst() then
                            ShopAddress."Province Code" := CopyStr(Province.Code, 1, MaxStrLen(ShopAddress."Province Code"))
                        else begin
                            Province.SetFilter(Name, Customer.County + '*');
                            if Province.FindFirst() then
                                ShopAddress."Province Code" := CopyStr(Province.Code, 1, MaxStrLen(ShopAddress."Province Code"));
                        end;
                    end;
            end;
        if (Customer."Country/Region Code" = '') and CompanyInfo.Get() then
            Customer."Country/Region Code" := CompanyInfo."Country/Region Code";

        if Country.Get(Customer."Country/Region Code") then
            ShopAddress."Country/Region Code" := Country."ISO Code";

        ShopAddress.Phone := Customer."Phone No.";

        if HasDiff(ShopifyCustomer, xShopifyCustomer) or HasDiff(ShopAddress, xShopAddress) then begin
            ShopifyCustomer."Last Updated by BC" := CurrentDateTime;
            exit(true);
        end;
    end;

    /// <summary> 
    /// Has Diff.
    /// </summary>
    /// <param name="Rec">Parameter of type Variant.</param>
    /// <param name="xRec">Parameter of type Variant.</param>
    /// <returns>Return value of type Boolean.</returns>
    local procedure HasDiff(Rec: Variant; xRec: Variant): Boolean
    var
        RecRef: RecordRef;
        xRecRef: RecordRef;
        Index: Integer;
    begin
        RecRef.GetTable(Rec);
        xRecRef.GetTable(xRec);
        if RecRef.Number = xRecRef.Number then
            for Index := 1 to RecRef.FieldCount do
                if RecRef.FieldIndex(Index).Value <> xRecRef.FieldIndex(Index).Value then
                    exit(true);
    end;

    /// <summary> 
    /// Metadata Fields.
    /// </summary>
    /// <param name="Customer">Parameter of type Record Customer.</param>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    local procedure MetadataFields(Customer: Record Customer; ShopifyCustomer: Record "Shpfy Customer")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Customer);
        AddOrUpdateMetadata(ShopifyCustomer, RecRef.Field(Customer.FieldNo("No.")));
        AddOrUpdateMetadata(ShopifyCustomer, RecRef.Field(Customer.FieldNo("VAT Bus. Posting Group")));
        AddOrUpdateMetadata(ShopifyCustomer, RecRef.Field(Customer.FieldNo("VAT Registration No.")));
        AddOrUpdateMetadata(ShopifyCustomer, RecRef.Field(Customer.FieldNo(SystemId)));
        AddOrUpdateMetadata(ShopifyCustomer, RecRef.Field(Customer.FieldNo("Customer Disc. Group")));
        AddOrUpdateMetadata(ShopifyCustomer, RecRef.Field(Customer.FieldNo("Customer Price Group")));
        AddOrUpdateMetadata(ShopifyCustomer, RecRef.Field(Customer.FieldNo("Customer Posting Group")));
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
        ShopifyAddress: Record "Shpfy Customer Address";
    begin
        ShopifyCustomer.Get(CustomerID);
        if ShopifyCustomer."Customer SystemId" <> Customer.SystemId then
            exit;  // An other customer with the same e-mail or phone is the source of it.

        ShopifyAddress.SetRange("Customer Id", CustomerId);
        ShopifyAddress.SetRange(Default, true);
        if not ShopifyAddress.FindFirst() then begin
            ShopifyAddress.SetRange(Default);
            ShopifyAddress.FindFirst();
        end;

        if FillInShopifyCustomerData(Customer, ShopifyCustomer, ShopifyAddress) then begin
            CustomerApi.UpdateCustomer(ShopifyCustomer, ShopifyAddress);
            ShopifyCustomer.Modify();
            ShopifyAddress.Modify();
        end;
    end;
}