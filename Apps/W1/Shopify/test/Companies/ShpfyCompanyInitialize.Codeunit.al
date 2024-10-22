codeunit 139638 "Shpfy Company Initialize"
{
    SingleInstance = true;

    var

        Any: Codeunit Any;

    internal procedure CreateShopifyCompanyLocation() CompanyLocation: Record "Shpfy Company Location"
    var
        ShopifyCompany: Record "Shpfy Company";
    begin
        CreateShopifyCompany(ShopifyCompany);
        exit(CreateShopifyCompanyLocation(ShopifyCompany));
    end;

    internal procedure CreateShopifyCompanyLocation(ShopifyCompany: Record "Shpfy Company") CompanyLocation: Record "Shpfy Company Location"
    begin
        CompanyLocation.DeleteAll();
        CompanyLocation.Init();
        CompanyLocation.Id := Any.IntegerInRange(1, 99999);
        CompanyLocation."Company SystemId" := ShopifyCompany.SystemId;
        CompanyLocation.Name := 'Address';
        CompanyLocation.Address := 'Address';
        CompanyLocation."Address 2" := 'Address 2';
        CompanyLocation."Phone No." := '111';
        CompanyLocation.Zip := '1111';
        CompanyLocation.City := 'City';
        CompanyLocation."Country/Region Code" := 'US';
        CompanyLocation.Insert();
    end;

    internal procedure CreateShopifyCompany(var ShopifyCompany: Record "Shpfy Company"): BigInteger
    var
        CompanyId: BigInteger;
    begin
        ShopifyCompany.DeleteAll();
        CompanyId := Any.IntegerInRange(1000, 99999);
        ShopifyCompany.Init();
        ShopifyCompany.Id := CompanyId;
        ShopifyCompany.Name := 'Name';
        ShopifyCompany.Insert();
        exit(CompanyId);
    end;

    internal procedure ModifyFields(RecVariant: variant): Variant
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        Index: Integer;
    begin
        RecordRef.GetTable(RecVariant);
        for Index := 1 to RecordRef.FieldCount do begin
            FieldRef := RecordRef.FieldIndex(Index);
            if FieldRef.Class = FieldRef.Class::Normal then
                if FieldRef.Type = FieldRef.Type::Text then
                    if Format(FieldRef.Value) <> '' then
                        FieldRef.Value := CopyStr('!' + Format(FieldRef.Value), 1, FieldRef.Length);
        end;
        RecordRef.SetTable(RecVariant);
        exit(RecVariant);
    end;

    internal procedure CreateCompanyGraphQLResult(): Text
    begin
        exit('{"query":"mutation {companyCreate(input: {company: {name: \"Name\"}, companyLocation: {billingSameAsShipping: true,name: \"Address\", phone: \"111\", shippingAddress: {address1: \"Address\", address2: \"Address 2\", zip: \"1111\", city: \"City\", phone: \"111\", countryCode: US}}}) {company {id, name, locations(first: 1) {edges {node {id, name}}}, contactRoles(first:10) {edges {node {id,name}}}}, userErrors {field, message}}}"}');
    end;

    internal procedure CreateGraphQueryUpdateCompanyResult(CompanyId: BigInteger): Text
    var
        GraphQLTxt: Label '{"query":"mutation {companyUpdate(companyId: \"gid://shopify/Company/%1\", input: {name: \"!Name\"}) {company {id, updatedAt}, userErrors {field, message}}}"}', Comment = '%1 = CompanyId', Locked = true;
    begin
        exit(StrSubstNo(GraphQLTxt, CompanyId));
    end;

    internal procedure CreateGraphQueryUpdateCompanyLocationResult(CompanyLocationId: BigInteger): Text
    var
        GraphQLTxt: Label '{"query":"mutation {companyLocationAssignAddress(locationId: \"gid://shopify/CompanyLocation/%1\", addressTypes: [BILLING,SHIPPING] address: {address1: \"!Address\", address2: \"!Address 2\", city: \"!City\", phone: \"!111\"}) {addresses {id}, userErrors {field, message}}}"}', Comment = '%1 = CompanyLocationId', Locked = true;
    begin
        exit(StrSubstNo(GraphQLTxt, CompanyLocationId));
    end;

    internal procedure CompanyMainContactResponse(Id: BigInteger; FirstName: Text; LastName: Text; Email: Text; PhoneNo: Text): JsonObject
    var
        JResult: JsonObject;
        ResultLbl: Label '{"id":"gid://shopify/CompanyContact/40665318","customer":{"id":"gid://shopify/Customer/%1","firstName":"%2","lastName":"%3","email":"%4","phone":"%5"}}', Comment = '%1 = CustomerId, %2 = FirstName, %3 = LastName, %4 = Email, %5 = PhoneNo', Locked = true;
    begin
        JResult.ReadFrom(StrSubstNo(ResultLbl, Id, FirstName, LastName, Email, PhoneNo));
        exit(JResult);
    end;

    internal procedure CompanyResponse(Name: Text; CompanyContactId: BigInteger; CustomerId: BigInteger; CompanyLocationId: BigInteger): JsonObject
    var
        JResult: JsonObject;
        ResultLbl: Label '{"name":"%1","id":"gid://shopify/Company/52199654","note":null,"createdAt":"2023-12-12T12:42:18Z","updatedAt":"2023-12-12T13:06:19Z","mainContact":{"id":"gid://shopify/CompanyContact/%2","customer":{"id":"gid://shopify/Customer/%3","firstName":"","lastName":"","email":"","phone":""}},"locations":{"edges":[{"node":{"id":"gid://shopify/CompanyLocation/%4","billingAddress":{"address1":"","address2":null,"city":"","countryCode":"","phone":"","zip":""}}}]}}', Comment = '%1 = Name, %2 = CompanyContactId, %3 = CustomerId, %4 = CompanyLocationId', Locked = true;
    begin
        JResult.ReadFrom(StrSubstNo(ResultLbl, Name, CompanyContactId, CustomerId, CompanyLocationId));
        exit(JResult);
    end;
}
