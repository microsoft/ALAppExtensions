// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The interface for registering upgrade tags.
/// Format of the upgrade tag is:
/// [CompanyPrefix]-[TFSID]-[Description]-[YYYYMMDD]
/// Example:
/// MS-29901-UpdateGLEntriesIntegrationRecordIDs-20161206
/// </summary>
codeunit 9999 "Upgrade Tag"
{
    Access = Public;
    Permissions = TableData "Upgrade Tags" = rimd;

    var
        UpgradeTagImpl: Codeunit "Upgrade Tag Impl.";

    /// <summary>
    /// Verifies if the upgrade tag exists.
    /// </summary>
    /// <param name="Tag">Tag code to check</param>
    /// <returns>True if the Tag with given code exist.</returns>
    procedure HasUpgradeTag(Tag: Code[250]): Boolean
    begin
        exit(UpgradeTagImpl.HasUpgradeTag(Tag));
    end;

    /// <summary>
    /// Verifies if the upgrade tag exists.
    /// </summary>
    /// <param name="Tag">Tag code to check</param>
    /// <param name="TagCompanyName">Name of the company to check existance of tag</param>
    /// <returns>True if the Tag with given code exist.</returns>
    procedure HasUpgradeTag(Tag: Code[250]; TagCompanyName: Code[30]): Boolean
    begin
        exit(UpgradeTagImpl.HasUpgradeTag(Tag, TagCompanyName));
    end;

    /// <summary>
    /// Sets the upgrade tag for database upgrades.
    /// </summary>
    /// <param name="NewTag">Tag code to save</param>
    procedure SetDatabaseUpgradeTag(NewTag: Code[250])
    begin
        UpgradeTagImpl.SetDatabaseUpgradeTag(NewTag);
    end;

    /// <summary>
    /// Sets the upgrade tag.
    /// </summary>
    /// <param name="NewTag">Tag code to save</param>
    procedure SetUpgradeTag(NewTag: Code[250])
    begin
        UpgradeTagImpl.SetUpgradeTag(NewTag);
    end;

    /// <summary>
    /// Sets the upgrade tag to skipped.
    /// </summary>
    /// <param name="ExistingTag">Tag code to set the Skipped Upgrade field</param>
    /// <param name="SkipUpgrade">Sets the Skipped Upgrade field</param>
    procedure SetSkippedUpgrade(ExistingTag: Code[250]; SkipUpgrade: Boolean)
    begin
        UpgradeTagImpl.SetSkippedUpgrade(ExistingTag, SkipUpgrade);
    end;

    /// <summary>
    /// Sets the upgrade tag to skipped.
    /// </summary>
    /// <param name="ExistingTag">Tag code to set the Skipped Upgrade field</param>
    /// <param name="TagCompanyName">Name of the company to check existance of tag</param>
    /// <param name="SkipUpgrade">Sets the Skipped Upgrade field</param>
    procedure SetSkippedUpgrade(ExistingTag: Code[250]; TagCompanyName: Code[30]; SkipUpgrade: Boolean)
    begin
        UpgradeTagImpl.SetSkippedUpgrade(ExistingTag, TagCompanyName, SkipUpgrade);
    end;

    /// <summary>
    /// Check if the upgrade tag is skipped.
    /// </summary>
    /// <param name="ExistingTag">Tag code to set the Skipped Upgrade field</param>
    /// <param name="TagCompanyName">Name of the company to check existance of tag</param>
    procedure HasUpgradeTagSkipped(ExistingTag: Code[250]; TagCompanyName: Code[30]): Boolean
    begin
        exit(UpgradeTagImpl.HasUpgradeTagSkipped(ExistingTag, TagCompanyName));
    end;

    /// <summary>
    /// This method should be used to set all upgrade tags in a new company. 
    /// The method is called from codeunit 2 - Company Initialize.
    /// </summary>
    procedure SetAllUpgradeTags()
    begin
        UpgradeTagImpl.SetAllUpgradeTags();
    end;

    /// <summary>
    /// This method should be used to set all upgrade tags in a new company.
    /// </summary>
    /// <param name="NewCompanyName">Name of the company set the upgrade tags</param>
    procedure SetAllUpgradeTags(NewCompanyName: Code[30])
    begin
        UpgradeTagImpl.SetAllUpgradeTags(NewCompanyName);
    end;

    /// <summary>
    /// This method should be used to copy all upgrade tags from a company to another company.
    /// </summary>
    /// <param name="FromCompanyName">Name of the company from which to take the upgrade tags.</param>
    /// <param name="ToCompanyName">Name of the company to which to copy the upgrade tags.</param>
    procedure CopyUpgradeTags(FromCompanyName: Code[30]; ToCompanyName: Code[30])
    begin
        UpgradeTagImpl.CopyUpgradeTags(FromCompanyName, ToCompanyName);
    end;

    /// <summary>
    /// With this method you get all the upgrade tags by company in a list. 
    /// </summary>
    /// <param name="PerCompanyUpgradeTags">
    /// List of upgrade tags that should be inserted if they do not exist.
    /// </param>
    procedure GetPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        OnGetPerCompanyUpgradeTags(PerCompanyUpgradeTags);
    end;

    /// <summary>
    /// With this method you get all the upgrade tags by database in a list. 
    /// </summary>
    /// <param name="PerCompanyUpgradeTags">
    /// List of upgrade tags that should be inserted if they do not exist.
    /// </param>
    procedure GetPerDatabaseUpgradeTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        OnGetPerDatabaseUpgradeTags(PerDatabaseUpgradeTags);
    end;

    /// <summary>
    /// This function is used for cloud migration to backup upgrade tags before cloud migration is triggered.
    /// Using the function if cloud migration is not enabled will throw an error.
    /// </summary>
    /// <returns>ID of the backup, used in <see cref="RestoreUpgradeTagsFromBackup"/> method.</returns>
    procedure BackupUpgradeTags(): Integer
    begin
        exit(UpgradeTagImpl.BackupUpgradeTags());
    end;

    /// <summary>
    /// This function is used to restore Upgrade tags after cloud migration.
    /// Using the function if cloud migration is not enabled will throw an error.
    /// </summary>
    /// <param name="BackupId">ID of the backup, created by <see cref="BackupUpgradeTags"/> method.</param>
    /// <param name="RestoreMissingTagsOnly">This parameter indicates if the function should restore the entire table or only insert back the missing upgrade tags.</param>
    procedure RestoreUpgradeTagsFromBackup(BackupId: Integer; RestoreMissingTagsOnly: Boolean)
    begin
        UpgradeTagImpl.RestoreUpgradeTagsFromBackup(BackupId, RestoreMissingTagsOnly);
    end;

    /// <summary>
    /// Use this event if you want to add upgrade tag for PerCompany upgrade method for a new company.
    /// </summary>
    /// <param name="PerCompanyUpgradeTags">
    /// List of upgrade tags that should be inserted if they do not exist.
    /// </param>
    [IntegrationEvent(false, false)]
    internal procedure OnGetPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
    end;

    /// <summary>
    /// Use this event if you want to add upgrade tag for PerDatabase upgrade method for a new company.
    /// </summary>
    /// <param name="PerDatabaseUpgradeTags">
    /// List of upgrade tags that should be inserted if they do not exist.
    /// </param>
    [IntegrationEvent(false, false)]
    internal procedure OnGetPerDatabaseUpgradeTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
    end;

    /// <summary>
    /// Use this event if you want to skip or run logic when we register all tags for a company.
    /// </summary>
    /// <param name="NewCompanyName">Name of the company to set the upgrade tags.</param>
    /// <param name="SkipSetAllUpgradeTags">Specifies if the setting of the tags for the company should be skipped.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnSetAllUpgradeTags(NewCompanyName: Text; var SkipSetAllUpgradeTags: Boolean)
    begin
    end;
}

