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


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Email - Outlook API Helper", 'OnAfterInitializeClients', '', false, false)]
    local procedure OnAfterInitializeClients(var OutlookAPIClient: interface "Email - Outlook API Client"; var OAuthClient: interface "Email - OAuth Client")
    begin
        OutlookAPIClient := OutlookAPIClientMock;
        OAuthClient := OAuthClientMock;
    end;
}

