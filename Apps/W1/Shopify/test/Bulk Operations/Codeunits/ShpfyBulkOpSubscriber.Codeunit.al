// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;

codeunit 139615 "Shpfy Bulk Op. Subscriber"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    var
        UploadUrlLbl: Label 'https://shopify-staged-uploads.storage.googleapis.com', Locked = true;
        BulkOperationId: BigInteger;
        BulkOperationRunning: Boolean;
        BulkUploadFail: Boolean;
        BulkOperationUrl: Text;
        VariantId1: BigInteger;
        VariantId2: BigInteger;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Bulk Operation Mgt.", 'OnInvalidUser', '', true, false)]
    local procedure OnInvalidUser(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnClientGet', '', true, false)]
    local procedure OnClientGet(var Url: Text; var Response: HttpResponseMessage)
    begin
        if Url = BulkOperationUrl then
            Response := GetBulkOperationResult();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnClientSend', '', true, false)]
    local procedure OnClientSend(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    begin
        MakeResponse(HttpRequestMessage, HttpResponseMessage);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnClientPost', '', true, false)]
    local procedure OnClientPost(var Url: Text; var Content: HttpContent; var Response: HttpResponseMessage)
    begin
        if Url = UploadUrlLbl then
            Response := GetJsonlUploadResult();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnGetContent', '', true, false)]
    local procedure OnGetContent(HttpResponseMessage: HttpResponseMessage; var Response: Text)
    begin
        HttpResponseMessage.Content.ReadAs(Response);
    end;

    local procedure MakeResponse(HttpRequestMessage: HttpRequestMessage; var HttpResponseMessage: HttpResponseMessage)
    var
        Uri: Text;
        GraphQLQuery: Text;
        StagedUploadGQLTxt: Label '{"query": "mutation { stagedUploadsCreate(input', Locked = true;
        BulkMutationGQLTxt: Label '{"query": "mutation { bulkOperationRunMutation(mutation', Locked = true;
        CurrentBulkOperationGQLTxt: Label '{"query": "query { currentBulkOperation(type', Locked = true;
        BulkOperationGQLTxt: Label '{"query": "query { node(id: \"gid://shopify/BulkOperation/', Locked = true;
        GraphQLCmdTxt: Label '/graphql.json', Locked = true;
    begin
        case HttpRequestMessage.Method of
            'POST':
                begin
                    Uri := HttpRequestMessage.GetRequestUri();
                    if Uri.EndsWith(GraphQLCmdTxt) then
                        if HttpRequestMessage.Content.ReadAs(GraphQLQuery) then begin
                            if GraphQLQuery.StartsWith(StagedUploadGQLTxt) then
                                HttpResponseMessage := GetStagedUplodResult();
                            if GraphQLQuery.StartsWith(BulkMutationGQLTxt) then
                                HttpResponseMessage := GetBulkMutationResponse();
                            if GraphQLQuery.StartsWith(CurrentBulkOperationGQLTxt) then
                                if BulkOperationRunning then
                                    HttpResponseMessage := GetCurrentBulkOperationRunningResult()
                                else
                                    HttpResponseMessage := GetCurrentBulkOperationCompletedResult();
                            if GraphQLQuery.StartsWith(BulkOperationGQLTxt) then
                                HttpResponseMessage := GetBulkOperationCompletedResult();
                        end;
                end;
        end;
    end;

    local procedure GetStagedUplodResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
        ResInStream: InStream;
    begin
        if BulkUploadFail then begin
            NavApp.GetResource('Bulk Operations/StagedUploadFailedResult.txt', ResInStream, TextEncoding::UTF8);
            ResInStream.ReadText(Body);
        end else begin
            NavApp.GetResource('Bulk Operations/StagedUploadResult.txt', ResInStream, TextEncoding::UTF8);
            ResInStream.ReadText(Body);
            Body := StrSubstNo(Body, UploadUrlLbl)
        end;
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    local procedure GetBulkMutationResponse(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Bulk Operations/BulkMutationResponse.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        HttpResponseMessage.Content.WriteFrom(StrSubstNo(Body, Format(BulkOperationId)));
        exit(HttpResponseMessage);
    end;

    local procedure GetCurrentBulkOperationCompletedResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Bulk Operations/CurrentBulkOperationCompletedResult.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        HttpResponseMessage.Content.WriteFrom(StrSubstNo(Body, Format(BulkOperationId)));
        exit(HttpResponseMessage);
    end;

    local procedure GetCurrentBulkOperationRunningResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Bulk Operations/CurrentBulkOperationRunningResult.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        HttpResponseMessage.Content.WriteFrom(StrSubstNo(Body, Format(BulkOperationId)));
        exit(HttpResponseMessage);
    end;

    local procedure GetJsonlUploadResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
    begin
        exit(HttpResponseMessage);
    end;

    local procedure GetBulkOperationResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: TextBuilder;
        BodyLine: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Bulk Operations/BulkOperationResult.txt', ResInStream, TextEncoding::UTF8);
        while not ResInStream.EOS do begin
            ResInStream.ReadText(BodyLine);
            Body.AppendLine(StrSubstNo(BodyLine, Format(VariantId1), Format(VariantId2)));
        end;
        HttpResponseMessage.Content.WriteFrom(Body.ToText());
        exit(HttpResponseMessage);
    end;

    local procedure GetBulkOperationCompletedResult(): HttpResponseMessage
    var
        HttpResponseMessage: HttpResponseMessage;
        Body: Text;
        ResInStream: InStream;
    begin
        NavApp.GetResource('Bulk Operations/BulkOperationCompletedResult.txt', ResInStream, TextEncoding::UTF8);
        ResInStream.ReadText(Body);
        HttpResponseMessage.Content.WriteFrom(Body);
        exit(HttpResponseMessage);
    end;

    internal procedure SetBulkOperationId(Id: BigInteger)
    begin
        BulkOperationId := Id;
    end;

    internal procedure SetBulkOperationRunning(OperationRunning: Boolean)
    begin
        BulkOperationRunning := OperationRunning;
    end;

    internal procedure SetBulkUploadFail(Fail: Boolean)
    begin
        BulkUploadFail := Fail;
    end;

    internal procedure SetBulkOperationUrl(Url: Text)
    begin
        BulkOperationUrl := Url;
    end;

    internal procedure SetVariantIds(Id1: BigInteger; Id2: BigInteger)
    begin
        VariantId1 := Id1;
        VariantId2 := Id2;
    end;
}