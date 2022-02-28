// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality to test plan configurations.
/// </summary>
codeunit 132924 "Plan Configuration Library"
{
    Access = Public;
    Permissions = tabledata "Plan Configuration" = rid;

    /// <summary>
    /// Clears all plan configurations.
    /// </summary>
    procedure ClearPlanConfigurations()
    var
        PlanConfiguration: Record "Plan Configuration";
    begin
        PlanConfiguration.DeleteAll();
    end;

    /// <summary>
    /// Adds a configuration for a plan
    /// </summary>
    /// <param name="PlanId">The ID of the plan.</param>
    /// <param name="Customized">Whether the permissions in the configurations are customized or not.</param>
    procedure AddConfiguration(PlanId: Guid; Customized: Boolean)
    var
        PlanConfiguration: Record "Plan Configuration";
    begin
        PlanConfiguration.Init();
        PlanConfiguration."Plan ID" := PlanId;
        PlanConfiguration.Customized := Customized;

        PlanConfiguration.Insert();
    end;

    /// <summary>
    /// Opens a plan configuration.
    /// </summary>
    /// <param name="PlanId">The ID of the plan.</param>
    procedure OpenConfiguration(PlanId: Guid)
    var
        PlanConfiguration: Record "Plan Configuration";
    begin
        PlanConfiguration.SetRange("Plan ID", PlanId);
        PlanConfiguration.FindFirst();

        Page.Run(Page::"Plan Configuration Card", PlanConfiguration);
    end;
}