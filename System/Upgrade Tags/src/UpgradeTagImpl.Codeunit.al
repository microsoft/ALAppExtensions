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
        UpgradeTagExists: Boolean;
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        UpgradeTagExists := UpgradeTags.Get(Tag, TagCompanyName);

        if GetExecutionContext() = ExecutionContext::Upgrade then begin
            AddDefaultTelemetryParameters(TelemetryDimensions, Tag, TagCompanyName);
            TelemetryDimensions.Add('Value', Format(UpgradeTagExists, 0, 9));
            Session.LogMessage('0000EJ9', StrSubstNo(HasUpgradeTagTelemetryLbl, Tag), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);
        end;

        exit(UpgradeTagExists);
    end;

    procedure SetUpgradeTag(NewTag: Code[250])
    var
        ConstUpgradeTags: Record "Upgrade Tags";
    begin
        SetUpgradeTagForCompany(NewTag, CopyStr(CompanyName(), 1, MaxStrLen(ConstUpgradeTags.Company)));
    end;

    procedure SetDatabaseUpgradeTag(NewTag: Code[250])
    begin
        SetUpgradeTagForCompany(NewTag, '');
    end;

    procedure SetSkippedUpgrade(ExistingTag: Code[250]; SkipUpgrade: Boolean)
    var
        UpgradeTags: Record "Upgrade Tags";
    begin
        SetSkippedUpgrade(ExistingTag, CopyStr(CompanyName(), 1, MaxStrLen(UpgradeTags.Company)), SkipUpgrade);
    end;

    procedure SetSkippedUpgrade(ExistingTag: Code[250]; TagCompanyName: Code[30]; SkipUpgrade: Boolean)
    var
        UpgradeTags: Record "Upgrade Tags";
    begin
        if UpgradeTags.Get(ExistingTag, TagCompanyName) then
            if UpgradeTags."Skipped Upgrade" <> SkipUpgrade then begin
                UpgradeTags."Skipped Upgrade" := SkipUpgrade;
                UpgradeTags.Modify();
            end;
    end;

    procedure HasUpgradeTagSkipped(ExistingTag: Code[250]; TagCompanyName: Code[30]): Boolean
    var
        UpgradeTags: Record "Upgrade Tags";
    begin
        if UpgradeTags.Get(ExistingTag, TagCompanyName) then
            exit(UpgradeTags."Skipped Upgrade");
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

    procedure CopyUpgradeTags(FromCompany: Code[30]; ToCompanyName: Code[30])
    var
        FromUpgradeTags: Record "Upgrade Tags";
        ToUpgradeTags: Record "Upgrade Tags";
    begin
        FromUpgradeTags.SetRange(Company, FromCompany);

        if FromUpgradeTags.FindSet() then
            repeat
                ToUpgradeTags.Copy(FromUpgradeTags);
                ToUpgradeTags.Company := ToCompanyName;

                if not ToUpgradeTags.Get(ToUpgradeTags.Tag, ToUpgradeTags.Company) then begin
                    ToUpgradeTags.Insert();
                    Session.LogMessage('0000EAY', StrSubstNo(CopyUpgradeTagLbl, FromUpgradeTags.Tag, FromUpgradeTags.Company, ToCompanyName), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', CategoryLbl);
                end;
            until FromUpgradeTags.Next() = 0;
    end;

    local procedure AddDefaultTelemetryParameters(var TelemetryDimensions: Dictionary of [Text, Text]; Tag: Code[250]; TagCompanyName: Code[30])
    begin
        TelemetryDimensions.Add('Category', CategoryLbl);
        TelemetryDimensions.Add('UpgradeTag', Tag);
        TelemetryDimensions.Add('CompanyName', TagCompanyName);
        TelemetryDimensions.Add('ExecutionContext', Format(Session.GetExecutionContext()));
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
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        UpgradeTags.Validate(Tag, NewTag);
        UpgradeTags.Validate("Tag Timestamp", CurrentDateTime());
        UpgradeTags.Validate(Company, NewCompanyName);
        UpgradeTags.Insert(true);

        AddDefaultTelemetryParameters(TelemetryDimensions, NewTag, NewCompanyName);
        Session.LogMessage('0000EJA', StrSubstNo(UpgradeTagSetTelemetryLbl, NewTag), Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::All, TelemetryDimensions);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateUpgradeTagsOnCompanyRename(var Rec: Record Company; var xRec: Record Company; RunTrigger: Boolean)
    var
        UpgradeTags: Record "Upgrade Tags";
        RenameUpgradeTags: Record "Upgrade Tags";
    begin
        if Rec.IsTemporary() then
            exit;

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
        if Rec.IsTemporary() then
            exit;

        SetAllUpgradeTags(Rec.Name);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company", 'OnAfterDeleteEvent', '', false, false)]
    local procedure UpdateUpgradeTagsOnCompanyDelete(var Rec: Record Company; RunTrigger: Boolean)
    var
        UpgradeTags: Record "Upgrade Tags";
    begin
        if Rec.IsTemporary() then
            exit;

        UpgradeTags.SetRange(Company, Rec.Name);
        UpgradeTags.DeleteAll();
    end;

    var
        UpgradeTagSetTelemetryLbl: Label 'Upgrade tag set: %1', Comment = '%1 tag name', Locked = true;
        HasUpgradeTagTelemetryLbl: Label 'Upgrade tag searched for: %1', Comment = '%1 tag name', Locked = true;
        CopyUpgradeTagLbl: Label 'Copying upgrade tag %1. From company: %2. To company: %3', Comment = '%1 tag name, %2 = origin company, % 3 destination company', Locked = true;
        CategoryLbl: Label 'ALUpgrade', Locked = true;
}

