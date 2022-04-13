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
        JHelper: Codeunit "Shpfy Json Helper";
        Events: Codeunit "Shpfy Customer Events";

    /// <summary> 
    /// Add Field To Graph Query.
    /// </summary>
    /// <param name="GraphQuery">Parameter of type TextBuilder.</param>
    /// <param name="FieldName">Parameter of type Text.</param>
    /// <param name="Value">Parameter of type Variant.</param>
    /// <returns>Return value of type Boolean.</returns>
    local procedure AddFieldToGraphQuery(var GraphQuery: TextBuilder; FieldName: Text; Value: Variant): Boolean
    begin
        GraphQuery.Append(FieldName);
        GraphQuery.Append(': \"');
        GraphQuery.Append(Format(Value));
        GraphQuery.Append('\", ');
        exit(true);
    end;

    internal procedure CreateCustomerGraphQLQuery(var ShopifyCustomer: Record "Shpfy Customer"; var ShopifyCustomerAddress: Record "Shpfy Customer Address"): Text
    var
        GraphQuery: TextBuilder;
    begin
        GraphQuery.Append('{"query":"mutation {customerCreate(input: {');
        if ShopifyCustomer."E-Mail" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'email', ShopifyCustomer."E-Mail");
        if ShopifyCustomer.FirstName <> '' then
            AddFieldToGraphQuery(GraphQuery, 'firstName', ShopifyCustomer.FirstName);
        if ShopifyCustomer.LastName <> '' then
            AddFieldToGraphQuery(GraphQuery, 'lastName', ShopifyCustomer.LastName);
        if ShopifyCustomer."Phone No." <> '' then
            AddFieldToGraphQuery(GraphQuery, 'phone', ShopifyCustomer."Phone No.");
        GraphQuery.Append('addresses: {');
        if ShopifyCustomerAddress.Company <> '' then
            AddFieldToGraphQuery(GraphQuery, 'company', ShopifyCustomerAddress.Company);
        if ShopifyCustomerAddress.FirstName <> '' then
            AddFieldToGraphQuery(GraphQuery, 'firstName', ShopifyCustomerAddress.FirstName);
        if ShopifyCustomerAddress.LastName <> '' then
            AddFieldToGraphQuery(GraphQuery, 'lastName', ShopifyCustomerAddress.LastName);
        if ShopifyCustomerAddress.Phone <> '' then
            AddFieldToGraphQuery(GraphQuery, 'phone', ShopifyCustomerAddress.Phone);
        if ShopifyCustomerAddress.Address1 <> '' then
            AddFieldToGraphQuery(GraphQuery, 'address1', ShopifyCustomerAddress.Address1);
        if ShopifyCustomerAddress.Address2 <> '' then
            AddFieldToGraphQuery(GraphQuery, 'address2', ShopifyCustomerAddress.Address2);
        if ShopifyCustomerAddress.Zip <> '' then
            AddFieldToGraphQuery(GraphQuery, 'zip', ShopifyCustomerAddress.Zip);
        if ShopifyCustomerAddress.City <> '' then
            AddFieldToGraphQuery(GraphQuery, 'city', ShopifyCustomerAddress.City);
        if ShopifyCustomerAddress.ProvinceCode <> '' then
            AddFieldToGraphQuery(GraphQuery, 'provinceCode', ShopifyCustomerAddress.ProvinceCode);
        if ShopifyCustomerAddress.CountryCode <> '' then
            AddFieldToGraphQuery(GraphQuery, 'countryCode', ShopifyCustomerAddress.CountryCode);
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
        Events.OnBeforeSendCreateShopifyCustomer(Shop, ShopifyCustomer, ShopifyCustomerAddress);
        GraphQuery := CreateCustomerGraphQLQuery(ShopifyCustomer, ShopifyCustomerAddress);
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery);
        if JResponse.SelectToken('$.data.customerCreate.customer', JItem) then
            if JItem.IsObject then
                ShopifyCustomer.Id := CommunicationMgt.GetIdOfGId(JHelper.GetValueAsText(JItem, 'id'));
        if (ShopifyCustomer.Id > 0) and JResponse.SelectToken('$.data.customerCreate.customer.addresses', JItem) then
            if JItem.IsArray and (JItem.AsArray().Count = 1) then begin
                JItem.AsArray().Get(0, JItem);
                ShopifyCustomerAddress.Id := CommunicationMgt.GetIdOfGId(JHelper.GetValueAsText(JItem, 'id'));
                ShopifyCustomerAddress.CustomerId := ShopifyCustomer.Id;
#pragma warning disable AA0139
                ShopifyCustomerAddress.CountryName := JHelper.GetValueAsText(JItem, 'country');
                ShopifyCustomerAddress.ProvinceName := JHelper.GetValueAsText(JItem, 'province');
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
            if JHelper.GetJsonArray(JResponse, JCustomers, 'data.customers.edges') then
                foreach JItem in JCustomers do
                    if JHelper.GetJsonObject(JItem.AsObject(), JCustomer, 'node') then
                        exit(CommunicationMgt.GetIdOfGId(JHelper.GetValueAsText(JCustomer, 'id')));
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
            if JHelper.GetJsonArray(JResponse, JCustomers, 'data.customers.edges') then begin
                JCustomers.Get(1, JItem);
                if JHelper.GetJsonObject(JItem.AsObject(), JCustomer, 'node') then
                    exit(CommunicationMgt.GetIdOfGId(JHelper.GetValueAsText(JCustomer, 'id')));
            end;
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
        if JHelper.GetJsonObject(JResponse, JCustomer, 'data.customer') then
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
        Paramaters: Dictionary of [Text, Text];
        LastSync: DateTime;
    begin
        GraphQLType := GraphQLType::GetCustomerIds;
        LastSync := Shop.GetLastSyncTime("Shpfy Synchronization Type"::Customers);
        if LastSync > 0DT then
            Paramaters.Add('LastSync', Format(LastSync, 0, 9))
        else
            Paramaters.Add('LastSync', '');
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Paramaters);
            if JHelper.GetJsonArray(JResponse, JCustomers, 'data.customers.edges') then begin
                foreach JItem in JCustomers do begin
                    Cursor := JHelper.GetValueAsText(JItem.AsObject(), 'cursor');
                    if JHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                        Id := CommunicationMgt.GetIdOfGId(JHelper.GetValueAsText(JNode, 'id'));
                        UpdatedAt := JHelper.GetValueAsDateTime(JNode, 'updatedAt');
                        CustomerIds.Add(Id, UpdatedAt);
                    end;
                end;
                if Paramaters.ContainsKey('After') then
                    Paramaters.Set('After', Cursor)
                else
                    Paramaters.Add('After', Cursor);
                GraphQLType := GraphQLType::GetNextCustomerIds;
            end;
        until not JHelper.GetValueAsBoolean(JResponse, 'data.customers.pageInfo.hasNextPage');
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
                    if ShopifyCustomer.Id <> CommunicationMgt.GetIdOfGId(JHelper.GetValueAsText(JItem, 'id')) then
                        Error(UpdateCustIdErr);
                    ShopifyCustomer."Accepts Marketing" := JHelper.GetValueAsBoolean(JItem, 'acceptsMarketing');
                    ShopifyCustomer."Accepts Marketing Update At" := JHelper.GetValueAsDateTime(JItem, 'acceptsMArketingUpdatedAt');
                    ShopifyCustomer."Tax Exempt" := JHelper.GetValueAsBoolean(JItem, 'taxtExempt');
                    ShopifyCustomer."Updated At" := JHelper.GetValueAsDateTime(JItem, 'updatedAt');
                    ShopifyCustomer."Verified Email" := JHelper.GetValueAsBoolean(JItem, 'verifiedEmail');
                end;
            if JResponse.SelectToken('$.data.customerCreate.customer', JItem) then
                if JItem.IsObject then
                    ShopifyCustomer.Id := CommunicationMgt.GetIdOfGId(JHelper.GetValueAsText(JItem, 'id'));

            if (ShopifyCustomer.Id > 0) and JResponse.SelectToken('$.data.customerCreate.customer.defaultAddress', JItem) then
                if JItem.IsObject then begin
                    if (ShopifyCustomerAddress.Id <> CommunicationMgt.GetIdOfGId(JHelper.GetValueAsText(JItem, 'id'))) then
                        Error(UpdateAddrIdErr);
                    ShopifyCustomerAddress.CustomerId := ShopifyCustomer.Id;
#pragma warning disable AA0139
                    ShopifyCustomerAddress.CountryName := JHelper.GetValueAsText(JItem, 'country', MaxStrLen(ShopifyCustomerAddress.CountryName));
                    ShopifyCustomerAddress.ProvinceName := JHelper.GetValueAsText(JItem, 'province', MaxStrLen(ShopifyCustomerAddress.ProvinceName));
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
    begin
        xShopifyCustomer.Get(ShopifyCustomer.Id);
        xShopifyCustomerAddress.Get(ShopifyCustomerAddress.Id);
        Events.OnBeforeSendUpdateShopifyCustomer(Shop, ShopifyCustomer, ShopifyCustomerAddress, xShopifyCustomer, xShopifyCustomerAddress);
        GraphQuery.Append('{"query":"mutation {customerUpdate(input: {');
        AddFieldToGraphQuery(GraphQuery, 'id', ShopifyCustomer.Id);
        if ShopifyCustomer."E-Mail" <> xShopifyCustomer."E-Mail" then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'email', ShopifyCustomer."E-Mail");
        if ShopifyCustomer.FirstName <> xShopifyCustomer.FirstName then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'firstName', ShopifyCustomer.FirstName);
        if ShopifyCustomer.LastName <> xShopifyCustomer.LastName then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'lastName', ShopifyCustomer.LastName);
        if ShopifyCustomer."Phone No." <> xShopifyCustomer."Phone No." then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'phone', ShopifyCustomer."Phone No.");
        if ShopifyCustomer.GetNote() <> xShopifyCustomer.GetNote() then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'note', CommunicationMgt.EscapeGrapQLData(ShopifyCustomer.GetNote()));

        GraphQuery.Append('addresses: {');

        AddFieldToGraphQuery(GraphQuery, 'id', ShopifyCustomerAddress.Id);
        if ShopifyCustomerAddress.Company <> '' then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'company', ShopifyCustomerAddress.Company);
        if ShopifyCustomerAddress.FirstName <> xShopifyCustomer.FirstName then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'firstName', ShopifyCustomerAddress.FirstName);
        if ShopifyCustomerAddress.LastName <> xShopifyCustomer.LastName then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'lastName', ShopifyCustomerAddress.LastName);
        if ShopifyCustomerAddress.Address1 <> '' then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'address1', CommunicationMgt.EscapeGrapQLData(ShopifyCustomerAddress.Address1));
        if ShopifyCustomerAddress.Address2 <> '' then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'address2', CommunicationMgt.EscapeGrapQLData(ShopifyCustomerAddress.Address2));
        if ShopifyCustomerAddress.Zip <> '' then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'zip', ShopifyCustomerAddress.Zip);
        if ShopifyCustomerAddress.City <> '' then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'city', CommunicationMgt.EscapeGrapQLData(ShopifyCustomerAddress.City));
        if ShopifyCustomerAddress.ProvinceCode <> '' then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'provinceCode', ShopifyCustomerAddress.ProvinceCode);
        if ShopifyCustomerAddress.CountryCode <> '' then
            HasChange := GraphQuery.Append('countryCode: ' + ShopifyCustomerAddress.CountryCode + ', ');
        if ShopifyCustomerAddress.Phone <> '' then
            HasChange := AddFieldToGraphQuery(GraphQuery, 'phone', ShopifyCustomerAddress.Phone);


        if HasChange then begin
            GraphQuery.Remove(GraphQuery.Length - 1, 2);
            GraphQuery.Append('}}) {customer {id, acceptsMarketing, acceptsMarketingUpdatedAt, tags, updatedAt, veriefiedEmail, defaultAddress {id, province, country}}, userErrors {field, message}}}"}');
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
        ShopifyAddress: Record "Shpfy Customer Address";
        TempTag: Record "Shpfy Tag" temporary;
        NodeId: BigInteger;
        UpdatedAt: DateTime;
        JAddresses: JsonArray;
        JMetafields: JsonArray;
        JTags: JsonArray;
        JAddress: JsonObject;
        JNode: JsonObject;
        JItem: JsonToken;
        Ids: List of [BigInteger];
        OutStream: OutStream;
        StateString: Text;
        FilterString: TextBuilder;
        PhoneNo: Text;
    begin
        UpdatedAt := JHelper.GetValueAsDateTime(JCustomer, 'updatedAt');
        if UpdatedAt <= ShopifyCustomer."Updated At" then
            exit(false);
        Result := true;

        ShopifyCustomer."Updated At" := UpdatedAt;
        ShopifyCustomer."Created At" := JHelper.GetValueAsDateTime(JCustomer, 'createdAt');
#pragma warning disable AA0139
        ShopifyCustomer.FirstName := JHelper.GetValueAsText(JCustomer, 'firstName', MaxStrLen(ShopifyCustomer.FirstName));
        ShopifyCustomer.LastName := JHelper.GetValueAsText(JCustomer, 'lastName', MaxStrLen(ShopifyCustomer.LastName));
        ShopifyCustomer."E-Mail" := JHelper.GetValueAsText(JCustomer, 'email', MaxStrLen(ShopifyCustomer."E-Mail"));
#pragma warning restore AA0139
        PhoneNo := JHelper.GetValueAsText(JCustomer, 'phone');
        PhoneNo := DelChr(PhoneNo, '=', DelChr(PhoneNo, '=', '1234567890/+ .()'));
        ShopifyCustomer."Phone No." := CopyStr(PhoneNo, 1, MaxStrLen(ShopifyCustomer."Phone No."));
        ShopifyCustomer."Accepts Marketing" := JHelper.GetValueAsBoolean(JCustomer, 'acceptsMarketing');
        ShopifyCustomer."Accepts Marketing Update At" := JHelper.GetValueAsDateTime(JCustomer, 'acceptsMarketingUpdateAt');
        ShopifyCustomer."Tax Exempt" := JHelper.GetValueAsBoolean(JCustomer, 'taxExempt');
        ShopifyCustomer."Verified Email" := JHelper.GetValueAsBoolean(JCustomer, 'verifiedEmail');
        StateString := JHelper.GetValueAsText(JCustomer, 'state').ToLower();
        StateString := Format(StateString[1]).ToUpper() + CopyStr(StateString, 2);
        Evaluate(ShopifyCustomer.State, StateString);
        if JHelper.GetValueAsBoolean(JCustomer, 'hasNote') then begin
            Clear(ShopifyCustomer.Note);
            ShopifyCustomer.Note.CreateOutStream(OutStream, TextEncoding::UTF8);
            OutStream.WriteText(JHelper.GetValueAsText(JCustomer, 'note'));
        end else
            Clear(ShopifyCustomer.Note);
        ShopifyCustomer."Created At" := JHelper.GetValueAsDateTime(JCustomer, 'createdAt');
        ShopifyCustomer.Modify(false);

        if JHelper.GetJsonArray(JCustomer, JTags, 'tags') then
            foreach JItem in JTags do begin
                Clear(TempTag);
                TempTag."Parent Table No." := Database::"Shpfy Customer";
                TempTag."Parent Id" := ShopifyCustomer.Id;
                TempTag.Tag := CopyStr(JItem.AsValue().AsText(), 1, MaxStrLen(TempTag.Tag));
                if TempTag.Insert(false) then;
            end;
        if JHelper.GetJsonArray(JCustomer, JAddresses, 'addresses') then begin
            Clear(Ids);
            foreach JItem in JAddresses do begin
                JAddress := JItem.AsObject();
                NodeId := CommunicationMgt.GetIdOfGId(JHelper.GetValueAsText(JAddress, 'id'));
                Ids.Add(NodeId);
                Clear(ShopifyAddress);
                ShopifyAddress.SetRange(Id, NodeId);
                if not ShopifyAddress.FindFirst() then begin
                    ShopifyAddress.Init();
                    ShopifyAddress.CustomerId := ShopifyCustomer.Id;
                    ShopifyAddress.Id := NodeId;
                    ShopifyAddress.Insert(false);
                end;
#pragma warning disable AA0139
                ShopifyAddress.Company := JHelper.GetValueAsText(JAddress, 'company', MaxStrLen(ShopifyAddress.Company));
                ShopifyAddress.FirstName := JHelper.GetValueAsText(JAddress, 'firstName', MaxStrLen(ShopifyAddress.FirstName));
                ShopifyAddress.LastName := JHelper.GetValueAsText(JAddress, 'lastName', MaxStrLen(ShopifyAddress.LastName));
                ShopifyAddress.Address1 := JHelper.GetValueAsText(JAddress, 'address1', MaxStrLen(ShopifyAddress.Address1));
                ShopifyAddress.Address2 := JHelper.GetValueAsText(JAddress, 'address2', MaxStrLen(ShopifyAddress.Address2));
                ShopifyAddress.Zip := JHelper.GetValueAsText(JAddress, 'zip', MaxStrLen(ShopifyAddress.Zip));
                ShopifyAddress.City := JHelper.GetValueAsText(JAddress, 'city', MaxStrLen(ShopifyAddress.City));
                ShopifyAddress.CountryCode := JHelper.GetValueAsText(JAddress, 'countryCodeV2');
                ShopifyAddress.CountryName := JHelper.GetValueAsText(JAddress, 'country');
                ShopifyAddress.ProvinceCode := JHelper.GetValueAsText(JAddress, 'provinceCode', MaxStrLen(ShopifyAddress.ProvinceCode));
                ShopifyAddress.ProvinceName := JHelper.GetValueAsText(JAddress, 'province', MaxStrLen(ShopifyAddress.ProvinceName));
#pragma warning restore AA0139
                PhoneNo := JHelper.GetValueAsText(JAddress, 'phone');
                PhoneNo := CopyStr(DelChr(PhoneNo, '=', DelChr(PhoneNo, '=', '1234567890/+ .()')), 1, MaxStrLen(ShopifyAddress.Phone));
                ShopifyAddress.Phone := CopyStr(PhoneNo, 1, MaxStrLen(ShopifyAddress.Phone));
                ShopifyAddress.Default := false;
                ShopifyAddress.Modify(false);
            end;
            Clear(ShopifyAddress);
            ShopifyAddress.SetRange(CustomerId, ShopifyCustomer.Id);
            Clear(FilterString);
            foreach NodeId in Ids do begin
                FilterString.Append('&<>');
                FilterString.Append(Format(NodeId));
            end;
            if FilterString.Length > 0 then begin
                FilterString.Remove(1, 1);
                ShopifyAddress.SetFilter(Id, FilterString.ToText());
                if not ShopifyAddress.IsEmpty then
                    ShopifyAddress.DeleteAll(false);
            end;

            if JHelper.GetJsonObject(JCustomer, JAddress, 'defaultAddress') then begin
                NodeId := CommunicationMgt.GetIdOfGId(JHelper.GetValueAsText(JAddress, 'id'));
                Clear(ShopifyAddress);
                ShopifyAddress.SetRange(Id, NodeId);
                if ShopifyAddress.FindFirst() then begin
                    ShopifyAddress.Default := true;
                    ShopifyAddress.Modify(false);
                end;
            end;
        end;
    end;
}