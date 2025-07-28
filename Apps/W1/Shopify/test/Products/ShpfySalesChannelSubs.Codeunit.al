// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;

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
        VariantCreateTok: Label '{"query":"mutation { productVariantsBulkCreate(', locked = true;
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
                                GraphQlQuery.Contains(VariantCreateTok):
                                    HttpResponseMessage := GetCreatedVariantResponse();
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

    local procedure GetCreatedVariantResponse(): HttpResponseMessage;
    var
        Any: Codeunit Any;
        NewVariantId: BigInteger;
        HttpResponseMessage: HttpResponseMessage;
        BodyTxt: Text;
        ResInStream: InStream;
    begin
        Any.SetDefaultSeed();
        NewVariantId := Any.IntegerInRange(100000, 999999);
        NavApp.GetResource('Products/CreatedVariantResponse.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(BodyTxt);
        HttpResponseMessage.Content.WriteFrom(StrSubstNo(BodyTxt, NewVariantId));
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
        ResponseLbl: Label '{ "data": { "publications": { "edges": %1 } }}', Comment = '%1 - edges', Locked = true;
    begin
        JEdges.WriteTo(EdgesTxt);
        BodyTxt := StrSubstNo(ResponseLbl, EdgesTxt);
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