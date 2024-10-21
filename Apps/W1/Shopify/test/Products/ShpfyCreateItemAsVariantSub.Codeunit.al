codeunit 139583 "Shpfy CreateItemAsVariantSub"
{
    EventSubscriberInstance = Manual;

    var
        GraphQueryTxt: Text;
        NewVariantId: BigInteger;

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
        Uri: Text;
        GraphQlQuery: Text;
        CreateItemVariantTok: Label '{"query":"mutation { productVariantCreate(input: {productId: \"gid://shopify/Product/', locked = true;
        GetOptionsStartTok: Label '{"query":"{product(id: \"gid://shopify/Product/', locked = true;
        GetOptionsEndTok: Label '\") {id title options {id name}}}"}', Locked = true;
        RemoveVariantStartTok: Label '{"query":"mutation {productVariantDelete(id: \"gid://shopify/ProductVariant/', Locked = true;
        RemoveVariantEndTok: Label '\") {deletedProductVariantId userErrors{field message}}}"}', Locked = true;
        GraphQLCmdTxt: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLCmdTxt) then
                        if HttpRequestMessage.Content.ReadAs(GraphQlQuery) then
                            case true of
                                GraphQlQuery.StartsWith(CreateItemVariantTok):
                                    HttpResponseMessage := GetCreatedVariantResponse();
                                GraphQlQuery.StartsWith(GetOptionsStartTok) and GraphQlQuery.EndsWith(GetOptionsEndTok):
                                    HttpResponseMessage := GetProductOptionsResponse();
                                GraphQlQuery.StartsWith(RemoveVariantStartTok) and GraphQlQuery.EndsWith(RemoveVariantEndTok):
                                    begin
                                        HttpResponseMessage := GetRemoveVariantResponse();
                                        GraphQueryTxt := GraphQlQuery;
                                    end;
                            end;
                end;
        end;
    end;

    local procedure GetCreatedVariantResponse(): HttpResponseMessage;
    var
        Any: Codeunit Any;
        HttpResponseMessage: HttpResponseMessage;
        BodyTxt: Text;
    begin
        NewVariantId := Any.IntegerInRange(100000, 999999);
        BodyTxt := StrSubstNo('{ "data": { "productVariantCreate": { "legacyResourceId": %1 } } }', NewVariantId);
        HttpResponseMessage.Content.WriteFrom(BodyTxt);
        exit(HttpResponseMessage);
    end;

    local procedure GetProductOptionsResponse(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        BodyTxt: Text;
    begin
        BodyTxt := '{"data": {"product": {"id": "gid://shopify/Product/123456", "title": "Product 1", "options": [{"id": "gid://shopify/ProductOption/1", "name": "Option 1"}]}}}';
        HttpResponseMessage.Content.WriteFrom(BodyTxt);
        exit(HttpResponseMessage);
    end;

    local procedure GetRemoveVariantResponse(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        BodyTxt: Text;
    begin
        BodyTxt := '{}';
        HttpResponseMessage.Content.WriteFrom(BodyTxt);
        exit(HttpResponseMessage);
    end;

    procedure GetNewVariantId(): BigInteger
    begin
        exit(NewVariantId);
    end;

    procedure GetGraphQueryTxt(): Text
    begin
        exit(GraphQueryTxt);
    end;
}