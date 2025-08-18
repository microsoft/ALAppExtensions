// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;

codeunit 134243 "Shpfy Company Import Subs."
{
    EventSubscriberInstance = Manual;

    var
        LocationValues: Dictionary of [Text, Text];
        CompanyImportExecuted: Boolean;

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
        GetCompanyGQLStartTok: Label '{"query":"{company(id: \"gid://shopify/Company/', Locked = true;
        GetCompanyGQLEndTok: Label '\") {name id externalId note createdAt updatedAt mainContact { id customer { id firstName lastName defaultPhoneNumber { phoneNumber } defaultEmailAddress { emailAddress }}} metafields(first: 50) {edges {node {id namespace ownerType legacyResourceId key value type}}}}}"}', Locked = true;
        GetLocationsStartTok: Label '{"query": "{companyLocations(first:20, query: \"company_id:', Locked = true;
        GraphQLCmdTxt: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLCmdTxt) then
                        if HttpRequestMessage.Content.ReadAs(GraphQlQuery) then
                            case true of
                                GraphQlQuery.StartsWith(GetCompanyGQLStartTok) and GraphQlQuery.EndsWith(GetCompanyGQLEndTok):
                                    HttpResponseMessage := GetCompanyResponse();
                                GraphQlQuery.StartsWith(GetLocationsStartTok):
                                    HttpResponseMessage := GetLocationsResponse();
                            end;
                end;
        end;
    end;

    local procedure GetCompanyResponse(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
        ResponseLbl: Label '{ "data": { "company" :{ "mainContact" : {}, "updatedAt" : "%1" } }}', Comment = '%1 - updatedAt', Locked = true;
    begin
        Body := StrSubstNo(ResponseLbl, Format(CurrentDateTime, 0, 9));
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetLocationsResponse(): HttpResponseMessage
    var
        CompanyInitialize: Codeunit "Shpfy Company Initialize";
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
    begin
        Body := CompanyInitialize.CreateLocationResponse(LocationValues);
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    internal procedure GetCompanyImportExecuted(): Boolean
    begin
        exit(CompanyImportExecuted);
    end;

    internal procedure SetLocationValues(NewLocationValues: Dictionary of [Text, Text])
    begin
        LocationValues := NewLocationValues;
    end;

}