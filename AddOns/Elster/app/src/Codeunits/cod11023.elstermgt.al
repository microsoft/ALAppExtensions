// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 11023 "Elster Management"
{
    procedure GetElsterUpgradeTag(): Code[250];
    begin
        exit('MS-332065-ElsterUpgrade-20191029');
    end;

    procedure GetCleanupElsterTag(): Code[250];
    begin
        exit('MS-332065-CleanupElster-20191029');
    end;

    [EventSubscriber(ObjectType::Codeunit, 9999, 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetElsterUpgradeTag());
        PerCompanyUpgradeTags.Add(GetCleanupElsterTag());
    end;
}
