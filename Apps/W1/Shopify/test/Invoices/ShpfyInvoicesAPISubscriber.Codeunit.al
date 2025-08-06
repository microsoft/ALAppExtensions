// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;

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
        FulfillmentCreateGraphQLTok: Label '{"query": "mutation { fulfillmentCreate ( fulfillment: { lineItemsByFulfillmentOrder:', Locked = true;
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
        ResInStream: InStream;
    begin
        NavApp.GetResource('Invoices/DraftOrderCreationResult.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetEmptyDraftOrderCreationResult(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Invoices/DraftOrderEmptyResult.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetDraftOrderCompleteResult(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Invoices/DraftOrderCompleteResult.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        HttpResponseMessage.Content.WriteFrom(StrSubstNo(Body, ShopifyOrderId, ShopifyOrderNo));
        exit(HttpResponseMessage);
    end;

    local procedure GetFulfillmentOrderResult(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Invoices/FulfillmentOrderResult.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetFulfillmentCreateResult(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Invoices/FulfillmentCreateResult.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
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