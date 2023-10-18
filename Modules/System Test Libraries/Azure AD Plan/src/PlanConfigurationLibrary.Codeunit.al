// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Azure.ActiveDirectory;

using System.Azure.Identity;

/// <summary>
/// Provides functionality to test plan configurations.
/// </summary>
codeunit 132924 "Plan Configuration Library"
{
    Access = Public;
    Permissions = tabledata "Plan Configuration" = rid,
                  tabledata "Default Permission Set In Plan" = rimd,
                  tabledata "Custom Permission Set In Plan" = rimd;

    /// <summary>
    /// Clears all plan configurations.
    /// </summary>
    procedure ClearPlanConfigurations()
    var
        PlanConfiguration: Record "Plan Configuration";
        DefaultPermissionSetInPlan: Record "Default Permission Set In Plan";
        CustomPermissionSetInPlan: Record "Custom Permission Set In Plan";
    begin
        PlanConfiguration.DeleteAll();
        DefaultPermissionSetInPlan.DeleteAll();
        CustomPermissionSetInPlan.DeleteAll();
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

    /// <summary>
    /// Assigns license 'D365 READ' to the 'Microsoft 365' license configuration.
    /// Used as a notification action.
    /// </summary>
    /// <param name="Notification">The related notification</param>
    procedure AssignD365ReadPermission(Notification: Notification)
    var
        M365License: Codeunit "Microsoft 365 License Impl.";
    begin
        M365License.AssignD365ReadPermission(Notification);
    end;
}