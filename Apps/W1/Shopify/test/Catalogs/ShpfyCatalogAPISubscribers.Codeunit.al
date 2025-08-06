// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;

codeunit 134241 "Shpfy Catalog API Subscribers"
{
    EventSubscriberInstance = Manual;

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
        CreateCatalogGQLStartTok: Label '{"query": "mutation { catalogCreate(input: {title: ', Locked = true;
        CreatePublicationGQLStartTok: Label '{"query": "mutation { publicationCreate(input: {autoPublish: true, catalogId:', Locked = true;
        CreatePriceListGQLStartTok: Label '{"query": "mutation { priceListCreate(input: {name: ', Locked = true;
        GraphQLCmdTxt: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLCmdTxt) then
                        if HttpRequestMessage.Content.ReadAs(GraphQlQuery) then
                            case true of
                                GraphQlQuery.StartsWith(CreateCatalogGQLStartTok):
                                    HttpResponseMessage := GetCatalogResult();
                                GraphQlQuery.StartsWith(CreatePublicationGQLStartTok):
                                    HttpResponseMessage := GetEmptyResponse();
                                GraphQlQuery.StartsWith(CreatePriceListGQLStartTok):
                                    HttpResponseMessage := GetEmptyResponse();
                            end;
                end;
        end;
    end;

    local procedure GetCatalogResult(): HttpResponseMessage
    var
        Any: Codeunit Any;
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
        CatalogResultLbl: Label '{"data": {"catalogCreate": {"catalog": {"id": %1}}}}', Comment = '%1 - catalogId', Locked = true;
    begin
        Body := StrSubstNo(CatalogResultLbl, Any.IntegerInRange(100000, 999999));
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
}