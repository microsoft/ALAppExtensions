// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9993 "Upgrade Tag Install"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        UpgradeTagTags: Codeunit "Upgrade Tag - Tags";
    begin
        UpgradeTagTags.SetInitializedTagIfNotRegistered();
    end;

    trigger OnInstallAppPerDatabase()
    var
        UpgradeTagTags: Codeunit "Upgrade Tag - Tags";
    begin
        UpgradeTagTags.SetInitializedTagIfNotRegistered();
    end;
}