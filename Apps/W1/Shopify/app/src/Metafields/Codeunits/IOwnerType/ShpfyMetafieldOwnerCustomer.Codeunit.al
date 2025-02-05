namespace Microsoft.Integration.Shopify;

codeunit 30333 "Shpfy Metafield Owner Customer" implements "Shpfy IMetafield Owner Type"
{
    procedure GetTableId(): Integer
    begin
        exit(Database::"Shpfy Customer");
    end;

    procedure RetrieveMetafieldIdsFromShopify(OwnerId: BigInteger) MetafieldIds: Dictionary of [BigInteger, DateTime]
    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        JResponse: JsonToken;
        JMetafields: JsonArray;
        JNode: JsonObject;
        JCustomer: JsonObject;
        JItem: JsonToken;
        Id: BigInteger;
        UpdatedAt: DateTime;
    begin
        Parameters.Add('CustomerId', Format(OwnerId));
        GraphQLType := GraphQLType::CustomerMetafieldIds;
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        if JsonHelper.GetJsonObject(JResponse, JCustomer, 'data.customer') then
            if JsonHelper.GetJsonArray(JResponse, JMetafields, 'data.customer.metafields.edges') then
                foreach JItem in JMetafields do
                    if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                        Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'legacyResourceId'));
                        UpdatedAt := JsonHelper.GetValueAsDateTime(JNode, 'updatedAt');
                        MetafieldIds.Add(Id, UpdatedAt);
                    end;
    end;

    procedure GetShopCode(OwnerId: BigInteger): Code[20]
    var
        Customer: Record "Shpfy Customer";
        Shop: Record "Shpfy Shop";
    begin
        Customer.Get(OwnerId);
        Shop.SetRange("Shop Id", Customer."Shop Id");
        Shop.FindFirst();
        exit(Shop.Code);
    end;

    procedure CanEditMetafields(Shop: Record "Shpfy Shop"): Boolean
    begin
        exit((Shop."Can Update Shopify Customer") and (Shop."Customer Import From Shopify" <> Enum::"Shpfy Customer Import Range"::AllCustomers));
    end;
}