namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Sales Channel API (ID 30215).
/// </summary>
codeunit 30215 "Shpfy Sales Channel API"
{
    Access = Internal;

    internal procedure RetreiveSalesChannelsFromShopify(ShopCode: Code[20])
    var
        SalesChannel: Record "Shpfy Sales Channel";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        GraphQLType: Enum "Shpfy GraphQL Type";
        JResponse: JsonToken;
        JPublications: JsonArray;
        JPublication: JsonToken;
        ChannelId: BigInteger;
    begin
        CommunicationMgt.SetShop(ShopCode);
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType::GetSalesChannels);
        if JsonHelper.GetJsonArray(JResponse, JPublications, 'data.publications.nodes') then
            foreach JPublication in JPublications do begin
                ChannelId := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JPublication, 'id'));
                if not SalesChannel.Get(ChannelId) then begin
                    SalesChannel.Init();
                    SalesChannel.Id := ChannelId;
                    SalesChannel.Name := JsonHelper.GetValueAsText(JPublication, 'name');
                    SalesChannel."Shop Code" := ShopCode;
                    SalesChannel.Insert(true);
                end;
            end;
    end;
}
