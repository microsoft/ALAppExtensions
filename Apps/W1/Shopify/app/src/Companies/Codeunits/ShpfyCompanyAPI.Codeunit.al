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
        MetafieldAPI: Codeunit "Shpfy Metafield API";

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
            if JItem.IsObject then begin
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
            end;
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
        MetafieldAPI.SetShop(Shop);
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
        GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(Format(ValueAsVariant)));
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
        AddFieldToGraphQuery(GraphQuery, 'name', CompanyLocation.Name);
        if CompanyLocation."Phone No." <> '' then
            AddFieldToGraphQuery(GraphQuery, 'phone', CompanyLocation."Phone No.");
        GraphQuery.Append('shippingAddress: {');
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
        if CompanyLocation."Province Code" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'zoneCode', CompanyLocation."Province Code");
        if CompanyLocation.Recipient <> '' then
            AddFieldToGraphQuery(GraphQuery, 'recipient', CompanyLocation.Recipient);
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
            HasChange := AddFieldToGraphQuery(GraphQuery, 'note', CommunicationMgt.EscapeGraphQLData(ShopifyCompany.GetNote()));

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
        if CompanyLocation."Province Code" <> xCompanyLocation."Province Code" then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'zoneCode', CompanyLocation."Province Code");
        if CompanyLocation.Recipient <> xCompanyLocation.Recipient then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'recipient', CompanyLocation.Recipient);
        GraphQuery.Remove(GraphQuery.Length - 1, 2);

        if HasChange then begin
            GraphQuery.Append('}) {addresses {id}, userErrors {field, message}}}"}');
            exit(GraphQuery.ToText());
        end;
    end;

    internal procedure RetrieveShopifyCompanyIds(var CompanyIds: Dictionary of [BigInteger, DateTime])
    var
        Id: BigInteger;
        UpdatedAt: DateTime;
        JCompanies: JsonArray;
        JNode: JsonObject;
        JItem: JsonToken;
        JResponse: JsonToken;
        Cursor: Text;
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
        LastSync: DateTime;
    begin
        GraphQLType := GraphQLType::GetCompanyIds;
        LastSync := Shop.GetLastSyncTime("Shpfy Synchronization Type"::Companies);
        Parameters.Add('LastSync', Format(LastSync, 0, 9));
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JsonHelper.GetJsonArray(JResponse, JCompanies, 'data.companies.edges') then begin
                foreach JItem in JCompanies do begin
                    Cursor := JsonHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                    if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                        Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'id'));
                        UpdatedAt := JsonHelper.GetValueAsDateTime(JNode, 'updatedAt');
                        CompanyIds.Add(Id, UpdatedAt);
                    end;
                end;
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', Cursor)
                else
                    Parameters.Add('After', Cursor);
                GraphQLType := GraphQLType::GetNextCompanyIds;
            end;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.companies.pageInfo.hasNextPage');
    end;

    internal procedure RetrieveShopifyCompany(var ShopifyCompany: Record "Shpfy Company"; var TempShopifyCustomer: Record "Shpfy Customer" temporary): Boolean
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
        JCompany: JsonObject;
        JCustomer: JsonObject;
        JResponse: JsonToken;
    begin
        if ShopifyCompany.Id = 0 then
            exit(false);

        Parameters.Add('CompanyId', Format(ShopifyCompany.Id));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::GetCompany, Parameters);

        if not JsonHelper.GetJsonObject(JResponse, JCustomer, 'data.company.mainContact') then
            exit(false)
        else
            UpdateShopifyCustomerFields(TempShopifyCustomer, JCustomer);

        if JsonHelper.GetJsonObject(JResponse, JCompany, 'data.company') then
            exit(UpdateShopifyCompanyFields(ShopifyCompany, JCompany));
    end;

    internal procedure UpdateShopifyCustomerFields(var TempShopifyCustomer: Record "Shpfy Customer" temporary; JCustomer: JsonObject)
    var
        PhoneNo: Text;
    begin
        Clear(TempShopifyCustomer);
        TempShopifyCustomer."Shop Id" := Shop."Shop Id";
        TempShopifyCustomer.Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JCustomer, 'customer.id'));
        TempShopifyCustomer."First Name" := CopyStr(JsonHelper.GetValueAsText(JCustomer, 'customer.firstName', MaxStrLen(TempShopifyCustomer."First Name")), 1, MaxStrLen(TempShopifyCustomer."First Name"));
        TempShopifyCustomer."Last Name" := CopyStr(JsonHelper.GetValueAsText(JCustomer, 'customer.lastName', MaxStrLen(TempShopifyCustomer."Last Name")), 1, MaxStrLen(TempShopifyCustomer."Last Name"));
        TempShopifyCustomer.Email := CopyStr(JsonHelper.GetValueAsText(JCustomer, 'customer.email', MaxStrLen(TempShopifyCustomer.Email)), 1, MaxStrLen(TempShopifyCustomer.Email));
        PhoneNo := JsonHelper.GetValueAsText(JCustomer, 'customer.phone');
        PhoneNo := DelChr(PhoneNo, '=', DelChr(PhoneNo, '=', '1234567890/+ .()'));
        TempShopifyCustomer."Phone No." := CopyStr(PhoneNo, 1, MaxStrLen(TempShopifyCustomer."Phone No."));
    end;

    internal procedure UpdateShopifyCompanyFields(var ShopifyCompany: Record "Shpfy Company"; JCompany: JsonObject) Result: Boolean
    var
        CompanyLocation: Record "Shpfy Company Location";
        UpdatedAt: DateTime;
        JLocations: JsonArray;
        JMetafields: JsonArray;
        JItem: JsonToken;
        OutStream: OutStream;
        PhoneNo: Text;
    begin
        UpdatedAt := JsonHelper.GetValueAsDateTime(JCompany, 'updatedAt');
        if UpdatedAt <= ShopifyCompany."Updated At" then
            exit(false);
        Result := true;

        ShopifyCompany."Updated At" := UpdatedAt;
        ShopifyCompany."Created At" := JsonHelper.GetValueAsDateTime(JCompany, 'createdAt');
        ShopifyCompany."Main Contact Id" := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JCompany, 'mainContact.id'));
        ShopifyCompany."Main Contact Customer Id" := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JCompany, 'mainContact.customer.id'));
        ShopifyCompany.Name := CopyStr(JsonHelper.GetValueAsText(JCompany, 'name', MaxStrLen(ShopifyCompany.Name)), 1, MaxStrLen(ShopifyCompany.Name));
        if JsonHelper.GetValueAsText(JCompany, 'note') <> '' then begin
            Clear(ShopifyCompany.Note);
            ShopifyCompany.Note.CreateOutStream(OutStream, TextEncoding::UTF8);
            OutStream.WriteText(JsonHelper.GetValueAsText(JCompany, 'note'));
        end else
            Clear(ShopifyCompany.Note);
        ShopifyCompany.Modify();

        if JsonHelper.GetJsonArray(JCompany, JLocations, 'locations.edges') then
            if JLocations.Count = 1 then
                if JLocations.Get(0, JItem) then begin
                    ShopifyCompany."Location Id" := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JItem, 'node.id'));

                    CompanyLocation.SetRange(Id, ShopifyCompany."Location Id");
                    if not CompanyLocation.FindFirst() then begin
                        CompanyLocation.Id := ShopifyCompany."Location Id";
                        CompanyLocation."Company SystemId" := ShopifyCompany.SystemId;
                        CompanyLocation.Name := CopyStr(JsonHelper.GetValueAsText(JItem, 'node.name'), 1, MaxStrLen(CompanyLocation.Name));
                        CompanyLocation.Insert();
                    end;

                    CompanyLocation.Address := CopyStr(JsonHelper.GetValueAsText(JItem, 'node.billingAddress.address1', MaxStrLen(CompanyLocation.Address)), 1, MaxStrLen(CompanyLocation.Address));
                    CompanyLocation."Address 2" := CopyStr(JsonHelper.GetValueAsText(JItem, 'node.billingAddress.address2', MaxStrLen(CompanyLocation."Address 2")), 1, MaxStrLen(CompanyLocation."Address 2"));
                    CompanyLocation.Zip := CopyStr(JsonHelper.GetValueAsCode(JItem, 'node.billingAddress.zip', MaxStrLen(CompanyLocation.Zip)), 1, MaxStrLen(CompanyLocation.Zip));
                    CompanyLocation.City := CopyStr(JsonHelper.GetValueAsText(JItem, 'node.billingAddress.city', MaxStrLen(CompanyLocation.City)), 1, MaxStrLen(CompanyLocation.City));
                    CompanyLocation."Country/Region Code" := CopyStr(JsonHelper.GetValueAsCode(JItem, 'node.billingAddress.countryCode', MaxStrLen(CompanyLocation."Country/Region Code")), 1, MaxStrLen(CompanyLocation."Country/Region Code"));
                    CompanyLocation."Province Code" := CopyStr(JsonHelper.GetValueAsText(JItem, 'node.billingAddress.zoneCode', MaxStrLen(CompanyLocation."Province Code")), 1, MaxStrLen(CompanyLocation."Province Code"));
                    CompanyLocation."Province Name" := CopyStr(JsonHelper.GetValueAsText(JItem, 'node.billingAddress.province', MaxStrLen(CompanyLocation."Province Name")), 1, MaxStrLen(CompanyLocation."Province Name"));
                    PhoneNo := JsonHelper.GetValueAsText(JItem, 'node.billingAddress.phone');
                    PhoneNo := CopyStr(DelChr(PhoneNo, '=', DelChr(PhoneNo, '=', '1234567890/+ .()')), 1, MaxStrLen(CompanyLocation."Phone No."));
                    CompanyLocation."Phone No." := CopyStr(PhoneNo, 1, MaxStrLen(CompanyLocation."Phone No."));
                    CompanyLocation."Tax Registration Id" := CopyStr(JsonHelper.GetValueAsText(JItem, 'node.taxRegistrationId', MaxStrLen(CompanyLocation."Tax Registration Id")), 1, MaxStrLen(CompanyLocation."Tax Registration Id"));
                    CompanyLocation.Recipient := CopyStr(JsonHelper.GetValueAsText(JItem, 'node.billingAddress.recipient', MaxStrLen(CompanyLocation.Recipient)), 1, MaxStrLen(CompanyLocation.Recipient));
                    CompanyLocation.Modify();
                end;
        if JsonHelper.GetJsonArray(JCompany, JMetafields, 'metafields.edges') then
            MetafieldAPI.UpdateMetafieldsFromShopify(JMetafields, Database::"Shpfy Company", ShopifyCompany.Id);
    end;
}