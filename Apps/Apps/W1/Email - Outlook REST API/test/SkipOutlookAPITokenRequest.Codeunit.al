// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139774 "Skip Outlook API Token Request"
{
    EventSubscriberInstance = Manual;

    var
        SkipTokenRequest: Boolean;

    procedure SetSkipTokenRequest(SkipToken: Boolean)
    begin
        SkipTokenRequest := SkipToken;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Email - OAuth Client", 'OnBeforeGetToken', '', false, false)]
    local procedure MockTokenRequest(var IsHandled: Boolean)
    begin
        IsHandled := SkipTokenRequest;
    end;
}
