// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9992 "Upgrade Tag - Tags"
{
    Access = Internal;
    Permissions = TableData Company = r,
                  TableData "Upgrade Tags" = rimd;

    procedure SetInitializedTagIfNotRegistered(): Text
    var
        UpgradeTagTags: Codeunit "Upgrade Tag - Tags";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagTags.GetUpgradeTagInitializedTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagTags.GetUpgradeTagInitializedTag());
    end;

    procedure VerifyAllCompaniesInitialized()
    var
        Company: Record Company;
    begin
        if not Company.FindSet() then
            exit;

        repeat
            VerifyCompanyInitialized(Company.Name);
        until Company.Next() = 0;
    end;

    procedure VerifyCompanyInitialized(CompanyName: Text[30])
    var
        UpgradeTags: Record "Upgrade Tags";
        UpgradeTagTags: Codeunit "Upgrade Tag - Tags";
    begin
        if not UpgradeTags.Get(UpgradeTagTags.GetUpgradeTagInitializedTag(), CompanyName) then
            Error(SystemIsNotInitialziedProperlyErr, CompanyName);
    end;

    /// <summary>
    /// Upgrade tag used to mark that the upgrade tags have been initialized for PerCompany and PerDatabase
    /// </summary>
    /// <returns>Tag value - format is: Publisher - TFSID - Name - Date. Purpose of the naming is to make the tag unique.</returns>
    procedure GetUpgradeTagInitializedTag(): Code[250]
    begin
        exit('MS-345417-UpgradeTagsInitialzied-20200303');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetUpgradeTagInitializedTag());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseUpgradeTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetUpgradeTagInitializedTag());
    end;

    var
        SystemIsNotInitialziedProperlyErr: Label 'System is not initialized properly. Upgrade tags are missing for %1 company', Comment = '%1 - Company name', Locked = true;
}