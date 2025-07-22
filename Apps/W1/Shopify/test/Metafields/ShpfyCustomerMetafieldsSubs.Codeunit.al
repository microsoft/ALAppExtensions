// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;

codeunit 139547 "Shpfy Customer Metafields Subs"
{
    EventSubscriberInstance = Manual;

    var
        ShopifyCustomerId: BigInteger;
        GQLQueryTxt: Text;

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Customer Events", OnBeforeFindMapping, '', true, false)]
    local procedure OnBeforeFindMapping(var Handled: Boolean; var ShopifyCustomer: Record "Shpfy Customer")
    begin
        ShopifyCustomer.Id := ShopifyCustomerId;
        Handled := true;
    end;

    local procedure MakeResponse(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    var
        Uri: Text;
        GraphQlQuery: Text;
        GetCustomersGQLMsg: Label '{"query":"{customers(first:100){pageInfo{endCursor hasNextPage} nodes{ legacyResourceId }}}"}', Locked = true;
        ModifyCustomerGQLStartTok: Label '{"query":"mutation {customerUpdate(input: {id: \"gid://shopify/Customer/', Locked = true;
        GetCustomerMetafieldsGQLStartTok: Label '{"query":"{customer(id: \"gid://shopify/Customer/', Locked = true;
        GetCustomerMetafieldsGQLEndTok: Label '\") { metafields(first: 50) {edges {node {legacyResourceId updatedAt}}}}}"}', Locked = true;
        CreateMetafieldsGQLStartTok: Label '{"query": "mutation { metafieldsSet(metafields: ', Locked = true;
        GraphQLCmdTxt: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLCmdTxt) then
                        if HttpRequestMessage.Content.ReadAs(GraphQlQuery) then
                            case true of
                                GraphQlQuery.Contains(GetCustomersGQLMsg):
                                    HttpResponseMessage := GetCustomersResult();
                                GraphQlQuery.StartsWith(ModifyCustomerGQLStartTok):
                                    HttpResponseMessage := GetEmptyResponse();
                                GraphQlQuery.StartsWith(GetCustomerMetafieldsGQLStartTok) and GraphQlQuery.EndsWith(GetCustomerMetafieldsGQLEndTok):
                                    HttpResponseMessage := GetEmptyResponse();
                                GraphQlQuery.StartsWith(CreateMetafieldsGQLStartTok):
                                    begin
                                        HttpResponseMessage := GetEmptyResponse();
                                        GQLQueryTxt := GraphQlQuery;
                                    end;
                            end;
                end;
        end;
    end;

    local procedure GetCustomersResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Metafields/CustomersResult.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetEmptyResponse(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := '{}';
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    internal procedure SetShopifyCustomerId(Id: BigInteger)
    begin
        ShopifyCustomerId := Id;
    end;

    internal procedure GetGQLQuery(): Text
    begin
        exit(GQLQueryTxt);
    end;

}