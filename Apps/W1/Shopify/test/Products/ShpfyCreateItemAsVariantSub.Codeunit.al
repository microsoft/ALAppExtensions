// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;

codeunit 139627 "Shpfy CreateItemAsVariantSub"
{
    EventSubscriberInstance = Manual;

    var
        GraphQueryTxt: Text;
        NewVariantId: BigInteger;
        DefaultVariantId: BigInteger;
        MultipleOptions: Boolean;
        OptionName: Text;

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
        CreateItemVariantTok: Label '{"query":"mutation { productVariantsBulkCreate(productId: \"gid://shopify/Product/', locked = true;
        GetOptionsStartTok: Label '{"query":"{product(id: \"gid://shopify/Product/', locked = true;
        GetOptionsEndTok: Label '\") {id title options {id name}}}"}', Locked = true;
        GetVariantsTok: Label 'variants(first:200){pageInfo{hasNextPage} edges{cursor node{legacyResourceId updatedAt}}}', Locked = true;
        ProductOptionUpdateStartTok: Label '{"query": "mutation { productOptionUpdate(productId:', locked = true;
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
                                    if MultipleOptions then
                                        HttpResponseMessage := GetProductMultipleOptionsResponse()
                                    else
                                        HttpResponseMessage := GetProductOptionsResponse();
                                GraphQlQuery.Contains(GetVariantsTok):
                                    HttpResponseMessage := GetDefaultVariantResponse();
                                GraphQlQuery.StartsWith(ProductOptionUpdateStartTok):
                                    HttpResponseMessage := GetUpdateVariantResponse();
                            end;
                end;
        end;
    end;

    local procedure GetCreatedVariantResponse(): HttpResponseMessage;
    var
        Any: Codeunit Any;
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

    local procedure GetProductOptionsResponse(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        BodyTxt: Text;
        ResInStream: InStream;
    begin
        if OptionName = '' then
            OptionName := 'Title';

        NavApp.GetResource('Products/ProductOptionsResponse.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(BodyTxt);
        HttpResponseMessage.Content.WriteFrom(StrSubstNo(BodyTxt, OptionName));
        exit(HttpResponseMessage);
    end;

    local procedure GetProductMultipleOptionsResponse(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        BodyTxt: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Products/ProductMultipleOptionsResponse.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(BodyTxt);
        HttpResponseMessage.Content.WriteFrom(BodyTxt);
        exit(HttpResponseMessage);
    end;

    local procedure GetDefaultVariantResponse(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        BodyTxt: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Products/DefaultVariantResponse.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(BodyTxt);
        HttpResponseMessage.Content.WriteFrom(StrSubstNo(BodyTxt, DefaultVariantId));
        exit(HttpResponseMessage);
    end;

    local procedure GetUpdateVariantResponse(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := '{}';
        HttpResponseMessage.Content.WriteFrom(Body);
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

    procedure SetMultipleOptions(NewMultipleOptions: Boolean)
    begin
        MultipleOptions := NewMultipleOptions;
    end;

    procedure SetDefaultVariantId(NewDefaultVariantId: BigInteger)
    begin
        DefaultVariantId := NewDefaultVariantId;
    end;

    procedure SetNonDefaultOption(NewOptionName: Text)
    begin
        OptionName := NewOptionName;
    end;
}