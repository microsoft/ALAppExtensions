namespace Microsoft.Integration.Shopify;

codeunit 30335 "Shpfy Metafield Owner Variant" implements "Shpfy IMetafield Owner Type"
{
    procedure GetTableId(): Integer
    begin
        exit(Database::"Shpfy Variant");
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
        Parameters.Add('VariantId', Format(OwnerId));
        GraphQLType := GraphQLType::VariantMetafieldIds;
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
        Variant: Record "Shpfy Variant";
    begin
        Variant.Get(OwnerId);
        exit(Variant."Shop Code");
    end;
}