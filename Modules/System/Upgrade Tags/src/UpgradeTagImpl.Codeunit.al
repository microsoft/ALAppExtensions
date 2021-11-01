// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9996 "Upgrade Tag Impl."
{
    Access = Internal;
    Permissions = TableData "Upgrade Tags" = rimd,
                  TableData "Upgrade Tag Backup" = rimd,
                  TableData "Intelligent Cloud" = r;

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
        SkipSetAllUpgradeTags: Boolean;
    begin
        UpgradeTag.OnSetAllUpgradeTags(NewCompanyName, SkipSetAllUpgradeTags);
        if SkipSetAllUpgradeTags then
            exit;

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

    procedure BackupUpgradeTags(): Integer
    var
        UpgradeTagBackup: Record "Upgrade Tag Backup";
        UpgradeTagOutStream: OutStream;
    begin
        VerifyBackupIsEnabled();

        UpgradeTagBackup.Content.CreateOutStream(UpgradeTagOutStream);
        SerializeUpgradeTagsToJson(UpgradeTagOutStream);
        UpgradeTagBackup.Insert();

        exit(UpgradeTagBackup.Id);
    end;

    /// <summary>
    /// Use function is used to restore Upgrade tags after Cloud Migration.
    /// </summary>
    /// <param name="BackupId">ID of the backup, used in RestoreUpgradeTagsFromBackup method.</param>
    /// <param name="RestoreMissingTagsOnly">This parameter indicates if the function should restore the entire table or only insert back the missing upgrade tags.</param>
    procedure RestoreUpgradeTagsFromBackup(BackupId: Integer; RestoreMissingTagsOnly: Boolean)
    var
        UpgradeTagBackup: Record "Upgrade Tag Backup";
        UpgradeTags: Record "Upgrade Tags";
        NewUpgradeTags: Record "Upgrade Tags";
        ExistingUpgradeTags: Record "Upgrade Tags";
        UpgradeTagInStream: InStream;
        UpgradeTagsJsonArray: JsonArray;
        UpgradeTagJsonToken: JsonToken;
        UpgradeTagJsonObject: JsonObject;
        CurrentGlobalLanguage: Integer;
    begin
        VerifyBackupIsEnabled();

        UpgradeTagBackup.SetAutoCalcFields(Content);
        UpgradeTagBackup.Get(BackupId);

        UpgradeTagBackup.Content.CreateInStream(UpgradeTagInStream);
        UpgradeTagsJsonArray.ReadFrom(UpgradeTagInStream);
        CurrentGlobalLanguage := GlobalLanguage();
        GlobalLanguage(1033); // ENU

        if not RestoreMissingTagsOnly then
            UpgradeTags.DeleteAll();

        foreach UpgradeTagJsonToken in UpgradeTagsJsonArray do begin
            Clear(UpgradeTags);
            UpgradeTagJsonObject := UpgradeTagJsonToken.AsObject();
            RestoreUpgradeTagFromJson(UpgradeTagJsonObject, NewUpgradeTags);
            if not UpgradeTags.Get(NewUpgradeTags.Tag, NewUpgradeTags.Company) then begin
                UpgradeTags.TransferFields(NewUpgradeTags, true);
                if not ExistingUpgradeTags.GetBySystemId(NewUpgradeTags.SystemId) then begin
                    UpgradeTags.SystemId := NewUpgradeTags.SystemId;
                    UpgradeTags.Insert(true, true);
                end else
                    UpgradeTags.Insert(true);
            end;
        end;

        GlobalLanguage(CurrentGlobalLanguage);
    end;

    local procedure RestoreUpgradeTagFromJson(UpgradeTagJsonObject: JsonObject; var NewUpgradeTags: Record "Upgrade Tags")
    var
        FieldMetadata: Record Field;
        UpgradeTagRecordRef: RecordRef;
        UpgradeTagFieldRef: FieldRef;
        UpgradeTagSystemFieldRef: FieldRef;
        UpgradeTagFieldToken: JsonToken;
        FieldNameTxt: Text;
    begin
        UpgradeTagRecordRef.Open(Database::"Upgrade Tags");
        FieldMetadata.SetRange(TableNo, Database::"Upgrade Tags");
        UpgradeTagSystemFieldRef := UpgradeTagRecordRef.Field(UpgradeTagRecordRef.SystemIdNo);

        foreach FieldNameTxt in UpgradeTagJsonObject.Keys do begin
            if FieldNameTxt <> UpgradeTagSystemFieldRef.Name then begin
                FieldMetadata.SetRange(FieldName, FieldNameTxt);
                FieldMetadata.FindFirst();
                UpgradeTagFieldRef := UpgradeTagRecordRef.Field(FieldMetadata."No.");
            end else
                UpgradeTagFieldRef := UpgradeTagSystemFieldRef;

            UpgradeTagJsonObject.Get(FieldNameTxt, UpgradeTagFieldToken);
            case UpgradeTagFieldRef.Type of
                FieldType::DateTime:
                    UpgradeTagFieldRef.Value := UpgradeTagFieldToken.AsValue().AsDateTime();
                FieldType::Boolean:
                    UpgradeTagFieldRef.Value := UpgradeTagFieldToken.AsValue().AsBoolean();
                else
                    UpgradeTagFieldRef.Value := UpgradeTagFieldToken.AsValue().AsText();
            end;
        end;

        UpgradeTagRecordRef.SetTable(NewUpgradeTags);
    end;

    local procedure SerializeUpgradeTagsToJson(var UpgradeTagOutStream: OutStream)
    var
        UpgradeTags: Record "Upgrade Tags";
        UpgradeTagsJsonArray: JsonArray;
        CurrentGlobalLanguage: Integer;
    begin
        CurrentGlobalLanguage := GlobalLanguage();
        GlobalLanguage(1033); // ENU

        UpgradeTags.FindSet();
        repeat
            UpgradeTagsJsonArray.Add(SerializeUpgradeTagToJson(UpgradeTags));
        until UpgradeTags.Next() = 0;

        UpgradeTagsJsonArray.WriteTo(UpgradeTagOutStream);

        GlobalLanguage(CurrentGlobalLanguage);
    end;

    local procedure SerializeUpgradeTagToJson(UpgradeTags: Record "Upgrade Tags"): JsonObject
    var
        UpgradeTagRecordRef: RecordRef;
        UpgradeTagFieldRef: FieldRef;
        UpgradeTagJson: JsonObject;
        I: Integer;
    begin
        UpgradeTagRecordRef.GetTable(UpgradeTags);

        for I := 1 to UpgradeTagRecordRef.FieldCount() do begin
            UpgradeTagFieldRef := UpgradeTagRecordRef.FieldIndex(I);
            UpgradeTagJson.Add(UpgradeTagFieldRef.Name, Format(UpgradeTagFieldRef.Value(), 0, 9));
        end;

        UpgradeTagFieldRef := UpgradeTagRecordRef.Field(UpgradeTagRecordRef.SystemIdNo);
        UpgradeTagJson.Add(UpgradeTagFieldRef.Name, Format(UpgradeTagFieldRef.Value(), 0, 9));

        exit(UpgradeTagJson);
    end;

    local procedure VerifyBackupIsEnabled()
    var
        IntelligentCloud: Record "Intelligent Cloud";
    begin
        if IntelligentCloud.Get() then
            if IntelligentCloud.Enabled then
                exit;

        Error(CannotUseWithoutEnablingCloudMigrationErr);
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
        CannotUseWithoutEnablingCloudMigrationErr: Label 'This functionality cannot be used without enabling the Cloud Migration. It should be used only in the context of the Cloud Migration.';
        UpgradeTagSetTelemetryLbl: Label 'Upgrade tag set: %1', Comment = '%1 tag name', Locked = true;
        HasUpgradeTagTelemetryLbl: Label 'Upgrade tag searched for: %1', Comment = '%1 tag name', Locked = true;
        CopyUpgradeTagLbl: Label 'Copying upgrade tag %1. From company: %2. To company: %3', Comment = '%1 tag name, %2 = origin company, % 3 destination company', Locked = true;
        CategoryLbl: Label 'ALUpgrade', Locked = true;
}