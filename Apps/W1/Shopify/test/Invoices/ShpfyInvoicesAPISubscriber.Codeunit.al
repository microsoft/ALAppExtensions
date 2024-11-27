codeunit 139558 "Shpfy Invoices API Subscriber"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    var
        FullDraftOrder: Boolean;
        ShopifyOrderId: BigInteger;
        ShopifyOrderNo: Code[50];

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
        DraftOrderCreateGraphQLTok: Label '{"query":"mutation {draftOrderCreate(input: {', Locked = true;
        DraftOrderCompleteGraphQLTok: Label '{ draftOrder { order { legacyResourceId, name }} userErrors { field, message }}}"}', Locked = true;
        FulfillmentOrderGraphQLTok: Label '{ fulfillmentOrders ( first:', Locked = true;
        FulfillmentCreateGraphQLTok: Label '{"query": "mutation { fulfillmentCreateV2 ( fulfillment: { lineItemsByFulfillmentOrder:', Locked = true;
        GraphQLQuerryTok: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLQuerryTok) then
                        if HttpRequestMessage.Content.ReadAs(GraphQlQuery) then
                            case true of
                                GraphQlQuery.Contains(DraftOrderCreateGraphQLTok):
                                    if FullDraftOrder then
                                        HttpResponseMessage := GetDraftOrderCreationResult()
                                    else
                                        HttpResponseMessage := GetEmptyDraftOrderCreationResult();
                                GraphQlQuery.Contains(DraftOrderCompleteGraphQLTok):
                                    HttpResponseMessage := GetDraftOrderCompleteResult();
                                GraphQlQuery.Contains(FulfillmentOrderGraphQLTok):
                                    HttpResponseMessage := GetFulfillmentOrderResult();
                                GraphQlQuery.Contains(FulfillmentCreateGraphQLTok):
                                    HttpResponseMessage := GetFulfillmentCreateResult();
                            end;
                end;
        end;
    end;

    local procedure GetDraftOrderCreationResult(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := '{"data":{"draftOrderCreate":{"draftOrder":{"id":"gid://shopify/DraftOrder/981388394558","legacyResourceId":"981388394558"},"userErrors":[]}},"extensions":{"cost":{"requestedQueryCost":10,"actualQueryCost":10,"throttleStatus":{"maximumAvailable":2000.0,"currentlyAvailable":1990,"restoreRate":100.0}}}}';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetEmptyDraftOrderCreationResult(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := '{"data":{"draftOrderCreate":{"draftOrder":{"id":"gid://shopify/DraftOrder/981388394558","legacyResourceId":"0"},"userErrors":[]}},"extensions":{"cost":{"requestedQueryCost":10,"actualQueryCost":10,"throttleStatus":{"maximumAvailable":2000.0,"currentlyAvailable":1990,"restoreRate":100.0}}}}';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetDraftOrderCompleteResult(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := StrSubstNo('{"data":{"draftOrderComplete":{"draftOrder":{"order":{"legacyResourceId":"%1","name":"%2"}},"userErrors":[]}},"extensions":{"cost":{"requestedQueryCost":11,"actualQueryCost":11,"throttleStatus":{"maximumAvailable":2000.0,"currentlyAvailable":1989,"restoreRate":100.0}}}}', ShopifyOrderId, ShopifyOrderNo);
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetFulfillmentOrderResult(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := '{"data":{"order":{"fulfillmentOrders":{"nodes":[{"id":"gid://shopify/FulfillmentOrder/7478691168318"}]}}},"extensions":{"cost":{"requestedQueryCost":7,"actualQueryCost":4,"throttleStatus":{"maximumAvailable":2000.0,"currentlyAvailable":1996,"restoreRate":100.0}}}}';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetFulfillmentCreateResult(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := '{"data":{"fulfillmentCreateV2":{"fulfillment":{"id":"gid://shopify/Fulfillment/5936298623038","status":"SUCCESS"},"userErrors":[]}},"extensions":{"cost":{"requestedQueryCost":10,"actualQueryCost":10,"throttleStatus":{"maximumAvailable":2000.0,"currentlyAvailable":1990,"restoreRate":100.0}}}}';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    internal procedure SetFullDraftOrder(IsFull: Boolean)
    begin
        this.FullDraftOrder := IsFull;
    end;

    procedure SetShopifyOrderId(OrderId: BigInteger)
    begin
        this.ShopifyOrderId := OrderId;
    end;

    procedure SetShopifyOrderNo(OrderNo: Code[50])
    begin
        this.ShopifyOrderNo := OrderNo;
    end;
}
