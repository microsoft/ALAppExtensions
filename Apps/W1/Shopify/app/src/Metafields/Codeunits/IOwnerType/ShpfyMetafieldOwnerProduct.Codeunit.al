namespace Microsoft.Integration.Shopify;

codeunit 30334 "Shpfy Metafield Owner Product" implements "Shpfy IMetafield Owner Type"
{
    procedure GetTableId(): Integer
    begin
        exit(Database::"Shpfy Product");
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
        JItem: JsonToken;
        Id: BigInteger;
        UpdatedAt: DateTime;
    begin
        Parameters.Add('ProductId', Format(OwnerId));
        GraphQLType := GraphQLType::ProductMetafieldIds;
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        if JsonHelper.GetJsonArray(JResponse, JMetafields, 'data.product.metafields.edges') then
            foreach JItem in JMetafields do
                if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                    Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'legacyResourceId'));
                    UpdatedAt := JsonHelper.GetValueAsDateTime(JNode, 'updatedAt');
                    MetafieldIds.Add(Id, UpdatedAt);
                end;
    end;

    procedure GetShopCode(OwnerId: BigInteger): Code[20]
    var
        Product: Record "Shpfy Product";
    begin
        Product.Get(OwnerId);
        exit(Product."Shop Code");
    end;
}