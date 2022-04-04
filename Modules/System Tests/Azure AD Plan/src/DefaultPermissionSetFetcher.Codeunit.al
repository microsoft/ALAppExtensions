// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132926 "Default Permission Set Fetcher"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Default Permission Set In Plan", 'OnGetDefaultPermissions', '', false, false)]
    local procedure AddDefaultPermissonSetsToPlan(var Sender: Codeunit "Default Permission Set In Plan")
    var
        AppId: Guid;
    begin
        Sender.AddPermissionSetToPlan('SUPER', AppId, 0);
    end;
}