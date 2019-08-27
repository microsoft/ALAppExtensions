// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135093 "SetAllUpgradeTags Mock"
{
    EventSubscriberInstance = Manual;

    var
        MockedPerCompanyUpgradeTags: List of [Code[250]];
        MockedPerDatabaseUpgradeTags: List of [Code[250]];

    procedure SetPerCompanyUpgradeTags(NewMockedPerCompanyUpgradeTags: List of [Code[250]])
    begin
        MockedPerCompanyUpgradeTags := NewMockedPerCompanyUpgradeTags;
    end;

    procedure SetPerDatabaseUpgradeTags(NewMockedPerDatabaseUpgradeTags: List of [Code[250]])
    begin
        MockedPerDatabaseUpgradeTags := NewMockedPerDatabaseUpgradeTags;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure GetPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    var
        MockUpgradeTag: Code[250];
    begin
        foreach MockUpgradeTag in MockedPerCompanyUpgradeTags do
            PerCompanyUpgradeTags.Add(MockUpgradeTag);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure GetPerDatabaseUpgradeTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    var
        MockUpgradeTag: Code[250];
    begin
        foreach MockUpgradeTag in MockedPerDatabaseUpgradeTags do
            PerDatabaseUpgradeTags.Add(MockUpgradeTag);
    end;
}

