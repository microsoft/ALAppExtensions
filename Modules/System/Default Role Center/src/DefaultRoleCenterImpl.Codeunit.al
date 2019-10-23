// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9171 "Default Role Center Impl."
{
    Access = Internal;

    // <summary>
    // Gets the default Role Center ID for the current user.
    // </summary>
    // <remarks>The function emits <see cref="OnBeforeGetDefaultRoleCenter" /> event.</remarks>
    // <returns>ID of a valid Role Center page</returns>
    local procedure GetDefaultRoleCenterId(): Integer
    var
        AllProfile: Record "All Profile";
        DefaultRoleCenter: Codeunit "Default Role Center";
        RoleCenterId: Integer;
        Handled: Boolean;
    begin
        DefaultRoleCenter.OnBeforeGetDefaultRoleCenter(RoleCenterId, Handled);

        if not IsValidRoleCenterId(RoleCenterId) then begin
            AllProfile.Get(AllProfile.Scope::Tenant, '63ca2fa4-4f03-4f2b-a480-172fef340d3f', 'BLANK');
            if not AllProfile.Enabled then begin
                AllProfile.Enabled := true;
                AllProfile.Modify();
            end;
            RoleCenterId := PAGE::"Blank Role Center";
        end;

        exit(RoleCenterId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Action Triggers", 'GetDefaultRoleCenterID', '', false, false)]
    local procedure OnGetDefaultRoleCenterId(var ID: Integer)
    begin
        ID := GetDefaultRoleCenterId();
    end;

    local procedure IsValidRoleCenterId(RoleCenterId: Integer): Boolean
    var
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if RoleCenterId = 0 then
            exit(false);

        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Page);
        AllObjWithCaption.SetRange("Object Subtype", 'RoleCenter');
        AllObjWithCaption.SetRange("Object ID", RoleCenterId);

        exit(not AllObjWithCaption.IsEmpty());
    end;
}

