// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139761 "Outlook Mock Init. Subscribers"
{
    EventSubscriberInstance = Manual;

    var
        OAuthClientMock: Codeunit "OAuth Client Mock";
        OutlookAPIClientMock: Codeunit "Outlook API Client Mock";
#if not CLEAN24
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Email - Outlook API Helper", 'OnAfterInitializeClients', '', false, false)]
    local procedure OnAfterInitializeClients(var OutlookAPIClient: interface "Email - Outlook API Client"; var OAuthClient: interface "Email - OAuth Client")
    begin
        OutlookAPIClient := OutlookAPIClientMock;
        OAuthClient := OAuthClientMock;
    end;
#endif

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Email - Outlook API Helper", 'OnAfterInitializeClientsV2', '', false, false)]
    local procedure OnAfterInitializeClientsV2(var OutlookAPIClient: interface "Email - Outlook API Client v2"; var OAuthClient: interface "Email - OAuth Client v2")
    begin
        OutlookAPIClient := OutlookAPIClientMock;
        OAuthClient := OAuthClientMock;
    end;
}

