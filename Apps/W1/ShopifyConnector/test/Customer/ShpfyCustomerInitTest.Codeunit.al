/// <summary>
/// Codeunit Shpfy Customer Init Test (ID 30510).
/// </summary>
codeunit 30510 "Shpfy Customer Init Test"
{
    SingleInstance = true;

    var

        Any: codeunit Any;
        Assert: Codeunit "Library Assert";

    internal procedure CreateShopifyCustomerAddress() ShpfyCustomerAddress: Record "Shpfy Customer Address"
    var
        ShpfyCustomer: Record "Shpfy Customer";
    begin
        CreateShopifyCustomer(ShpfyCustomer);
        exit(CreateShopifyCustomerAddress(ShpfyCustomer));
    end;

    internal procedure CreateShopifyCustomerAddress(ShpfyCustomer: Record "Shpfy Customer") ShpfyCustomerAddress: Record "Shpfy Customer Address"
    begin
        ShpfyCustomerAddress.DeleteAll();
        ShpfyCustomerAddress.Init();
        ShpfyCustomerAddress.Id := Any.IntegerInRange(1, 99999);
        ShpfyCustomerAddress."Customer Id" := ShpfyCustomer.Id;
        ShpfyCustomerAddress.Company := 'Company';
        ShpfyCustomerAddress."First Name" := 'Firstname';
        ShpfyCustomerAddress."Last Name" := 'Lastname';
        ShpfyCustomerAddress."Address 1" := 'Address';
        ShpfyCustomerAddress."Address 2" := 'Address 2';
        ShpfyCustomerAddress.Phone := '111';
        ShpfyCustomerAddress.Zip := '1111';
        ShpfyCustomerAddress.City := 'City';
        ShpfyCustomerAddress."Country/Region Code" := 'US';
        ShpfyCustomerAddress.Insert();
    end;

    internal procedure CreateShopifyCustomer(var ShpfyCustomer: Record "Shpfy Customer"): BigInteger
    var
        CustomerId: BigInteger;
    begin
        ShpfyCustomer.DeleteAll();
        CustomerId := Any.IntegerInRange(1000, 99999);
        ShpfyCustomer.Init();
        ShpfyCustomer.Id := CustomerId;
        ShpfyCustomer."First Name" := 'Firstname';
        ShpfyCustomer."Last Name" := 'Lastname';
        ShpfyCustomer.Email := 'mail@domain.com';
        ShpfyCustomer."Phone No." := '111';
        ShpfyCustomer.Insert();
        exit(CustomerId);
    end;


    internal procedure CreateJsonCustomerInfo(NameSource: Enum "Shpfy Name Source"; Name2Source: Enum "Shpfy Name Source"): JsonObject
    var
        Name: Text;
        Name2: Text;
        JCustomerInfo: JsonObject;
    begin
        case NameSource of
            "Shpfy Name Source"::CompanyName:
                Name := 'Company';
            "Shpfy Name Source"::FirstAndLastName:
                Name := 'Firstname Lastname';
            "Shpfy Name Source"::LastAndFirstName:
                Name := 'Lastname Firstname';
            "Shpfy Name Source"::None:
                Name := '';
        end;
        case Name2Source of
            "Shpfy Name Source"::CompanyName:
                Name2 := 'Company';
            "Shpfy Name Source"::FirstAndLastName:
                Name2 := 'Firstname Lastname';
            "Shpfy Name Source"::LastAndFirstname:
                Name2 := 'Lastname Firstname';
            "Shpfy Name Source"::None:
                Name2 := '';
        end;
        if Name = '' then begin
            Name := Name2;
            Name2 := '';
        end;
        JCustomerInfo.Add('Name', Name);
        JCustomerInfo.Add('Name2', Name2);
        JCustomerInfo.Add('Address', 'Address');
        JCustomerInfo.Add('Address2', 'Address 2');
        JCustomerInfo.Add('PostCode', '1111');
        JCustomerInfo.Add('City', 'City');
        JCustomerInfo.Add('County', '');
        JCustomerInfo.Add('CountryCode', 'US');
        exit(JCustomerInfo);
    end;

    internal procedure ModifyFields(Rec: variant): Variant
    var
        RecRef: RecordRef;
        FRef: FieldRef;
        Index: Integer;
    begin
        RecRef.GetTable(Rec);
        for Index := 1 to RecRef.FieldCount do begin
            FRef := RecRef.FieldIndex(Index);
            if FRef.Class = FRef.Class::Normal then
                if FRef.Type = FRef.Type::Text then
                    if Format(FRef.Value) <> '' then
                        FRef.Value := CopyStr('!' + Format(FRef.Value), 1, FRef.Length);
        end;
        RecRef.SetTable(Rec);
        exit(Rec);
    end;

    internal procedure CreateCustomerGraphQLResult(): Text
    begin
        exit('{"query":"mutation {customerCreate(input: {email: \"mail@domain.com\", firstName: \"Firstname\", lastName: \"Lastname\", phone: \"111\", addresses: {company: \"Company\", firstName: \"Firstname\", lastName: \"Lastname\", phone: \"111\", address1: \"Address\", address2: \"Address 2\", zip: \"1111\", city: \"City\", countryCode: US}}) {customer {id, addresses {id, country, province}}, userErrors {field, message}}}"}');
    end;

    internal procedure CreateGraphQueryUpdateCustomerResult(ShopifyCustomerId: BigInteger; ShopifyCustomerAddressId: BigInteger): Text
    var
#pragma warning disable AL0435
        GraphQLTxt: Label '{"query":"mutation {customerUpdate(input: {id: \"%1\", email: \"!mail@domain.com\", firstName: \"!Firstname\", lastName: \"!Lastname\", phone: \"!111\", addresses: {id: \"%2\", company: \"!Company\", firstName: \"!Firstname\", lastName: \"!Lastname\", address1: \"!Address\", address2: \"!Address 2\", zip: \"1111\", city: \"!City\", countryCode: US, phone: \"!111\"}}) {customer {id, acceptsMarketing, acceptsMarketingUpdatedAt, tags, updatedAt, veriefiedEmail, defaultAddress {id, province, country}}, userErrors {field, message}}}"}', Comment = '%1 = CustomerId, %2 = CustomerAddressId', Locked = true;
#pragma warning restore AL0435
    begin
        exit(StrSubstNo(GraphQLTxt, ShopifyCustomerId, ShopifyCustomerAddressId));
    end;

    internal procedure DummyJsonCustomerObjectFromShopify(ShopifyCustomerId: BigInteger; ShopifyCustomerAddressId: BigInteger): JsonObject
    var
        JCustomer: JsonObject;
#pragma warning disable AL0435
        JCustomerTxt: Label '{"legacyResourceId":"%1","firstName":"First Name","lastName":"Last Name","email":"Email","phone":"Phone No.","acceptsMarketing":false,"acceptsMarketingUpdatedAt":"2022-04-01T00:00:00Z","taxExempt":false,"taxExemptions":[],"verifiedEmail":true,"state":"DISABLED","hasNote":false,"note":null,"createdAt":"2022-04-01T00:00:00Z","updatedAt":"%3T00:00:00Z","tags":[],"addresses":[{"id":"gid:\/\/shopify\/MailingAddress\/%2?model_name=CustomerAddress","company":"Company","firstName":"First Name","lastName":"Last Name","address1":"Address 1","address2":"Address 2","zip":"ZIP","city":"City","countryCodeV2":"US","country":"Country/Region Name","provinceCode":"Province Code","province":"Province Name","phone":"Phone No."}],"defaultAddress":{"id":"gid:\/\/shopify\/MailingAddress\/7065543475272?model_name=CustomerAddress"},"metafields":{"edges":[]}}', Comment = '%1 = CustomerId, %2 = CustomerAddressId, %3 = Date of Update as YYYY-MM-DD', Locked = true;
#pragma warning restore AL0435
    begin
        JCustomer.ReadFrom(StrSubstNo(JCustomerTxt, ShopifyCustomerId, ShopifyCustomerAddressId, Format(Today, 0, 9)));
        exit(JCustomer);
    end;

    internal procedure TextFieldsContainsFieldName(Rec: variant): boolean
    var
        RecRef: RecordRef;
        FRef: FieldRef;
        Index: Integer;
        RecFieldTxt: Label '"%1"."%2"', Locked = true;
    begin
        RecRef.GetTable(Rec);
        for Index := 1 to RecRef.FieldCount do begin
            FRef := RecRef.FieldIndex(Index);
            if FRef.Class = FRef.Class::Normal then
                if FRef.Type = FRef.Type::Text then
                    case FRef.Name of
                        'Phone No.', 'Phone':  // Because invalid phone charters will be deleted.
                            Assert.AreEqual(' .', Format(FRef.Value), StrSubstNo(RecFieldTxt, RecRef.Name, FRef.Name));
                        else
                            Assert.AreEqual(FRef.Name, Format(FRef.Value), StrSubstNo(RecFieldTxt, RecRef.Name, FRef.Name));
                    end;
        end;
        exit(true);
    end;
}
