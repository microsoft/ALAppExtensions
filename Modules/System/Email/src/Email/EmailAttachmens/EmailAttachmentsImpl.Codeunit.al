// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Email;

codeunit 8865 "Email Attachments Impl"
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Email Message Impl.", 'OnBeforeDeleteSentEmailAttachment', '', false, false)]
    local procedure OnBeforeDeleteSentEmailAttachment(var BypassSentCheck: Boolean)
    begin
        BypassSentCheck := true;
    end;

}