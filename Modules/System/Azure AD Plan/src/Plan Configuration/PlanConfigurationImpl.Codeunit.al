// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

using System.Telemetry;
using System.Security.User;
using System.Security.AccessControl;
using System.Environment;

codeunit 9822 "Plan Configuration Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    Permissions = tabledata "Plan Configuration" = rimd,
                  tabledata "Custom Permission Set In Plan" = rimd,
                  tabledata "Default Permission Set In Plan" = rimd;

    var
        ConfirmRemoveCustomizationsQst: Label 'Restoring the default permissions will delete the customization for the selected license. Do you want to continue?';
        ConfigurationAlreadyExistsErr: Label 'Configuration for license %1 already exists. To edit it, select it from the list.', Comment = '%1 = License name, e.g. Dynamics 365 Business Central Essentials';
        MissingSecurityErr: Label 'You do not have permissions to configure licenses. Contact your system administrator.';
        MissingPermissionSetErr: Label 'You don''t have rights to manage the %1 permission set for licenses. The SECURITY permission set only grants you rights to manage those permission sets that are also assigned to your account.', Comment = '%1 = permssion set name, e.g. ''D365 READ''';
        CustomizePermissionsNotificationTxt: Label 'Customizing permissions below will affect only newly created users who are assigned %1 license. Permissions for existing users who are assigned the license will not be affected.', Comment = '%1 = license name, e.g. e.g. Dynamics 365 Business Central Essentials';
        DefaultConfigurationNotificationTxt: Label 'One or more of the license configurations use implicit company permissions, which is not recommended.';
        LearnMoreTok: Label 'Learn more';
        DocumentationLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2186490', Locked = true;
        BCAdminCenterSaaSLinkTxt: Label '%1/admin', Locked = true, Comment = '%1 = Base URL (including tenant ID Guid)';
        BCAdminCenterOnPremLinkTxt: Label '%1%2/admin', Locked = true, Comment = '%1 = Base URL, %2 = Tenant ID (Guid)';
        M365AdminCenterLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2211746', Locked = true;
        CustomizationNotificationIdTok: Label '9d730988-ff4a-43ca-8b4f-80ee476fa3c4', Locked = true;
        PlanConfigurationFeatureNameTok: Label 'Custom Permissions Assignment Per Plan', Locked = true;
        PermissionSetAssignedToUserTxt: Label 'Custom Permission Set Assigned To User', Locked = true;
        CustomPermissionSetLbl: Label 'role id %1, app id %2, scope %3, company %4 and plan %5', Locked = true;
        CustomPermissionSetInPlanAddedLbl: Label 'Custom Permission Set In Plan was added with %1.', Locked = true;
        CustomPermissionSetInPlanRemovedLbl: Label 'Custom Permission Set In Plan was removed with %1.', Locked = true;
        CustomPermissionSetInPlanModifiedLbl: Label 'Custom Permission Set In Plan was modified from %1 to %2.', Locked = true;
        PlanConfigurationUpdatedLbl: Label 'Plan Configuration was modified for plan %1. Customized: %2.', Locked = true;

    procedure IsCustomized(PlanId: Guid): Boolean
    var
        PlanConfiguration: Record "Plan Configuration";
    begin
        PlanConfiguration.SetRange("Plan ID", PlanId);
        if not PlanConfiguration.FindFirst() then
            exit(false);

        exit(PlanConfiguration.Customized);
    end;

    [Scope('OnPrem')]
    procedure AddCustomPermissionSetToPlan(PlanId: Guid; RoleId: Code[20]; AppId: Guid; Scope: Option; Company: Text[30])
    var
        CustomPermissionSetInPlan: Record "Custom Permission Set In Plan";
    begin
        CustomPermissionSetInPlan."Plan ID" := PlanId;
        CustomPermissionSetInPlan."Role ID" := RoleId;
        CustomPermissionSetInPlan."Company Name" := Company;
        CustomPermissionSetInPlan.Scope := Scope;
        CustomPermissionSetInPlan."App ID" := AppId;

        if CustomPermissionSetInPlan.Insert() then;
    end;

    [Scope('OnPrem')]
    procedure RemoveCustomPermissionSetFromPlan(PlanId: Guid; RoleId: Code[20]; AppId: Guid; Scope: Option; Company: Text)
    var
        CustomPermissionSetInPlan: Record "Custom Permission Set In Plan";
    begin
        CustomPermissionSetInPlan.SetRange("Plan ID", PlanId);
        CustomPermissionSetInPlan.SetRange("Role ID", RoleId);
        CustomPermissionSetInPlan.SetRange("Company Name", Company);
        CustomPermissionSetInPlan.SetRange(Scope, Scope);
        CustomPermissionSetInPlan.SetRange("App ID", AppId);

        if CustomPermissionSetInPlan.FindFirst() then
            CustomPermissionSetInPlan.Delete();
    end;

    [Scope('OnPrem')]
    procedure AssignCustomPermissionsToUser(PlanId: Guid; UserSecurityId: Guid)
    var
        CustomPermissionSetInPlan: Record "Custom Permission Set In Plan";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GLO', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::Used);

        CustomPermissionSetInPlan.SetRange("Plan ID", PlanId);
        if not CustomPermissionSetInPlan.FindSet() then
            exit;

        repeat
            FeatureTelemetry.LogUsage('0000GMJ', PlanConfigurationFeatureNameTok, PermissionSetAssignedToUserTxt, GetTelemetryDimensions(CustomPermissionSetInPlan, true));
            AddPermissionSetToAccessControl(UserSecurityId, CustomPermissionSetInPlan."Role ID", CustomPermissionSetInPlan."App ID", CustomPermissionSetInPlan.Scope, CustomPermissionSetInPlan."Company Name");
        until CustomPermissionSetInPlan.Next() = 0;
    end;

    procedure RemoveCustomPermissionsFromUser(PlanId: Guid; UserSecurityId: Guid)
    var
        CustomPermissionSetInPlan: Record "Custom Permission Set In Plan";
        CustomPermissionSetInOtherPlans: Record "Custom Permission Set In Plan";
        AccessControl: Record "Access Control";
#if not CLEAN22
        PlanConfiguration: Codeunit "Plan Configuration";
        IsAssignedViaUserGroups: Boolean;
#endif
        PlanIdFilter: Text;
    begin
        CustomPermissionSetInPlan.SetRange("Plan ID", PlanId);
        if not CustomPermissionSetInPlan.FindSet() then
            exit;

        repeat
            if AccessControl.Get(UserSecurityID, CustomPermissionSetInPlan."Role ID", CustomPermissionSetInPlan."Company Name", CustomPermissionSetInPlan.Scope, CustomPermissionSetInPlan."App ID") then
#if not CLEAN22
#pragma warning disable AA0013
            begin
#pragma warning restore AA0013
#pragma warning disable AL0432
                PlanConfiguration.OnBeforeRemoveCustomPermissionsFromUser(AccessControl, IsAssignedViaUserGroups);
#pragma warning restore AL0432
                if not IsAssignedViaUserGroups then
#endif
                    if not GetUserPlansAsFilter(UserSecurityId, PlanId, PlanIdFilter) then
                        AccessControl.Delete() // there are no plans assigned to this user or we are deleting permissions for the only assigned plan
                    else begin
                        // Check if the permission set is assigned to other user plans that the user still has assigned
                        CustomPermissionSetInOtherPlans.SetFilter("Plan ID", PlanIdFilter);
                        CustomPermissionSetInOtherPlans.SetRange("Role ID", CustomPermissionSetInPlan."Role ID");
                        CustomPermissionSetInOtherPlans.SetRange("Company Name", CustomPermissionSetInPlan."Company Name");
                        CustomPermissionSetInOtherPlans.SetRange(Scope, CustomPermissionSetInPlan.Scope);
                        CustomPermissionSetInOtherPlans.SetRange("App ID", CustomPermissionSetInPlan."App ID");

                        // If not, we remove the assigned permission set
                        if CustomPermissionSetInOtherPlans.IsEmpty() then
                            AccessControl.Delete();
                    end;
#if not CLEAN22
            end;
#endif
        until CustomPermissionSetInPlan.Next() = 0;
    end;

    procedure GetCustomPermissions(var PermissionSetInPlanBuffer: Record "Permission Set In Plan Buffer")
    var
        CustomPermissionSetInPlan: Record "Custom Permission Set In Plan";
    begin
        PermissionSetInPlanBuffer.Reset();
        PermissionSetInPlanBuffer.DeleteAll();

        if not CustomPermissionSetInPlan.FindSet() then
            exit;

        repeat
            PermissionSetInPlanBuffer.TransferFields(CustomPermissionSetInPlan);
            PermissionSetInPlanBuffer.Insert();
        until CustomPermissionSetInPlan.Next() = 0;
    end;

    procedure AddDefaultPermissionSetToPlan(PlanId: Guid; RoleId: Code[20]; AppId: Guid; Scope: Option)
    var
        DefaultPermissionSetInPlan: Record "Default Permission Set In Plan";
    begin
        DefaultPermissionSetInPlan."Plan ID" := PlanId;
        DefaultPermissionSetInPlan."Role ID" := RoleId;
        DefaultPermissionSetInPlan.Scope := Scope;
        DefaultPermissionSetInPlan."App ID" := AppId;

        if DefaultPermissionSetInPlan.Insert() then;
    end;

    procedure RemoveDefaultPermissionSetFromPlan(PlanId: Guid; RoleId: Code[20]; AppId: Guid; Scope: Option)
    var
        DefaultPermissionSetInPlan: Record "Default Permission Set In Plan";
    begin
        if DefaultPermissionSetInPlan.Get(PlanId, RoleId, Scope, AppId) then
            DefaultPermissionSetInPlan.Delete();
    end;

    procedure AssignDefaultPermissionsToUser(PlanId: Guid; UserSecurityId: Guid; Company: Text[30])
    var
        DefaultPermissionSetInPlan: Record "Default Permission Set In Plan";
    begin
        DefaultPermissionSetInPlan.SetRange("Plan ID", PlanId);
        if not DefaultPermissionSetInPlan.FindSet() then
            exit;

        repeat
            AddPermissionSetToAccessControl(UserSecurityId, DefaultPermissionSetInPlan."Role ID", DefaultPermissionSetInPlan."App ID", DefaultPermissionSetInPlan.Scope, Company);
        until DefaultPermissionSetInPlan.Next() = 0;
    end;

    procedure RemoveDefaultPermissionsFromUser(PlanId: Guid; UserSecurityId: Guid)
    var
        DefaultPermissionSetInPlan: Record "Default Permission Set In Plan";
        DefaultPermissionSetInOtherPlans: Record "Default Permission Set In Plan";
        AccessControl: Record "Access Control";
#if not CLEAN22
        PlanConfiguration: Codeunit "Plan Configuration";
        IsAssignedViaUserGroups: Boolean;
#endif
        PlanIdFilter: Text;
    begin
        DefaultPermissionSetInPlan.SetRange("Plan ID", PlanId);
        if not DefaultPermissionSetInPlan.FindSet() then
            exit;

        repeat
            AccessControl.SetRange("User Security ID", UserSecurityID);
            AccessControl.SetRange("Role ID", DefaultPermissionSetInPlan."Role ID");
            AccessControl.SetRange(Scope, DefaultPermissionSetInPlan.Scope);
            AccessControl.SetRange("App ID", DefaultPermissionSetInPlan."App ID");

            if AccessControl.FindFirst() then
#if not CLEAN22
#pragma warning disable AA0013
            begin
#pragma warning restore AA0013
#pragma warning disable AL0432
                PlanConfiguration.OnBeforeRemoveDefaultPermissionsFromUser(AccessControl, IsAssignedViaUserGroups);
#pragma warning restore AL0432
                if not IsAssignedViaUserGroups then
#endif
                    if not GetUserPlansAsFilter(UserSecurityId, PlanId, PlanIdFilter) then
                        AccessControl.DeleteAll() // there are no plans assigned to this user or we are deleting permissions for the only assigned plan
                    else begin
                        // Check if the permission set is assigned to other user plans that the user still has assigned
                        DefaultPermissionSetInOtherPlans.SetFilter("Plan ID", PlanIdFilter);
                        DefaultPermissionSetInOtherPlans.SetRange("Role ID", DefaultPermissionSetInPlan."Role ID");
                        DefaultPermissionSetInOtherPlans.SetRange(Scope, DefaultPermissionSetInPlan.Scope);
                        DefaultPermissionSetInOtherPlans.SetRange("App ID", DefaultPermissionSetInPlan."App ID");

                        // If not, we remove all the assigned permission sets
                        if DefaultPermissionSetInOtherPlans.IsEmpty() then
                            AccessControl.DeleteAll();
                    end;
#if not CLEAN22
            end;
#endif
        until DefaultPermissionSetInPlan.Next() = 0;
    end;

    procedure GetDefaultPermissions(var PermissionSetInPlanBuffer: Record "Permission Set In Plan Buffer")
    var
        DefaultPermissionSetInPlan: Record "Default Permission Set In Plan";
    begin
        PermissionSetInPlanBuffer.Reset();
        PermissionSetInPlanBuffer.DeleteAll();

        if not DefaultPermissionSetInPlan.FindSet() then
            exit;

        repeat
            PermissionSetInPlanBuffer.TransferFields(DefaultPermissionSetInPlan);
            PermissionSetInPlanBuffer.Insert();
        until DefaultPermissionSetInPlan.Next() = 0;
    end;

    [Scope('OnPrem')]
    procedure VerifyUserHasRequiredPermissionSet(RoleId: Code[20]; AppId: Guid; Scope: Option; Company: Text)
    var
        UserPermissions: Codeunit "User Permissions";
        PermissionSetScope: Option System,Tenant;
        NullGuid: Guid;
    begin
        if UserPermissions.HasUserPermissionSetAssigned(UserSecurityId(), Company, 'SUPER', PermissionSetScope::System, NullGuid) then
            exit;

        if not UserPermissions.HasUserPermissionSetAssigned(UserSecurityId(), Company, 'SECURITY', PermissionSetScope::System, NullGuid) then
            Error(MissingSecurityErr);

        if not UserPermissions.HasUserPermissionSetAssigned(UserSecurityId(), Company, RoleId, Scope, AppId) then
            Error(MissingPermissionSetErr, RoleId);
    end;

    procedure ConfigurationContainsSuper(PlanId: Guid): Boolean
    var
        PlanConfiguration: Record "Plan Configuration";
        CustomPermissionSetInPlan: Record "Custom Permission Set In Plan";
        NullGuid: Guid;
    begin
        PlanConfiguration.SetRange("Plan ID", PlanId);

        if not PlanConfiguration.FindFirst() then
            exit(false); // default permission sets never contain SUPER

        if not PlanConfiguration.Customized then
            exit(false); // default permission sets never contain SUPER

        CustomPermissionSetInPlan.SetRange("Plan ID", PlanId);
        CustomPermissionSetInPlan.SetRange("Role ID", 'SUPER');
        CustomPermissionSetInPlan.SetRange("Company Name", '');
        CustomPermissionSetInPlan.SetRange("App ID", NullGuid);
        CustomPermissionSetInPlan.SetRange(Scope, CustomPermissionSetInPlan.Scope::System);

        exit(not CustomPermissionSetInPlan.IsEmpty());
    end;

    procedure AddLicenseEntry()
    var
        PlanConfiguration: Record "Plan Configuration";
        Plans: Page Plans;
        SelectedPlanId: Guid;
        SelectedPlanName: Text[50];
    begin
        Plans.LookupMode(true);
        if Plans.RunModal() = Action::LookupOK then begin
            Plans.GetSelectedPlan(SelectedPlanId, SelectedPlanName);

            PlanConfiguration.SetRange("Plan ID", SelectedPlanId);
            if not PlanConfiguration.IsEmpty() then
                Error(ConfigurationAlreadyExistsErr, SelectedPlanName);

            PlanConfiguration.Init();
            PlanConfiguration."Plan ID" := SelectedPlanId;
            PlanConfiguration."Plan Name" := SelectedPlanName;
            PlanConfiguration.Insert();
        end;
    end;

    internal procedure TransferPermissions(PlanId: Guid)
    var
        CustomPermissionSetInPlan: Record "Custom Permission Set In Plan";
#if not CLEAN22
#pragma warning disable AL0432
        DefaultPermissionSetInPlan: Record "Permission Set In Plan Buffer";
        DefaultPermissionSetInPlanController: Codeunit "Default Permission Set In Plan";
#pragma warning restore AL0432
#else
        DefaultPermissionSetInPlan: Record "Default Permission Set In Plan";
#endif
#if not CLEAN22
        PlanConfiguration: Codeunit "Plan Configuration";
#endif
    begin
#if not CLEAN22
        DefaultPermissionSetInPlanController.GetPermissionSets(PlanId, DefaultPermissionSetInPlan);
#endif
        DefaultPermissionSetInPlan.SetRange("Plan ID", PlanId);
        if DefaultPermissionSetInPlan.FindSet() then
            repeat
                Clear(CustomPermissionSetInPlan.Id);

                CustomPermissionSetInPlan.TransferFields(DefaultPermissionSetInPlan);
                CustomPermissionSetInPlan."Plan ID" := PlanId;
                CustomPermissionSetInPlan."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(CustomPermissionSetInPlan."Company Name"));

                if CustomPermissionSetInPlan.Insert() then;
            until DefaultPermissionSetInPlan.Next() = 0;
#if not CLEAN22
#pragma warning disable AL0432
        PlanConfiguration.OnAfterTransferPermissions(PlanId);
#pragma warning restore AL0432
#endif
    end;

    local procedure DeleteCustomizations(PlanId: Guid)
    var
        CustomPermissionSetInPlan: Record "Custom Permission Set In Plan";
#if not CLEAN22
        PlanConfiguration: Codeunit "Plan Configuration";
#endif
    begin
        CustomPermissionSetInPlan.SetRange("Plan ID", PlanId);
        CustomPermissionSetInPlan.DeleteAll();
#if not CLEAN22
#pragma warning disable AL0432
        PlanConfiguration.OnAfterDeleteCustomPermissions(PlanId);
#pragma warning restore AL0432
#endif
    end;

    [EventSubscriber(ObjectType::Page, Page::"Plan Configuration Card", OnAfterValidateEvent, Customized, false, false)]
    local procedure OnAfterConfigaritonCustomize(var Rec: Record "Plan Configuration")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        if not Rec.Customized then
            if not Confirm(ConfirmRemoveCustomizationsQst, false) then begin
                Rec.Customized := true;
                exit;
            end;

        TelemetryDimensions.Add('Customized', Format(Rec.Customized));
        TelemetryDimensions.Add('PlanId', Format(Rec."Plan ID", 0, 4));
        FeatureTelemetry.LogUptake('0000GLS', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::"Set up", TelemetryDimensions);

        Session.LogSecurityAudit(PlanConfigurationFeatureNameTok, SecurityOperationResult::Success,
            StrSubstNo(PlanConfigurationUpdatedLbl, Rec."Plan ID", Rec.Customized), AuditCategory::UserManagement);

        if Rec.Customized then
            TransferPermissions(Rec."Plan ID")
        else
            DeleteCustomizations(Rec."Plan ID");

        ShowCustomPermissionsEffectNotification(Rec);
    end;

    internal procedure ShowCustomPermissionsEffectNotification(PlanConfiguration: Record "Plan Configuration")
    var
        CustomizationNotification: Notification;
    begin
        PlanConfiguration.CalcFields("Plan Name");

        CustomizationNotification.Id := CustomizationNotificationIdTok;
        CustomizationNotification.Message(StrSubstNo(CustomizePermissionsNotificationTxt, PlanConfiguration."Plan Name"));
        CustomizationNotification.Scope := NotificationScope::LocalScope;

        CustomizationNotification.Recall(); // Do not show the notification twice

        if PlanConfiguration.Customized then
            CustomizationNotification.Send();
    end;

    internal procedure ShowDefaultConfigurationNotification()
    var
        DefaultConfigurationExistsNotification: Notification;
    begin
        DefaultConfigurationExistsNotification.Id := CreateGuid();
        DefaultConfigurationExistsNotification.Message(DefaultConfigurationNotificationTxt);
        DefaultConfigurationExistsNotification.AddAction(LearnMoreTok, Codeunit::"Plan Configuration Impl.", 'OpenDocumentation');
        DefaultConfigurationExistsNotification.Scope := NotificationScope::LocalScope;

        DefaultConfigurationExistsNotification.Send();
    end;

    internal procedure OpenDocumentation(Notification: Notification)
    begin
        Hyperlink(DocumentationLinkTxt);
    end;

    local procedure AddPermissionSetToAccessControl(UserSecurityId: Guid; RoleId: Code[20]; AppId: Guid; Scope: Option; Company: Text[30])
    var
        AccessControl: Record "Access Control";
        NullGuid: Guid;
    begin
        AccessControl.SetRange("User Security ID", UserSecurityID);
        AccessControl.SetRange("Role ID", RoleId);
        AccessControl.SetRange("Company Name", Company);
        AccessControl.SetRange(Scope, Scope);

        // SUPER and SECURITY always have null guids
        if RoleId in ['SUPER', 'SECURITY'] then
            AccessControl.SetRange("App ID", NullGuid)
        else
            // If scope is system and App ID is null, filter to non-null App IDs
            if (Scope = AccessControl.Scope::System) and IsNullGuid(AppId) then
                AccessControl.SetFilter("App ID", '<>%1', NullGuid)
            else
                AccessControl.SetRange("App ID", AppId);

        if AccessControl.IsEmpty() then begin
            AccessControl.Init();
            AccessControl."User Security ID" := UserSecurityID;
            AccessControl."Role ID" := RoleId;
            AccessControl."Company Name" := Company;
            AccessControl.Scope := Scope;
            AccessControl."App ID" := AppId;
            AccessControl.Insert();
        end;
    end;

    local procedure GetUserPlansAsFilter(UserSecurityId: Guid; ExcludePlanId: Guid; var PlanIdFilter: Text): Boolean
    var
        UserPlan: Record "User Plan";
        PlanIdFilterBuilder: TextBuilder;
    begin
        UserPlan.SetRange("User Security ID", UserSecurityId);
        UserPlan.SetFilter("Plan ID", '<>%1', ExcludePlanId); // allow deleting permissions for own plan
        if UserPlan.IsEmpty() then
            exit(false);

        repeat
            PlanIdFilterBuilder.Append(UserPlan."Plan ID");
            PlanIdFilterBuilder.Append('|');
        until UserPlan.Next() = 0;
        PlanIdFilter := PlanIdFilterBuilder.ToText().TrimEnd('|');
        exit(true);
    end;

    procedure LookupPermissionSet(AllowMultiselect: Boolean; var CustomPermissionSetInPlan: Record "Custom Permission Set In Plan"; var PermissionSetLookupRecord: Record "Aggregate Permission Set"): Boolean
    var
        PermissionSetRelation: Codeunit "Permission Set Relation";
    begin
        if PermissionSetRelation.LookupPermissionSet(AllowMultiselect, PermissionSetLookupRecord) then begin
            CustomPermissionSetInPlan.Scope := PermissionSetLookupRecord.Scope;
            CustomPermissionSetInPlan."App ID" := PermissionSetLookupRecord."App ID";
            CustomPermissionSetInPlan."Role ID" := PermissionSetLookupRecord."Role ID";
            CustomPermissionSetInPlan.CalcFields("App Name", "Role Name");
            exit(true);
        end;
        exit(false);
    end;

    internal procedure OpenBCAdminCenter()
    begin
        Hyperlink(BCAdminCenterUrl());
    end;

    internal procedure OpenM365AdminCenter()
    begin
        Hyperlink(M365AdminCenterLinkTxt);
    end;

    local procedure BCAdminCenterUrl(): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        Url: Text;
    begin
        Url := GetUrl(ClientType::Web);
        if EnvironmentInformation.IsSaaS() then
            exit(StrSubstNo(BCAdminCenterSaaSLinkTxt, CopyStr(Url, 1, Url.LastIndexOf('/') - 1))) // Remove environment segment from URL
        else
            exit(StrSubstNo(BCAdminCenterOnPremLinkTxt, Url, AzureADTenant.GetAadTenantId())); // Add tenant ID segment to URL
    end;

    [EventSubscriber(ObjectType::Table, Database::"Plan Configuration", OnAfterDeleteEvent, '', false, false)]
    local procedure DeleteCustomPermissionSet(var Rec: Record "Plan Configuration")
    begin
        DeleteCustomizations(Rec."Plan ID")
    end;

    #region Install/Upgrade
    procedure CreateDefaultPlanConfigurations()
    var
        PlanConfiguration: Record "Plan Configuration";
        Plan: Query Plan;
    begin
        if Plan.Open() then
            while Plan.Read() do begin
                PlanConfiguration.SetRange("Plan ID", Plan.Plan_ID);

                if PlanConfiguration.IsEmpty() then begin
                    PlanConfiguration.Init();
                    PlanConfiguration."Plan ID" := Plan.Plan_ID;
                    PlanConfiguration."Plan Name" := Plan.Plan_Name;
                    PlanConfiguration.Insert();
                end;

                Clear(PlanConfiguration);
            end;
    end;
    #endregion

    #region Telemetry
    [EventSubscriber(ObjectType::Page, Page::"Plan Configuration Card", OnOpenPageEvent, '', false, false)]
    local procedure LogFeatureTelemetryPlanConfigurationCard()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GLQ', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::Discovered);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Plan Configuration List", OnOpenPageEvent, '', false, false)]
    local procedure LogFeatureTelemetryPlanConfigurationList()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GLR', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::Discovered);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Custom Permission Set In Plan", OnAfterDeleteEvent, '', false, false)]
    local procedure LogTelemeteryOnDeleteCustomPermissioSet(var Rec: Record "Custom Permission Set In Plan")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        Session.LogSecurityAudit(PlanConfigurationFeatureNameTok, SecurityOperationResult::Success,
            StrSubstNo(CustomPermissionSetInPlanRemovedLbl, StrSubstNo(CustomPermissionSetLbl, Rec."Role ID", Rec."App ID", Rec.Scope, Rec."Company Name", Rec."Plan ID")), AuditCategory::UserManagement);
        FeatureTelemetry.LogUptake('0000GLT', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::"Set up", GetTelemetryDimensions(Rec, false));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Custom Permission Set In Plan", OnAfterInsertEvent, '', false, false)]
    local procedure LogTelemeteryOnInsertCustomPermissioSet(var Rec: Record "Custom Permission Set In Plan")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GLU', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::"Set up", GetTelemetryDimensions(Rec, true));

        Session.LogSecurityAudit(PlanConfigurationFeatureNameTok, SecurityOperationResult::Success,
            StrSubstNo(CustomPermissionSetInPlanAddedLbl, StrSubstNo(CustomPermissionSetLbl, Rec."Role ID", Rec."App ID", Rec.Scope, Rec."Company Name", Rec."Plan ID")), AuditCategory::UserManagement);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Custom Permission Set In Plan", OnAfterModifyEvent, '', false, false)]
    local procedure LogTelemeteryOnModifyCustomPermissioSet(var Rec: Record "Custom Permission Set In Plan"; var xRec: Record "Custom Permission Set In Plan")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GLO', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::"Set up", GetTelemetryDimensions(Rec, true));
        FeatureTelemetry.LogUptake('0000GPU', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::"Set up", GetTelemetryDimensions(xRec, false));

        Session.LogSecurityAudit(PlanConfigurationFeatureNameTok, SecurityOperationResult::Success,
            StrSubstNo(CustomPermissionSetInPlanModifiedLbl, StrSubstNo(CustomPermissionSetLbl, xRec."Role ID", xRec."App ID", xRec.Scope, xRec."Company Name", xRec."Plan ID"),
            StrSubstNo(CustomPermissionSetLbl, Rec."Role ID", Rec."App ID", Rec.Scope, Rec."Company Name", Rec."Plan ID")), AuditCategory::UserManagement);
    end;

    local procedure GetTelemetryDimensions(CustomPermissionSetInPlan: Record "Custom Permission Set In Plan"; PermissionSetAdded: Boolean) TelemetryDimensions: Dictionary of [Text, Text]
    begin
        Clear(TelemetryDimensions);

        TelemetryDimensions.Add('PlanId', Format(CustomPermissionSetInPlan."Plan ID", 0, 4));
        if CustomPermissionSetInPlan.Scope = CustomPermissionSetInPlan.Scope::System then
            TelemetryDimensions.Add('PermissionSetId', CustomPermissionSetInPlan."Role ID"); // only emit the permission set ID in the permission set was defined through code
        TelemetryDimensions.Add('PermissionSetAppId', Format(CustomPermissionSetInPlan."App ID", 0, 4));
        TelemetryDimensions.Add('PermissionSetScope', Format(CustomPermissionSetInPlan.Scope));
        TelemetryDimensions.Add('PermissionSetCompany', CustomPermissionSetInPlan."Company Name");
        TelemetryDimensions.Add('PermissionSetAdded', Format(PermissionSetAdded));
    end;
    #endregion
}