#if not CLEAN20
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9222 "User Settings Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;
    Permissions = tabledata "Extra Settings" = r,
                  tabledata "Application User Settings" = rim;

    trigger OnUpgradePerDatabase()
    begin
        TransferFieldsToApplicationUserSettings();
    end;

    local procedure TransferFieldsToApplicationUserSettings()
    var
        ExtraSettings: Record "Extra Settings";
        ApplicationUserSettings: Record "Application User Settings";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetUserSettingsUpgradeTag()) then
            exit;

        if ExtraSettings.FindSet() then
            repeat
                ApplicationUserSettings.TransferFields(ExtraSettings);
                ApplicationUserSettings.Insert();
            until ExtraSettings.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetUserSettingsUpgradeTag());
    end;

    local procedure GetUserSettingsUpgradeTag(): Code[250]
    begin
        exit('MS-417094-UserSettingsTransferFields-20211125');
    end;
}
#endif