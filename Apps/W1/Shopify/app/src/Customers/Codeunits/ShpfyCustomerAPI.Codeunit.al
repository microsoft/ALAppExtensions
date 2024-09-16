namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Codeunit Shpfy Customer API (ID 30114).
/// </summary>
codeunit 30114 "Shpfy Customer API"
{
    Access = Internal;
    Permissions = tabledata Customer = rim;

    var
        Shop: Record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        CustomerEvents: Codeunit "Shpfy Customer Events";

    /// <summary> 
    /// Add Field To Graph Query.
    /// </summary>
    /// <param name="GraphQuery">Parameter of type TextBuilder.</param>
    /// <param name="FieldName">Parameter of type Text.</param>
    /// <param name="ValueAsVariant">Parameter of type Variant.</param>
    /// <returns>Return value of type Boolean.</returns>
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

    internal procedure CreateCustomerGraphQLQuery(var ShopifyCustomer: Record "Shpfy Customer"; var ShopifyCustomerAddress: Record "Shpfy Customer Address"): Text
    var
        GraphQuery: TextBuilder;
    begin
        GraphQuery.Append('{"query":"mutation {customerCreate(input: {');
        if ShopifyCustomer.Email <> '' then
            AddFieldToGraphQuery(GraphQuery, 'email', ShopifyCustomer.Email);
        if ShopifyCustomer."First Name" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'firstName', ShopifyCustomer."First Name");
        if ShopifyCustomer."Last Name" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'lastName', ShopifyCustomer."Last Name");
        if ShopifyCustomer."Phone No." <> '' then
            AddFieldToGraphQuery(GraphQuery, 'phone', ShopifyCustomer."Phone No.");
        GraphQuery.Append('addresses: {');
        if ShopifyCustomerAddress.Company <> '' then
            AddFieldToGraphQuery(GraphQuery, 'company', ShopifyCustomerAddress.Company);
        if ShopifyCustomerAddress."First Name" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'firstName', ShopifyCustomerAddress."First Name");
        if ShopifyCustomerAddress."Last Name" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'lastName', ShopifyCustomerAddress."Last Name");
        if ShopifyCustomerAddress.Phone <> '' then
            AddFieldToGraphQuery(GraphQuery, 'phone', ShopifyCustomerAddress.Phone);
        if ShopifyCustomerAddress."Address 1" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'address1', ShopifyCustomerAddress."Address 1");
        if ShopifyCustomerAddress."Address 2" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'address2', ShopifyCustomerAddress."Address 2");
        if ShopifyCustomerAddress.Zip <> '' then
            AddFieldToGraphQuery(GraphQuery, 'zip', ShopifyCustomerAddress.Zip);
        if ShopifyCustomerAddress.City <> '' then
            AddFieldToGraphQuery(GraphQuery, 'city', ShopifyCustomerAddress.City);
        if (ShopifyCustomerAddress."Province Code" <> '') and (ShopifyCustomerAddress."Country/Region Code" <> '') then
            AddFieldToGraphQuery(GraphQuery, 'provinceCode', ShopifyCustomerAddress."Province Code");
        if ShopifyCustomerAddress."Country/Region Code" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'countryCode', ShopifyCustomerAddress."Country/Region Code", false);
        GraphQuery.Remove(GraphQuery.Length - 1, 2);
        GraphQuery.Append('}}) {customer {id, addresses {id, country, province}}, userErrors {field, message}}}"}');
        exit(GraphQuery.ToText());
    end;

    /// <summary> 
    /// Create Customer.
    /// </summary>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="ShopifyCustomerAddress">Parameter of type Record "Shopify Customer Address".</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure CreateCustomer(var ShopifyCustomer: Record "Shpfy Customer"; var ShopifyCustomerAddress: Record "Shpfy Customer Address"): Boolean
    var
        JItem: JsonToken;
        JResponse: JsonToken;
        GraphQuery: Text;
    begin
        CustomerEvents.OnBeforeSendCreateShopifyCustomer(Shop, ShopifyCustomer, ShopifyCustomerAddress);
        GraphQuery := CreateCustomerGraphQLQuery(ShopifyCustomer, ShopifyCustomerAddress);
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery);
        if JResponse.SelectToken('$.data.customerCreate.customer', JItem) then
            if JItem.IsObject then
                ShopifyCustomer.Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JItem, 'id'));
        if (ShopifyCustomer.Id > 0) and JResponse.SelectToken('$.data.customerCreate.customer.addresses', JItem) then
            if JItem.IsArray and (JItem.AsArray().Count = 1) then begin
                JItem.AsArray().Get(0, JItem);
                ShopifyCustomerAddress.Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JItem, 'id'));
                ShopifyCustomerAddress."Customer Id" := ShopifyCustomer.Id;
#pragma warning disable AA0139
                ShopifyCustomerAddress."Country/Region Name" := JsonHelper.GetValueAsText(JItem, 'country');
                ShopifyCustomerAddress."Province Name" := JsonHelper.GetValueAsText(JItem, 'province');
#pragma warning restore AA0139
            end;
        exit(ShopifyCustomer.Id > 0);
    end;

    /// <summary> 
    /// Find Id By Email.
    /// </summary>
    /// <param name="EMail">Parameter of type Text.</param>
    /// <returns>Return value of type BigInteger.</returns>
    internal procedure FindIdByEmail(EMail: Text): BigInteger
    var
        JCustomers: JsonArray;
        JCustomer: JsonObject;
        JItem: JsonToken;
        JResponse: JsonToken;
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
    begin
        if EMail <> '' then begin
            Parameters.Add('EMail', EMail.ToLower());
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::FindCustomerIdByEMail, Parameters);
            if JsonHelper.GetJsonArray(JResponse, JCustomers, 'data.customers.edges') then
                foreach JItem in JCustomers do
                    if JsonHelper.GetJsonObject(JItem.AsObject(), JCustomer, 'node') then
                        exit(CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JCustomer, 'id')));
        end;
    end;

    /// <summary> 
    /// Find Id By Phone.
    /// </summary>
    /// <param name="Phone">Parameter of type Text.</param>
    /// <returns>Return value of type BigInteger.</returns>
    internal procedure FindIdByPhone(Phone: Text): BigInteger
    var
        JCustomers: JsonArray;
        JCustomer: JsonObject;
        JItem: JsonToken;
        JResponse: JsonToken;
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
    begin
        if Phone <> '' then begin
            Parameters.Add('Phone', Phone);
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::FindCustomerIdByPhone, Parameters);
            if JsonHelper.GetJsonArray(JResponse, JCustomers, 'data.customers.edges') then
                foreach JItem in JCustomers do
                    if JsonHelper.GetJsonObject(JItem.AsObject(), JCustomer, 'node') then
                        exit(CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JCustomer, 'id')));
        end;
    end;

    /// <summary> 
    /// Retrieve Shopify Customer.
    /// </summary>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <returns>Return value of type Boolean.</returns>
    internal procedure RetrieveShopifyCustomer(var ShopifyCustomer: Record "Shpfy Customer"): Boolean
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
        JCustomer: JsonObject;
        JResponse: JsonToken;
    begin
        if ShopifyCustomer.Id = 0 then
            exit(false);

        Parameters.Add('CustomerId', Format(ShopifyCustomer.Id));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::GetCustomer, Parameters);
        if JsonHelper.GetJsonObject(JResponse, JCustomer, 'data.customer') then
            exit(UpdateShopifyCustomerFields(ShopifyCustomer, JCustomer));
    end;

    /// <summary> 
    /// Retrieve Shopify Customer Ids.
    /// </summary>
    /// <param name="CustomerIds">Parameter of type Dictionary of [BigInteger, DateTime].</param>
    internal procedure RetrieveShopifyCustomerIds(var CustomerIds: Dictionary of [BigInteger, DateTime])
    var
        Id: BigInteger;
        UpdatedAt: DateTime;
        JCustomers: JsonArray;
        JNode: JsonObject;
        JItem: JsonToken;
        JResponse: JsonToken;
        Cursor: Text;
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
        LastSync: DateTime;
    begin
        GraphQLType := GraphQLType::GetCustomerIds;
        LastSync := Shop.GetLastSyncTime("Shpfy Synchronization Type"::Customers);
        Parameters.Add('LastSync', Format(LastSync, 0, 9));
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            if JsonHelper.GetJsonArray(JResponse, JCustomers, 'data.customers.edges') then begin
                foreach JItem in JCustomers do begin
                    Cursor := JsonHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                    if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                        Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'id'));
                        UpdatedAt := JsonHelper.GetValueAsDateTime(JNode, 'updatedAt');
                        CustomerIds.Add(Id, UpdatedAt);
                    end;
                end;
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', Cursor)
                else
                    Parameters.Add('After', Cursor);
                GraphQLType := GraphQLType::GetNextCustomerIds;
            end;
        until not JsonHelper.GetValueAsBoolean(JResponse, 'data.customers.pageInfo.hasNextPage');
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="Code">Parameter of type Code[20].</param>
    internal procedure SetShop(Code: Code[20])
    begin
        Clear(Shop);
        Shop.Get(Code);
        CommunicationMgt.SetShop(Shop);
    end;

    /// <summary> 
    /// Set Shop.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
        CommunicationMgt.SetShop(Shop);
    end;

    /// <summary> 
    /// Update Customer.
    /// </summary>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="ShopifyCustomerAddress">Parameter of type Record "Shopify Customer Address".</param>
    internal procedure UpdateCustomer(var ShopifyCustomer: Record "Shpfy Customer"; var ShopifyCustomerAddress: Record "Shpfy Customer Address")
    var
        JItem: JsonToken;
        JResponse: JsonToken;
        GraphQuery: Text;
        UpdateCustIdErr: Label 'Wrong updated Customer Id';
        UpdateAddrIdErr: Label 'Wrong updated Address Id';
    begin
        GraphQuery := CreateGraphQueryUpdateCustomer(ShopifyCustomer, ShopifyCustomerAddress);

        if GraphQuery <> '' then begin
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery);
            if JResponse.SelectToken('$.data.customerCreate.customer', JItem) then
                if JItem.IsObject then begin
                    if ShopifyCustomer.Id <> CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JItem, 'id')) then
                        Error(UpdateCustIdErr);
                    if JsonHelper.GetValueAsText(JItem, 'emailMarketingConsent.marketingState') = 'SUBSCRIBED' then
                        ShopifyCustomer."Accepts Marketing" := true
                    else
                        ShopifyCustomer."Accepts Marketing" := false;
                    ShopifyCustomer."Accepts Marketing Update At" := JsonHelper.GetValueAsDateTime(JItem, 'emailMarketingConsent.consentUpdatedAt');
                    ShopifyCustomer."Tax Exempt" := JsonHelper.GetValueAsBoolean(JItem, 'taxExempt');
                    ShopifyCustomer."Updated At" := JsonHelper.GetValueAsDateTime(JItem, 'updatedAt');
                    ShopifyCustomer."Verified Email" := JsonHelper.GetValueAsBoolean(JItem, 'verifiedEmail');
                end;
            if JResponse.SelectToken('$.data.customerCreate.customer', JItem) then
                if JItem.IsObject then
                    ShopifyCustomer.Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JItem, 'id'));

            if (ShopifyCustomer.Id > 0) and JResponse.SelectToken('$.data.customerCreate.customer.defaultAddress', JItem) then
                if JItem.IsObject then begin
                    if (ShopifyCustomerAddress.Id <> CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JItem, 'id'))) then
                        Error(UpdateAddrIdErr);
                    ShopifyCustomerAddress."Customer Id" := ShopifyCustomer.Id;
#pragma warning disable AA0139
                    ShopifyCustomerAddress."Country/Region Name" := JsonHelper.GetValueAsText(JItem, 'country', MaxStrLen(ShopifyCustomerAddress."Country/Region Name"));
                    ShopifyCustomerAddress."Province Name" := JsonHelper.GetValueAsText(JItem, 'province', MaxStrLen(ShopifyCustomerAddress."Province Name"));
#pragma warning restore AA0139
                end;
        end;
    end;

    internal procedure CreateGraphQueryUpdateCustomer(var ShopifyCustomer: Record "Shpfy Customer"; var ShopifyCustomerAddress: Record "Shpfy Customer Address"): Text
    var
        xShopifyCustomer: Record "Shpfy Customer";
        xShopifyCustomerAddress: Record "Shpfy Customer Address";
        HasChange: Boolean;
        GraphQuery: TextBuilder;
        CustomerIdTxt: Label 'gid://shopify/Customer/%1', Comment = '%1 = Customer Id', Locked = true;
        MailingAddressIdTxt: Label 'gid://shopify/MailingAddress/%1?model_name=CustomerAddress', Comment = '%1 = Address Id', Locked = true;
    begin
        xShopifyCustomer.Get(ShopifyCustomer.Id);
        xShopifyCustomerAddress.Get(ShopifyCustomerAddress.Id);
        CustomerEvents.OnBeforeSendUpdateShopifyCustomer(Shop, ShopifyCustomer, ShopifyCustomerAddress, xShopifyCustomer, xShopifyCustomerAddress);
        GraphQuery.Append('{"query":"mutation {customerUpdate(input: {');
        AddFieldToGraphQuery(GraphQuery, 'id', StrSubstNo(CustomerIdTxt, ShopifyCustomer.Id));
        if ShopifyCustomer.Email <> xShopifyCustomer.Email then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'email', ShopifyCustomer.Email);
        if ShopifyCustomer."First Name" <> xShopifyCustomer."First Name" then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'firstName', ShopifyCustomer."First Name");
        if ShopifyCustomer."Last Name" <> xShopifyCustomer."Last Name" then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'lastName', ShopifyCustomer."Last Name");
        if ShopifyCustomer."Phone No." <> xShopifyCustomer."Phone No." then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'phone', ShopifyCustomer."Phone No.");
        if ShopifyCustomer.GetNote() <> xShopifyCustomer.GetNote() then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'note', CommunicationMgt.EscapeGraphQLData(ShopifyCustomer.GetNote()));

        GraphQuery.Append('addresses: {');

        AddFieldToGraphQuery(GraphQuery, 'id', StrSubstNo(MailingAddressIdTxt, ShopifyCustomerAddress.Id));
        if ShopifyCustomerAddress.Company <> '' then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'company', ShopifyCustomerAddress.Company);
        if ShopifyCustomerAddress."First Name" <> xShopifyCustomer."First Name" then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'firstName', ShopifyCustomerAddress."First Name");
        if ShopifyCustomerAddress."Last Name" <> xShopifyCustomer."Last Name" then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'lastName', ShopifyCustomerAddress."Last Name");
        if ShopifyCustomerAddress."Address 1" <> '' then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'address1', CommunicationMgt.EscapeGraphQLData(ShopifyCustomerAddress."Address 1"));
        if ShopifyCustomerAddress."Address 2" <> '' then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'address2', CommunicationMgt.EscapeGraphQLData(ShopifyCustomerAddress."Address 2"));
        if ShopifyCustomerAddress.Zip <> '' then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'zip', ShopifyCustomerAddress.Zip);
        if ShopifyCustomerAddress.City <> '' then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'city', CommunicationMgt.EscapeGraphQLData(ShopifyCustomerAddress.City));
        if ShopifyCustomerAddress."Province Code" <> '' then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'provinceCode', ShopifyCustomerAddress."Province Code");
        if ShopifyCustomerAddress."Country/Region Code" <> '' then
            HasChange := GraphQuery.Append('countryCode: ' + ShopifyCustomerAddress."Country/Region Code" + ', ');
        if ShopifyCustomerAddress.Phone <> '' then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'phone', ShopifyCustomerAddress.Phone);


        if HasChange then begin
            GraphQuery.Remove(GraphQuery.Length - 1, 2);
            GraphQuery.Append('}}) {customer {id, tags, updatedAt, verifiedEmail, emailMarketingConsent {consentUpdatedAt marketingState}, defaultAddress {id, province, country}}, userErrors {field, message}}}"}');
            exit(GraphQuery.ToText());
        end;
    end;

    /// <summary> 
    /// Update Shopify Customer Fields.
    /// </summary>
    /// <param name="ShopifyCustomer">Parameter of type Record "Shopify Customer".</param>
    /// <param name="JCustomer">Parameter of type JsonObject.</param>
    /// <returns>Return variable "Result" of type Boolean.</returns>
    internal procedure UpdateShopifyCustomerFields(var ShopifyCustomer: Record "Shpfy Customer"; JCustomer: JsonObject) Result: Boolean
    var
        CustomerAddress: Record "Shpfy Customer Address";
        NodeId: BigInteger;
        UpdatedAt: DateTime;
        JAddresses: JsonArray;
        JTags: JsonArray;
        JAddress: JsonObject;
        JItem: JsonToken;
        Ids: List of [BigInteger];
        OutStream: OutStream;
        StateString: Text;
        FilterString: TextBuilder;
        PhoneNo: Text;
    begin
        UpdatedAt := JsonHelper.GetValueAsDateTime(JCustomer, 'updatedAt');
        if UpdatedAt <= ShopifyCustomer."Updated At" then
            exit(false);
        Result := true;

        ShopifyCustomer."Updated At" := UpdatedAt;
        ShopifyCustomer."Created At" := JsonHelper.GetValueAsDateTime(JCustomer, 'createdAt');
#pragma warning disable AA0139
        ShopifyCustomer."First Name" := JsonHelper.GetValueAsText(JCustomer, 'firstName', MaxStrLen(ShopifyCustomer."First Name"));
        ShopifyCustomer."Last Name" := JsonHelper.GetValueAsText(JCustomer, 'lastName', MaxStrLen(ShopifyCustomer."Last Name"));
        ShopifyCustomer.Email := JsonHelper.GetValueAsText(JCustomer, 'email', MaxStrLen(ShopifyCustomer.Email));
#pragma warning restore AA0139
        PhoneNo := JsonHelper.GetValueAsText(JCustomer, 'phone');
        PhoneNo := DelChr(PhoneNo, '=', DelChr(PhoneNo, '=', '1234567890/+ .()'));
        ShopifyCustomer."Phone No." := CopyStr(PhoneNo, 1, MaxStrLen(ShopifyCustomer."Phone No."));
        if JsonHelper.GetValueAsText(JCustomer, 'emailMarketingConsent.marketingState') = 'SUBSCRIBED' then
            ShopifyCustomer."Accepts Marketing" := true
        else
            ShopifyCustomer."Accepts Marketing" := false;
        ShopifyCustomer."Accepts Marketing Update At" := JsonHelper.GetValueAsDateTime(JCustomer, 'emailMarketingConsent.consentUpdatedAt');
        ShopifyCustomer."Tax Exempt" := JsonHelper.GetValueAsBoolean(JCustomer, 'taxExempt');
        ShopifyCustomer."Verified Email" := JsonHelper.GetValueAsBoolean(JCustomer, 'verifiedEmail');
        StateString := JsonHelper.GetValueAsText(JCustomer, 'state').ToLower();
        StateString := Format(StateString[1]).ToUpper() + CopyStr(StateString, 2);
        Evaluate(ShopifyCustomer.State, StateString);
        if JsonHelper.GetValueAsText(JCustomer, 'note') <> '' then begin
            Clear(ShopifyCustomer.Note);
            ShopifyCustomer.Note.CreateOutStream(OutStream, TextEncoding::UTF8);
            OutStream.WriteText(JsonHelper.GetValueAsText(JCustomer, 'note'));
        end else
            Clear(ShopifyCustomer.Note);
        ShopifyCustomer."Created At" := JsonHelper.GetValueAsDateTime(JCustomer, 'createdAt');
        ShopifyCustomer.Modify(false);


        if JsonHelper.GetJsonArray(JCustomer, JTags, 'tags') then
            ShopifyCustomer.UpdateTags(JsonHelper.GetArrayAsText(JTags));

        if JsonHelper.GetJsonArray(JCustomer, JAddresses, 'addresses') then begin
            Clear(Ids);
            foreach JItem in JAddresses do begin
                JAddress := JItem.AsObject();
                NodeId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JAddress, 'id'));
                Ids.Add(NodeId);
                Clear(CustomerAddress);
                CustomerAddress.SetRange(Id, NodeId);
                if not CustomerAddress.FindFirst() then begin
                    CustomerAddress.Init();
                    CustomerAddress."Customer Id" := ShopifyCustomer.Id;
                    CustomerAddress.Id := NodeId;
                    CustomerAddress.Insert(false);
                end;
#pragma warning disable AA0139
                CustomerAddress.Company := JsonHelper.GetValueAsText(JAddress, 'company', MaxStrLen(CustomerAddress.Company));
                CustomerAddress."First Name" := JsonHelper.GetValueAsText(JAddress, 'firstName', MaxStrLen(CustomerAddress."First Name"));
                CustomerAddress."Last Name" := JsonHelper.GetValueAsText(JAddress, 'lastName', MaxStrLen(CustomerAddress."Last Name"));
                CustomerAddress."Address 1" := JsonHelper.GetValueAsText(JAddress, 'address1', MaxStrLen(CustomerAddress."Address 1"));
                CustomerAddress."Address 2" := JsonHelper.GetValueAsText(JAddress, 'address2', MaxStrLen(CustomerAddress."Address 2"));
                CustomerAddress.Zip := JsonHelper.GetValueAsText(JAddress, 'zip', MaxStrLen(CustomerAddress.Zip));
                CustomerAddress.City := JsonHelper.GetValueAsText(JAddress, 'city', MaxStrLen(CustomerAddress.City));
                CustomerAddress."Country/Region Code" := JsonHelper.GetValueAsText(JAddress, 'countryCodeV2');
                CustomerAddress."Country/Region Name" := JsonHelper.GetValueAsText(JAddress, 'country');
                CustomerAddress."Province Code" := JsonHelper.GetValueAsText(JAddress, 'provinceCode', MaxStrLen(CustomerAddress."Province Code"));
                CustomerAddress."Province Name" := JsonHelper.GetValueAsText(JAddress, 'province', MaxStrLen(CustomerAddress."Province Name"));
#pragma warning restore AA0139
                PhoneNo := JsonHelper.GetValueAsText(JAddress, 'phone');
                PhoneNo := CopyStr(DelChr(PhoneNo, '=', DelChr(PhoneNo, '=', '1234567890/+ .()')), 1, MaxStrLen(CustomerAddress.Phone));
                CustomerAddress.Phone := CopyStr(PhoneNo, 1, MaxStrLen(CustomerAddress.Phone));
                CustomerAddress.Default := false;
                CustomerAddress.Modify(false);
            end;
            Clear(CustomerAddress);
            CustomerAddress.SetRange("Customer Id", ShopifyCustomer.Id);
            Clear(FilterString);
            foreach NodeId in Ids do begin
                FilterString.Append('&<>');
                FilterString.Append(Format(NodeId));
            end;
            if FilterString.Length > 0 then begin
                FilterString.Remove(1, 1);
                CustomerAddress.SetFilter(Id, FilterString.ToText());
                if not CustomerAddress.IsEmpty then
                    CustomerAddress.DeleteAll(false);
            end;

            if JsonHelper.GetJsonObject(JCustomer, JAddress, 'defaultAddress') then begin
                NodeId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JAddress, 'id'));
                Clear(CustomerAddress);
                CustomerAddress.SetRange(Id, NodeId);
                if CustomerAddress.FindFirst() then begin
                    CustomerAddress.Default := true;
                    CustomerAddress.Modify(false);
                end;
            end;
        end;
    end;

    internal procedure FillInMissingShopIds()
    var
        ShopCounter: Record "Shpfy Shop";
        ShopifyCustomer: Record "Shpfy Customer";
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
        JResult: JsonToken;
        JArray: JsonArray;
        FilterString: Text;
    begin
        ShopifyCustomer.SetRange("Shop Id", 0);
        ShopifyCustomer.SetCurrentKey("Shop Id");
        if ShopifyCustomer.IsEmpty then
            exit;

        if ShopCounter.Count = 1 then
            ShopifyCustomer.ModifyAll("Shop Id", Shop."Shop Id", false)
        else begin
            GraphQLType := "Shpfy GraphQL Type"::GetAllCustomerIds;
            repeat
                JResult := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
                GraphQLType := "Shpfy GraphQL Type"::GetNextAllCustomerIds;
                if JsonHelper.GetJsonArray(JResult, JArray, 'data.customers.nodes') then begin
                    FilterString := Format(JArray).TrimStart('[').TrimEnd(']').Replace('{"legacyResourceId":"', '').Replace('"}', '').Replace(',', '|');
                    ShopifyCustomer.SetFilter(Id, FilterString);
                    if not ShopifyCustomer.IsEmpty() then
                        ShopifyCustomer.ModifyAll("Shop Id", Shop."Shop Id", false);
                end;
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', JsonHelper.GetValueAsText(JResult, 'data.customers.pageInfo.endCursor'))
                else
                    Parameters.Add('After', JsonHelper.GetValueAsText(JResult, 'data.customers.pageInfo.endCursor'));
            until not JsonHelper.GetValueAsBoolean(JResult, 'data.customers.pageInfo.hasNextPage');
        end;
        Commit();
    end;
}