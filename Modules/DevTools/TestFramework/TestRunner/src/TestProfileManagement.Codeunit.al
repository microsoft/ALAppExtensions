// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 130457 "Test Profile Management"
{
    // Used to insert a profile into blank database
    // Web Client cannot load a blank company with no profiles, existing profiles should not be modified
    // This approach is following the implementation done by the Default Profile module

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'GetDefaultRoleCenterID', '', false, false)]
    local procedure OnGetDefaultRoleCenterId(var ID: Integer)
    var
        AllProfile: Record "All Profile";
    begin
        if (ID <> 0) then
            exit;

        AllProfile.SetRange("Default Role Center", true);
        if NOT AllProfile.IsEmpty() then
            exit;

        ID := Page::"Test Role Center";
    end;
}

