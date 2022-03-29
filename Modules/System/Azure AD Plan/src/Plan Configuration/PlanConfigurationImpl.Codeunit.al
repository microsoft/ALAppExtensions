// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9822 "Plan Configuration Impl."
{
    Access = Internal;

    Permissions = tabledata "Plan Configuration" = rimd,
                  tabledata "Custom Permission Set In Plan" = rimd;

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
        AccessControl: Record "Access Control";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        AccessControlExists: Boolean;
        NullGuid: Guid;
    begin
        FeatureTelemetry.LogUptake('0000GLO', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::Used);

        CustomPermissionSetInPlan.SetRange("Plan ID", PlanId);
        if not CustomPermissionSetInPlan.FindSet() then
            exit;

        repeat
            FeatureTelemetry.LogUsage('0000GMJ', PlanConfigurationFeatureNameTok, PermissionSetAssignedToUserTxt, GetTelemetryDimensions(CustomPermissionSetInPlan, true));

            AccessControl.SetRange("User Security ID", UserSecurityID);
            AccessControl.SetRange("Role ID", CustomPermissionSetInPlan."Role ID");
            AccessControl.SetRange("Company Name", CustomPermissionSetInPlan."Company Name");
            AccessControl.SetRange(Scope, CustomPermissionSetInPlan.Scope);

            // SUPER and SECURITY always have null guids
            if CustomPermissionSetInPlan."Role ID" in ['SUPER', 'SECURITY'] then
                AccessControl.SetRange("App ID", NullGuid)
            else
                // If scope is system and App ID is null, filter to non-null App IDs
                if (CustomPermissionSetInPlan.Scope = AccessControl.Scope::System) and IsNullGuid(CustomPermissionSetInPlan."App ID") then
                    AccessControl.SetFilter("App ID", '<>%1', NullGuid)
                else
                    AccessControl.SetRange("App ID", CustomPermissionSetInPlan."App ID");

            AccessControlExists := not AccessControl.IsEmpty();
            if not AccessControlExists then begin
                AccessControl.Init();
                AccessControl."User Security ID" := UserSecurityID;
                AccessControl."Role ID" := CustomPermissionSetInPlan."Role ID";
                AccessControl."Company Name" := CustomPermissionSetInPlan."Company Name";
                AccessControl.Scope := CustomPermissionSetInPlan.Scope;
                AccessControl."App ID" := CustomPermissionSetInPlan."App ID";
                AccessControl.Insert();
            end;

        until CustomPermissionSetInPlan.Next() = 0;
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

    [IntegrationEvent(false, false)]
    internal procedure OnPermissionSetChange(PlanId: Guid; RoleId: Code[20]; AppId: Guid; Scope: Option; Company: Text[30]);
    begin
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

    procedure SelectLicense(var PlanConfiguration: Record "Plan Configuration")
    var
        PlanConfigurationRec: Record "Plan Configuration";
        Plans: Page Plans;
        SelectedPlanId: Guid;
        SelectedPlanName: Text[50];
    begin
        Plans.LookupMode(true);
        Plans.SetSelectedPlan(PlanConfiguration."Plan ID");

        if Plans.RunModal() = Action::LookupOK then begin
            Plans.GetSelectedPlan(SelectedPlanId, SelectedPlanName);

            PlanConfigurationRec.SetRange("Plan ID", SelectedPlanId);
            if not PlanConfigurationRec.IsEmpty() then
                Error(ConfigurationAlreadyExistsErr, SelectedPlanName);

            PlanConfiguration."Plan ID" := SelectedPlanId;
            PlanConfiguration."Plan Name" := SelectedPlanName;
        end;
    end;

    local procedure TransferPermissions(PlanId: Guid)
    var
        CustomPermissionSetInPlan: Record "Custom Permission Set In Plan";
        DefaultPermissionSetInPlan: Record "Default Permission Set In Plan";
        DefaultPermissionSetInPlanController: Codeunit "Default Permission Set In Plan";
        PlanConfiguration: Codeunit "Plan Configuration";
    begin
        DefaultPermissionSetInPlanController.GetPermissionSets(PlanId, DefaultPermissionSetInPlan);

        if DefaultPermissionSetInPlan.FindSet() then
            repeat
                Clear(CustomPermissionSetInPlan.Id);

                CustomPermissionSetInPlan.TransferFields(DefaultPermissionSetInPlan);
                CustomPermissionSetInPlan."Plan ID" := PlanId;
                CustomPermissionSetInPlan."Company Name" := StrSubstNo(CompanyName(), MaxStrLen(CustomPermissionSetInPlan."Company Name"));

                if CustomPermissionSetInPlan.Insert() then;
            until DefaultPermissionSetInPlan.Next() = 0;

        PlanConfiguration.OnAfterTransferPermissions(PlanId);
    end;

    local procedure DeleteCustomizations(PlanId: Guid)
    var
        CustomPermissionSetInPlan: Record "Custom Permission Set In Plan";
        PlanConfiguration: Codeunit "Plan Configuration";
    begin
        CustomPermissionSetInPlan.SetRange("Plan ID", PlanId);
        CustomPermissionSetInPlan.DeleteAll();

        PlanConfiguration.OnAfterDeleteCustomPermissions(PlanId);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Plan Configuration Card", 'OnAfterValidateEvent', 'Customized', false, false)]
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
        FeatureTelemetry.LogUptake('0000GLS', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::"Set up", false, TelemetryDimensions);

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

    [EventSubscriber(ObjectType::Table, Database::"Plan Configuration", 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteCustomPermissionSet(var Rec: Record "Plan Configuration")
    begin
        DeleteCustomizations(Rec."Plan ID")
    end;

    #region Telemetry
    [EventSubscriber(ObjectType::Page, Page::"Plan Configuration Card", 'OnOpenPageEvent', '', false, false)]
    local procedure LogFeatureTelemetryPlanConfigurationCard()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GLQ', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::Discovered);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Plan Configuration List", 'OnOpenPageEvent', '', false, false)]
    local procedure LogFeatureTelemetryPlanConfigurationList()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GLR', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::Discovered);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Custom Permission Set In Plan", 'OnAfterDeleteEvent', '', false, false)]
    local procedure LogTelemeteryOnDeleteCustomPermissioSet(var Rec: Record "Custom Permission Set In Plan")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        Session.LogSecurityAudit(PlanConfigurationFeatureNameTok, SecurityOperationResult::Success,
            StrSubstNo(CustomPermissionSetInPlanRemovedLbl, StrSubstNo(CustomPermissionSetLbl, Rec."Role ID", Rec."App ID", Rec.Scope, Rec."Company Name", Rec."Plan ID")), AuditCategory::UserManagement);
        FeatureTelemetry.LogUptake('0000GLT', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::"Set up", false, GetTelemetryDimensions(Rec, false));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Custom Permission Set In Plan", 'OnAfterInsertEvent', '', false, false)]
    local procedure LogTelemeteryOnInsertCustomPermissioSet(var Rec: Record "Custom Permission Set In Plan")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GLU', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::"Set up", false, GetTelemetryDimensions(Rec, true));

        Session.LogSecurityAudit(PlanConfigurationFeatureNameTok, SecurityOperationResult::Success,
            StrSubstNo(CustomPermissionSetInPlanAddedLbl, StrSubstNo(CustomPermissionSetLbl, Rec."Role ID", Rec."App ID", Rec.Scope, Rec."Company Name", Rec."Plan ID")), AuditCategory::UserManagement);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Custom Permission Set In Plan", 'OnAfterModifyEvent', '', false, false)]
    local procedure LogTelemeteryOnModifyCustomPermissioSet(var Rec: Record "Custom Permission Set In Plan"; var xRec: Record "Custom Permission Set In Plan")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GLO', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::"Set up", false, GetTelemetryDimensions(Rec, true));
        FeatureTelemetry.LogUptake('0000GPU', PlanConfigurationFeatureNameTok, Enum::"Feature Uptake Status"::"Set up", false, GetTelemetryDimensions(xRec, false));

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

    var
        ConfirmRemoveCustomizationsQst: Label 'Restoring the default permissions will delete the customization for the selected license. Do you want to continue?';
        ConfigurationAlreadyExistsErr: Label 'Configration for license %1 already exists. To edit it, select it from the list.', Comment = '%1 = License name, e.g. Dynamics 365 Business Central Essentials';
        MissingSecurityErr: Label 'You do not have permissions to configure licenses. Contact your system administrator.';
        MissingPermissionSetErr: Label 'You don''t have rights to manage the %1 permission set for licenses. The SECURITY permission set only grants you rights to manage those permission sets that are also assigned to your account.', Comment = '%1 = permssion set name, e.g. ''D365 READ''';
        CustomizePermissionsNotificationTxt: Label 'Customizing permissions below will affect only newly created user who are assigned %1 license. Permissions for existing users who are assigned the license will not be affected.', Comment = '%1 = license name, e.g. e.g. Dynamics 365 Business Central Essentials';
        DefaultConfigurationNotificationTxt: Label 'One or more of the license configurations use implicit company permissions, which is not recommended.';
        LearnMoreTok: Label 'Learn more';
        DocumentationLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2186490', Locked = true;
        CustomizationNotificationIdTok: Label '9d730988-ff4a-43ca-8b4f-80ee476fa3c4', Locked = true;
        PlanConfigurationFeatureNameTok: Label 'Custom Permissions Assignment Per Plan', Locked = true;
        PermissionSetAssignedToUserTxt: Label 'Custom Permission Set Assigned To User', Locked = true;
        CustomPermissionSetLbl: Label 'role id %1, app id %2, scope %3, company %4 and plan %5', Locked = true;
        CustomPermissionSetInPlanAddedLbl: Label 'Custom Permission Set In Plan was added with %1.', Locked = true;
        CustomPermissionSetInPlanRemovedLbl: Label 'Custom Permission Set In Plan was removed with %1.', Locked = true;
        CustomPermissionSetInPlanModifiedLbl: Label 'Custom Permission Set In Plan was modified from %1 to %2.', Locked = true;
        PlanConfigurationUpdatedLbl: Label 'Plan Configuration was modified for plan %1. Customized: %2.', Locked = true;
}