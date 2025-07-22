// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Location Subcriber (ID 139587).
/// </summary>
codeunit 139587 "Shpfy Location Subcriber"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    var
        JLocations: JsonObject;

    internal procedure InitShopifyLocations(Locations: JsonObject)
    begin
        JLocations := Locations;
    end;


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
        GraphQLCmdMsg: Label '{"query":"{ locations(first: 20, includeLegacy: true) { pageInfo { hasNextPage endCursor } nodes { legacyResourceId isActive isPrimary name fulfillmentService { serviceName }}}}"}', Locked = true;
        GraphQLCmdTxt: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLCmdTxt) then
                        if HttpRequestMessage.Content.ReadAs(GraphQlQuery) then
                            if GraphQlQuery = GraphQLCmdMsg then
                                HttpResponseMessage := GetLocationResult();
                end;
        end;
    end;

    local procedure GetLocationResult(): HttpResponseMessage;
    var
        HttpResponseMessage: HttpResponseMessage;
    begin
        HttpResponseMessage.Content.WriteFrom(Format(JLocations));
        exit(HttpResponseMessage);
    end;

}