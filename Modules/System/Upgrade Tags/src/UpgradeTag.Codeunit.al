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
    /// Sets the upgrade tag.
    /// </summary>
    /// <param name="NewTag">Tag code to save</param>
    procedure SetUpgradeTag(NewTag: Code[250])
    begin
        UpgradeTagImpl.SetUpgradeTag(NewTag);
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
    /// The method is called from Copy Company Report
    /// </summary>
    /// <param name="NewCompanyName">Name of the company set the upgrade tags</param>
    procedure SetAllUpgradeTags(NewCompanyName: Code[30])
    begin
        UpgradeTagImpl.SetAllUpgradeTags(NewCompanyName);
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
}

