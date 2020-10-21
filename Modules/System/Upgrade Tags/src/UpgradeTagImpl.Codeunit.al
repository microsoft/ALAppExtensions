// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9996 "Upgrade Tag Impl."
{
    Access = Internal;
    Permissions = TableData "Upgrade Tags" = rimd;

    procedure HasUpgradeTag(Tag: Code[250]): Boolean
    var
        ConstUpgradeTags: Record "Upgrade Tags";
    begin
        exit(HasUpgradeTag(Tag, CopyStr(CompanyName(), 1, MaxStrLen(ConstUpgradeTags.Company))));
    end;

    procedure HasUpgradeTag(Tag: Code[250]; TagCompanyName: Code[30]): Boolean
    var
        UpgradeTags: Record "Upgrade Tags";
    begin
        exit(UpgradeTags.Get(Tag, TagCompanyName));
    end;

    procedure SetUpgradeTag(NewTag: Code[250])
    var
        ConstUpgradeTags: Record "Upgrade Tags";
    begin
        SetUpgradeTagForCompany(NewTag, CopyStr(CompanyName(), 1, MaxStrLen(ConstUpgradeTags.Company)));
    end;

    procedure SetAllUpgradeTags()
    var
        ConstUpgradeTags: Record "Upgrade Tags";
    begin
        SetAllUpgradeTags(CopyStr(CompanyName(), 1, MaxStrLen(ConstUpgradeTags.Company)));
    end;

    procedure SetAllUpgradeTags(NewCompanyName: Code[30])
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        PerCompanyUpgradeTags: List of [Code[250]];
        PerDatabaseUpgradeTags: List of [Code[250]];
    begin
        UpgradeTag.OnGetPerDatabaseUpgradeTags(PerDatabaseUpgradeTags);
        EnsurePerDatabaseUpgradeTagsExist(PerDatabaseUpgradeTags);

        UpgradeTag.OnGetPerCompanyUpgradeTags(PerCompanyUpgradeTags);
        EnsurePerCompanyUpgradeTagsExist(PerCompanyUpgradeTags, NewCompanyName);
    end;

    local procedure EnsurePerCompanyUpgradeTagsExist(PerCompanyUpgradeTags: List of [Code[250]]; TagCompanyName: Code[30])
    var
        UpgradeTag: Code[250];
    begin
        if PerCompanyUpgradeTags.Count() = 0 then
            exit;

        foreach UpgradeTag in PerCompanyUpgradeTags do
            if not HasUpgradeTag(UpgradeTag, TagCompanyName) then
                SetUpgradeTagForCompany(UpgradeTag, TagCompanyName);
    end;

    local procedure EnsurePerDatabaseUpgradeTagsExist(PerDatabaseUpgradeTags: List of [Code[250]])
    var
        UpgradeTags: Record "Upgrade Tags";
        UpgradeTag: Code[250];
    begin
        if PerDatabaseUpgradeTags.Count() = 0 then
            exit;

        foreach UpgradeTag in PerDatabaseUpgradeTags do
            if not UpgradeTags.Get(UpgradeTag, '') then
                SetUpgradeTagForCompany(UpgradeTag, '');
    end;

    local procedure SetUpgradeTagForCompany(NewTag: Code[250]; NewCompanyName: Code[30])
    var
        UpgradeTags: Record "Upgrade Tags";
    begin
        UpgradeTags.Validate(Tag, NewTag);
        UpgradeTags.Validate("Tag Timestamp", CurrentDateTime());
        UpgradeTags.Validate(Company, NewCompanyName);
        UpgradeTags.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateUpgradeTagsOnCompanyRename(var Rec: Record Company; var xRec: Record Company; RunTrigger: Boolean)
    var
        UpgradeTags: Record "Upgrade Tags";
        RenameUpgradeTags: Record "Upgrade Tags";
    begin
        UpgradeTags.SetRange(Company, xRec.Name);
        if not UpgradeTags.FindSet(true) then
            exit;

        repeat
            RenameUpgradeTags.GetBySystemId(UpgradeTags.SystemId);
            RenameUpgradeTags.Rename(RenameUpgradeTags.Tag, Rec.Name);
        until UpgradeTags.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateUpgradeTagsOnInsertCompany(var Rec: Record Company; RunTrigger: Boolean)
    begin
        SetAllUpgradeTags(Rec.Name);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company", 'OnAfterDeleteEvent', '', false, false)]
    local procedure UpdateUpgradeTagsOnCompanyDelete(var Rec: Record Company; RunTrigger: Boolean)
    var
        UpgradeTags: Record "Upgrade Tags";
    begin
        UpgradeTags.SetRange(Company, Rec.Name);
        UpgradeTags.DeleteAll();
    end;
}

