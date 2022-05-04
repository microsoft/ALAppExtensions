// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to retrieve the device upgrade tag.
/// </summary>
codeunit 9058 "Plan Upgrade Tag"
{
    Access = Public;

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerDatabaseUpgradeTags', '', false, false)]
    local procedure RegisterPerDatabaseTags(var PerDatabaseUpgradeTags: List of [Code[250]])
    begin
        PerDatabaseUpgradeTags.Add(GetAddDeviceISVEmbUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetRenamePlansUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetRenameTeamMemberPlanUpgradeTag());
        PerDatabaseUpgradeTags.Add(GetPlanfigurationsUpgradeTag());
    end;

    /// <summary>
    /// Returns the device upgrade tag.
    /// </summary>
    /// <returns>The device upgrade tag.</returns>
    procedure GetAddDeviceISVEmbUpgradeTag(): Code[250]
    begin
        exit('MS-322095-AddDeviceISVEmbPlan-20190821');
    end;

    /// <summary>
    /// Returns the rename plans upgrade tag.
    /// </summary>
    /// <returns>The rename plans upgrade tag.</returns>
    internal procedure GetRenamePlansUpgradeTag(): Code[250]
    begin
        exit('MS-329421-RenamePlans-20211028');
    end;

    /// <summary>
    /// Returns the rename team member plan upgrade tag.
    /// </summary>
    /// <returns>The rename team member plan upgrade tag.</returns>
    internal procedure GetRenameTeamMemberPlanUpgradeTag(): Code[250]
    begin
        exit('MS-393309-RenameTeamMemberPlan-20210315');
    end;

    /// <summary>
    /// Returns the rename device plan upgrade tag.
    /// </summary>
    /// <returns>The rename device plan upgrade tag.</returns>
    internal procedure GetRenameDevicePlanUpgradeTag(): Code[250]
    begin
        exit('MS-394628-RenameDevicePlan-20210325');
    end;

    /// <summary>
    /// Returns the Premium Partner Sandbox upgrade tag.
    /// </summary>
    /// <returns>The Premium Partner Sandbox upgrade tag.</returns>
    internal procedure GetPremiumPartnerSandboxUpgradeTag(): Code[250]
    begin
        exit('MS-426983-AddPremiumPartnerSandbox-20220218');
    end;

    internal procedure GetPlanfigurationsUpgradeTag(): Code[250]
    begin
        exit('MS-430587-AddPlanConfigurations-20220321');
    end;
}

