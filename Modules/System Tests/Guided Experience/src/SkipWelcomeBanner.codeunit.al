// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------


codeunit 132620 "Skip Welcome Banner"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Checklist Banner", 'OnOpenChecklistBannerPage', '', false, false)]
    local procedure OnOpenChecklistBannerPage(var SkipWelcomeState: Boolean)
    begin
        SkipWelcomeState := true;
    end;

}