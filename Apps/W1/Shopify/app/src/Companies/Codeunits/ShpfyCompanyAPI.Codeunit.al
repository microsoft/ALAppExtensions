namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Codeunit Shpfy Company API (ID 30286).
/// </summary>
codeunit 30286 "Shpfy Company API"
{
    Access = Internal;
    Permissions = tabledata Customer = rim;

    var
        Shop: Record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    internal procedure CreateCompany(var ShopifyCompany: Record "Shpfy Company"; var CompanyLocation: Record "Shpfy Company Location"; ShopifyCustomer: Record "Shpfy Customer"): Boolean
    var
        JItem: JsonToken;
        JResponse: JsonToken;
        JLocations: JsonArray;
        GraphQuery: Text;
        CompanyContactId: BigInteger;
        CompanyContactRoles: Dictionary of [Text, BigInteger];
    begin
        GraphQuery := CreateCompanyGraphQLQuery(ShopifyCompany, CompanyLocation);
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery);
        if JResponse.SelectToken('$.data.companyCreate.company', JItem) then
            if JItem.IsObject then
                ShopifyCompany.Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JItem, 'id'));
        if JsonHelper.GetJsonArray(JResponse, JLocations, 'data.companyCreate.company.locations.edges') then
            if JLocations.Count = 1 then
                if JLocations.Get(0, JItem) then begin
                    ShopifyCompany."Location Id" := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JItem, 'node.id'));
                    CompanyLocation.Id := ShopifyCompany."Location Id";
                end;
        if JsonHelper.GetJsonArray(JResponse, JLocations, 'data.companyCreate.company.contactRoles.edges') then
            foreach JItem in JLocations do
                CompanyContactRoles.Add(JsonHelper.GetValueAsText(JItem, 'node.name'), CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JItem, 'node.id')));
        if ShopifyCompany.Id > 0 then begin
            CompanyContactId := AssignCompanyMainContact(ShopifyCompany.Id, ShopifyCustomer.Id, ShopifyCompany."Location Id", CompanyContactRoles);
            ShopifyCompany."Main Contact Id" := CompanyContactId;
            exit(true);
        end else
            exit(false);
    end;

    internal procedure UpdateCompany(var ShopifyCompany: Record "Shpfy Company"; var CompanyLocation: Record "Shpfy Company Location")
    var
        JItem: JsonToken;
        JResponse: JsonToken;
        GraphQuery: Text;
        UpdateCustIdErr: Label 'Wrong updated Customer Id';
    begin
        GraphQuery := CreateGraphQueryUpdateCompany(ShopifyCompany);

        if GraphQuery <> '' then begin
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery);
            if JResponse.SelectToken('$.data.companyUpdate.company', JItem) then
                if JItem.IsObject then begin
                    if ShopifyCompany.Id <> CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JItem, 'id')) then
                        Error(UpdateCustIdErr);
                    ShopifyCompany."Updated At" := JsonHelper.GetValueAsDateTime(JItem, 'updatedAt');
                end;
        end;

        GraphQuery := CreateGraphQueryUpdateLocation(CompanyLocation);
        if GraphQuery <> '' then
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery);
    end;

    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CommunicationMgt.SetShop(Shop);
    end;

    local procedure AddFieldToGraphQuery(var GraphQuery: TextBuilder; FieldName: Text; ValueAsVariant: Variant): Boolean
    begin
        exit(AddFieldToGraphQuery(GraphQuery, FieldName, ValueAsVariant, true));
    end;

    local procedure AddFieldToGraphQuery(var GraphQuery: TextBuilder; FieldName: Text; ValueAsVariant: Variant; ValueAsString: Boolean): Boolean
    begin
        GraphQuery.Append(FieldName);
        if ValueAsString then
            GraphQuery.Append(': \"')
        else
            GraphQuery.Append(': ');
        GraphQuery.Append(CommunicationMgt.EscapeGrapQLData(Format(ValueAsVariant)));
        if ValueAsString then
            GraphQuery.Append('\", ')
        else
            GraphQuery.Append(', ');
        exit(true);
    end;

    internal procedure CreateCompanyGraphQLQuery(var ShopifyCompany: Record "Shpfy Company"; CompanyLocation: Record "Shpfy Company Location"): Text
    var
        GraphQuery: TextBuilder;
    begin
        GraphQuery.Append('{"query":"mutation {companyCreate(input: {company: {');
        if ShopifyCompany.Name <> '' then
            AddFieldToGraphQuery(GraphQuery, 'name', ShopifyCompany.Name);
        GraphQuery.Remove(GraphQuery.Length - 1, 2);
        GraphQuery.Append('}, companyLocation: {billingSameAsShipping: true,');
        AddFieldToGraphQuery(GraphQuery, 'name', 'Main');
        if CompanyLocation."Phone No." <> '' then
            AddFieldToGraphQuery(GraphQuery, 'phone', CompanyLocation."Phone No.");
        GraphQuery.Append('shippingAddress: {');
        if CompanyLocation.Address <> '' then
            AddFieldToGraphQuery(GraphQuery, 'address1', CompanyLocation.Address);
        if CompanyLocation."Address 2" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'address2', CompanyLocation."Address 2");
        if CompanyLocation.Zip <> '' then
            AddFieldToGraphQuery(GraphQuery, 'zip', CompanyLocation.Zip);
        if CompanyLocation.City <> '' then
            AddFieldToGraphQuery(GraphQuery, 'city', CompanyLocation.City);
        if CompanyLocation."Phone No." <> '' then
            AddFieldToGraphQuery(GraphQuery, 'phone', CompanyLocation."Phone No.");
        if CompanyLocation."Country/Region Code" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'countryCode', CompanyLocation."Country/Region Code", false);
        GraphQuery.Remove(GraphQuery.Length - 1, 2);
        GraphQuery.Append('}}}) {company {id, name, locations(first: 1) {edges {node {id, name}}}, contactRoles(first:10) {edges {node {id,name}}}}, userErrors {field, message}}}"}');
        exit(GraphQuery.ToText());
    end;

    local procedure AssignCompanyMainContact(CompanyId: BigInteger; CustomerId: BigInteger; LocationId: BigInteger; CompanyContactRoles: Dictionary of [Text, BigInteger]): BigInteger
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        JResponse: JsonToken;
        Parameters: Dictionary of [Text, Text];
        CompanyContactId: BigInteger;
    begin
        Parameters.Add('CompanyId', Format(CompanyId));
        Parameters.Add('CustomerId', Format(CustomerId));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::CompanyAssignCustomerAsContact, Parameters);
        CompanyContactId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JResponse, 'data.companyAssignCustomerAsContact.companyContact.id'));
        if CompanyContactId > 0 then begin
            Clear(Parameters);
            Parameters.Add('CompanyId', Format(CompanyId));
            Parameters.Add('CompanyContactId', Format(CompanyContactId));
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::CompanyAssignMainContact, Parameters);
            AssignCompanyContactRoles(CompanyContactId, LocationId, CompanyContactRoles);
        end;
        exit(CompanyContactId);
    end;

    local procedure AssignCompanyContactRoles(CompanyContactId: BigInteger; LocationId: BigInteger; CompanyContactRoles: Dictionary of [Text, BigInteger])
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        JResponse: JsonToken;
        Parameters: Dictionary of [Text, Text];
    begin
        if Shop."Default Contact Permission" = "Shpfy Default Cont. Permission"::"No Permission" then
            exit
        else begin
            Parameters.Add('LocationId', Format(LocationId));
            Parameters.Add('ContactId', Format(CompanyContactId));
            Parameters.Add('ContactRoleId', Format(CompanyContactRoles.Get(Enum::"Shpfy Default Cont. Permission".Names().Get(Enum::"Shpfy Default Cont. Permission".Ordinals().IndexOf(Shop."Default Contact Permission".AsInteger())))));
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::CompanyAssignContactRole, Parameters);
        end;
    end;

    internal procedure CreateGraphQueryUpdateCompany(var ShopifyCompany: Record "Shpfy Company"): Text
    var
        xShopifyCompany: Record "Shpfy Company";
        HasChange: Boolean;
        GraphQuery: TextBuilder;
        CompanyIdTxt: Label 'gid://shopify/Company/%1', Comment = '%1 = Company Id', Locked = true;
    begin
        xShopifyCompany.Get(ShopifyCompany.Id);
        GraphQuery.Append('{"query":"mutation {companyUpdate(companyId: \"' + StrSubstNo(CompanyIdTxt, ShopifyCompany.Id) + '\", input: {');
        if ShopifyCompany.Name <> xShopifyCompany.Name then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'name', ShopifyCompany.Name);
        if ShopifyCompany.GetNote() <> xShopifyCompany.GetNote() then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'note', CommunicationMgt.EscapeGrapQLData(ShopifyCompany.GetNote()));

        if HasChange then begin
            GraphQuery.Remove(GraphQuery.Length - 1, 2);
            GraphQuery.Append('}) {company {id, updatedAt}, userErrors {field, message}}}"}');
            exit(GraphQuery.ToText());
        end;
    end;

    internal procedure CreateGraphQueryUpdateLocation(var CompanyLocation: Record "Shpfy Company Location"): Text
    var
        xCompanyLocation: Record "Shpfy Company Location";
        HasChange: Boolean;
        GraphQuery: TextBuilder;
        CompanyLocationIdTxt: Label 'gid://shopify/CompanyLocation/%1', Comment = '%1 = Company Location Id', Locked = true;
    begin
        xCompanyLocation.Get(CompanyLocation.Id);
        GraphQuery.Append('{"query":"mutation {companyLocationAssignAddress(locationId: \"' + StrSubstNo(CompanyLocationIdTxt, CompanyLocation.Id) + '\", addressTypes: [BILLING,SHIPPING] address: {');
        if CompanyLocation.Address <> xCompanyLocation.Address then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'address1', CompanyLocation.Address);
        if CompanyLocation."Address 2" <> xCompanyLocation."Address 2" then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'address2', CompanyLocation."Address 2");
        if CompanyLocation.Zip <> xCompanyLocation.Zip then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'zip', CompanyLocation.Zip);
        if CompanyLocation.City <> xCompanyLocation.City then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'city', CompanyLocation.City);
        if CompanyLocation."Phone No." <> xCompanyLocation."Phone No." then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'phone', CompanyLocation."Phone No.");
        if CompanyLocation."Country/Region Code" <> xCompanyLocation."Country/Region Code" then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'countryCode', CompanyLocation."Country/Region Code", false);
        GraphQuery.Remove(GraphQuery.Length - 1, 2);

        if HasChange then begin
            GraphQuery.Append('}) {addresses {id}, userErrors {field, message}}}"}');
            exit(GraphQuery.ToText());
        end;
    end;
}