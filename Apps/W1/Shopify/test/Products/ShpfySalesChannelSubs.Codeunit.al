codeunit 139697 "Shpfy Sales Channel Subs."
{
    EventSubscriberInstance = Manual;

    var
        GraphQueryTxt: Text;
        JEdges: JsonArray;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnClientSend', '', true, false)]
    local procedure OnClientSend(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        MakeResponse(HttpRequestMessage, HttpResponseMessage);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnGetContent', '', true, false)]
    local procedure OnGetContent(HttpResponseMessage: HttpResponseMessage; var Response: Text)
    begin
        HttpResponseMessage.Content.ReadAs(Response);
    end;

    local procedure MakeResponse(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    var
        GQLGetSalesChannels: Codeunit "Shpfy GQL Get SalesChannels";
        Uri: Text;
        GraphQlQuery: Text;
        PublishProductTok: Label '{"query":"mutation {publishablePublish(id: \"gid://shopify/Product/', locked = true;
        ProductCreateTok: Label '{"query":"mutation {productCreate(', locked = true;
        VariantUpdateTok: Label '{"query":"mutation { productVariantUpdate(', locked = true;
        InventoryActivationTok: Label '{"query":"mutation inventoryBulkToggleActivation(', locked = true;
        GraphQLCmdTxt: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLCmdTxt) then
                        if HttpRequestMessage.Content.ReadAs(GraphQlQuery) then
                            case true of
                                GraphQlQuery.Contains(PublishProductTok):
                                    begin
                                        HttpResponseMessage := GetEmptyPublishResponse();
                                        GraphQueryTxt := GraphQlQuery;
                                    end;
                                GraphQlQuery.Contains(ProductCreateTok):
                                    HttpResponseMessage := GetCreateProductResponse();
                                GraphQlQuery = GQLGetSalesChannels.GetGraphQL():
                                    HttpResponseMessage := GetSalesChannelsResponse();
                                GraphQlQuery.Contains(VariantUpdateTok):
                                    HttpResponseMessage := GetUpdateVariantResponse();
                                GraphQlQuery.Contains(InventoryActivationTok):
                                    HttpResponseMessage := GetInventoryActivateResponse();
                            end;
                end;
        end;
    end;

    local procedure GetEmptyPublishResponse(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
        BodyTxt: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Products/EmptyPublishResponse.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(BodyTxt);
        HttpResponseMessage.Content.WriteFrom(BodyTxt);
        exit(HttpResponseMessage);
    end;

    local procedure GetCreateProductResponse(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        BodyTxt: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Products/CreatedProductResponse.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(BodyTxt);
        HttpResponseMessage.Content.WriteFrom(BodyTxt);
        exit(HttpResponseMessage);
    end;

    local procedure GetUpdateVariantResponse(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        BodyTxt: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Products/UpdatedVariantResponse.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(BodyTxt);
        HttpResponseMessage.Content.WriteFrom(BodyTxt);
        exit(HttpResponseMessage);
    end;

    local procedure GetInventoryActivateResponse(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
    begin
        HttpResponseMessage.Content.WriteFrom('{}');
        exit(HttpResponseMessage);
    end;

    local procedure GetSalesChannelsResponse(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        BodyTxt: Text;
        EdgesTxt: Text;
    begin
        JEdges.WriteTo(EdgesTxt);
        BodyTxt := StrSubstNo('{ "data": { "publications": { "edges": %1 } }}', EdgesTxt);
        HttpResponseMessage.Content.WriteFrom(BodyTxt);
        exit(HttpResponseMessage);
    end;

    internal procedure GetGraphQueryTxt(): Text
    begin
        exit(GraphQueryTxt);
    end;

    internal procedure SetJEdges(NewJEdges: JsonArray)
    begin
        this.JEdges := NewJEdges;
    end;
}