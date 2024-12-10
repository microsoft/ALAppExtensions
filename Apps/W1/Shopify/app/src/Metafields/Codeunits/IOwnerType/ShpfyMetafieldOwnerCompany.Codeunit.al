namespace Microsoft.Integration.Shopify;

codeunit 30366 "Shpfy Metafield Owner Company" implements "Shpfy IMetafield Owner Type"
{

    procedure GetTableId(): Integer
    begin
        exit(Database::"Shpfy Company");
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
        JCompany: JsonObject;
        JItem: JsonToken;
        Id: BigInteger;
        UpdatedAt: DateTime;
    begin
        Parameters.Add('CompanyId', Format(OwnerId));
        GraphQLType := GraphQLType::CompanyMetafieldIds;
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        if JsonHelper.GetJsonObject(JResponse, JCompany, 'data.company') then
            if JsonHelper.GetJsonArray(JResponse, JMetafields, 'data.company.metafields.edges') then
                foreach JItem in JMetafields do
                    if JsonHelper.GetJsonObject(JItem.AsObject(), JNode, 'node') then begin
                        Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JNode, 'legacyResourceId'));
                        UpdatedAt := JsonHelper.GetValueAsDateTime(JNode, 'updatedAt');
                        MetafieldIds.Add(Id, UpdatedAt);
                    end;
    end;

    procedure GetShopCode(OwnerId: BigInteger): Code[20]
    var
        Company: Record "Shpfy Company";
    begin
        Company.Get(OwnerId);
        exit(Company."Shop Code");
    end;

    procedure CanEditMetafields(Shop: Record "Shpfy Shop"): Boolean
    begin
        exit((Shop."Can Update Shopify Companies") and (Shop."Company Import From Shopify" <> Enum::"Shpfy Company Import Range"::AllCompanies));
    end;

}
