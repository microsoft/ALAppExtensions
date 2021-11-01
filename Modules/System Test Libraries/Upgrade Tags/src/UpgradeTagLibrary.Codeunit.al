// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135102 "Upgrade Tag Library"
{
    Permissions = tabledata "Upgrade Tags" = rmid;

    procedure DeleteAllUpgradeTags()
    var
        UpgradeTags: Record "Upgrade Tags";
    begin
        UpgradeTags.DeleteAll();
    end;

    procedure DeleteUpgradeTag(Tag: Code[250]; TagCompanyName: Code[30])
    var
        UpgradeTags: Record "Upgrade Tags";
    begin
        UpgradeTags.Get(Tag, TagCompanyName);
        UpgradeTags.Delete();
    end;
}