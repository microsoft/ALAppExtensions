// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132507 "OnAfterCopyLinks Monitor"
{
    EventSubscriberInstance = Manual;

    var
        EventRaised: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Record Link Management", 'OnAfterCopyLinks', '', false, false)]
    local procedure OnAfterCopyLinks(FromRecord: Variant; ToRecord: Variant)
    begin
        EventRaised := true;
    end;

    procedure IsEventRaised(): Boolean
    begin
        exit(EventRaised);
    end;
}