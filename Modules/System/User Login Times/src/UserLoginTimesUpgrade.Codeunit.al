// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9028 "User Login Times Upgrade"
{
    Subtype = Upgrade;
    Permissions = tabledata "User Environment Login" = ri,
                  tabledata "User Login" = r;

    trigger OnUpgradePerCompany()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetMoveUserLoginUpgradeTag()) then
            exit;

        AddUserEnvironmentLogin();

        UpgradeTag.SetUpgradeTag(GetMoveUserLoginUpgradeTag());
    end;

    /// <summary>
    /// Create entries in "User Environment Login" for all the user who have logged in to any company.
    /// </summary>
    local procedure AddUserEnvironmentLogin()
    var
        UserLogin: Record "User Login";
        UserEnvironmentLogin: Record "User Environment Login";
    begin
        if not UserLogin.FindSet() then
            exit;

        repeat
            if not UserEnvironmentLogin.Get(UserLogin."User SID") then begin
                UserEnvironmentLogin."User SID" := UserLogin."User SID";
                UserEnvironmentLogin.Insert();
            end;
        until UserLogin.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure AddUpgradeTag(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        if not PerCompanyUpgradeTags.Contains(GetMoveUserLoginUpgradeTag()) then
            PerCompanyUpgradeTags.Add(GetMoveUserLoginUpgradeTag());
    end;

    local procedure GetMoveUserLoginUpgradeTag(): Code[250]
    begin
        exit('MS-427843-MoveUserLogin-03032022');
    end;
}