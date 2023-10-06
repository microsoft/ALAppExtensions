// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.Core;

using System.Environment.Configuration;
using System.Security.AccessControl;
using System.Upgrade;

codeunit 13602 "Upgrade Local Permission Set"
{
    Subtype = Upgrade;

    trigger OnUpgradePerDatabase()
    begin
        RunUpgrade();
    end;

    internal procedure RunUpgrade()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        DKCoreUpgradeTags: Codeunit "DKCore Upgrade Tags";
        ServerSettings: Codeunit "Server Setting";
    begin
        if not ServerSettings.GetUsePermissionSetsFromExtensions() then
            exit;

        if UpgradeTag.HasUpgradeTag(DKCoreUpgradeTags.GetRemoveLocalPermissionSetUpgradeTag()) then
            exit;

        RemoveLocalPermissionSet();

        UpgradeTag.SetUpgradeTag(DKCoreUpgradeTags.GetRemoveLocalPermissionSetUpgradeTag());
    end;


    local procedure RemoveLocalPermissionSet()
    var
        UserGroupPermissionSet: Record "User Group Permission Set";
        UserGroupAccessControl: Record "User Group Access Control";
        AccessControl: Record "Access Control";
        NullGuid: Guid;
    begin
        UserGroupPermissionSet.SetRange(Scope, UserGroupPermissionSet.Scope::System);
        UserGroupPermissionSet.SetRange("Role ID", 'LOCAL');
        UserGroupPermissionSet.SetRange("App ID", NullGuid);

        UserGroupPermissionSet.DeleteAll();

        UserGroupAccessControl.SetRange(Scope, UserGroupAccessControl.Scope::System);
        UserGroupAccessControl.SetRange("Role ID", 'LOCAL');
        UserGroupAccessControl.SetRange("App ID", NullGuid);

        UserGroupAccessControl.DeleteAll();

        AccessControl.SetRange(Scope, AccessControl.Scope::System);
        AccessControl.SetRange("Role ID", 'LOCAL');
        AccessControl.SetRange("App ID", NullGuid);

        AccessControl.DeleteAll();
    end;

}
