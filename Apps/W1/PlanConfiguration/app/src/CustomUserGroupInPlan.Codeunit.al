// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9059 "Custom User Group In Plan"
{
    Access = Internal;
    Permissions = tabledata "User Group Permission Set" = r,
                  tabledata "User Group Plan" = r,
                  tabledata "Custom User Group In Plan" = rimd;

    internal procedure VerifyUserHasRequiredUserGroup(UserGroupCode: Code[20]; SelectedCompany: Text)
    var
        UserGroupPermissionSet: Record "User Group Permission Set";
        PlanConfiguration: Codeunit "Plan Configuration";
    begin
        UserGroupPermissionSet.SetRange("User Group Code", UserGroupCode);
        if UserGroupPermissionSet.FindSet() then
            repeat
                PlanConfiguration.VerifyUserHasRequiredPermissionSet(UserGroupPermissionSet."Role ID", UserGroupPermissionSet."App ID", UserGroupPermissionSet.Scope, SelectedCompany);
            until UserGroupPermissionSet.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Plan Configuration", 'OnAfterTransferPermissions', '', false, false)]
    local procedure TransferUserGroups(PlanId: Guid)
    var
        UserGroupPlan: Record "User Group Plan";
        CustomUserGroupsInPlan: Record "Custom User Group In Plan";
    begin
        UserGroupPlan.SetRange("Plan ID", PlanId);

        if UserGroupPlan.FindSet() then
            repeat
                Clear(CustomUserGroupsInPlan.Id);
                CustomUserGroupsInPlan."Plan ID" := UserGroupPlan."Plan ID";
                CustomUserGroupsInPlan."User Group Code" := UserGroupPlan."User Group Code";
                CustomUserGroupsInPlan."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(CustomUserGroupsInPlan."Company Name"));

                if CustomUserGroupsInPlan.Insert() then;
            until UserGroupPlan.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Plan Configuration", 'OnAfterDeleteCustomPermissions', '', false, false)]
    local procedure DeleteCustomUserGroups(PlanId: Guid)
    var
        CustomUserGroupsInPlan: Record "Custom User Group In Plan";
    begin
        CustomUserGroupsInPlan.SetRange("Plan ID", PlanId);
        CustomUserGroupsInPlan.DeleteAll();
    end;

    local procedure AssignCustomPermissionsToUserForPlan(UserSecurityID: Guid; PlanID: Guid): Boolean
    var
        CustomUserGroupInPlan: Record "Custom User Group In Plan";
        PlanConfiguration: Codeunit "Plan Configuration";
        PermissionManager: Codeunit "Permission Manager";
    begin
        // If no custom assignments, add system default user groups
        if not PlanConfiguration.IsCustomized(PlanID) then
            exit(false); // nothing to add

        // Add custom assignments
        CustomUserGroupInPlan.SetRange("Plan ID", PlanID);
        if CustomUserGroupInPlan.FindSet() then
            repeat
                PermissionManager.AddUserToUserGroup(UserSecurityID, CustomUserGroupInPlan."User Group Code", CustomUserGroupInPlan."Company Name");
            until CustomUserGroupInPlan.Next() = 0;

        PlanConfiguration.AssignCustomPermissionsToUser(PlanID, UserSecurityID);

        exit(true);
    end;

    procedure AddPermissionSetsFromUserGroup(CustomUserGroupInPlan: Record "Custom User Group In Plan")
    var
        UserGroupPermissionSet: Record "User Group Permission Set";
        PlanConfiguration: Codeunit "Plan Configuration";
    begin
        // Add permission sets related to the user group
        UserGroupPermissionSet.SetRange("User Group Code", CustomUserGroupInPlan."User Group Code");
        if UserGroupPermissionSet.FindSet() then
            repeat
                PlanConfiguration.AddCustomPermissionSetToPlan(CustomUserGroupInPlan."Plan ID", UserGroupPermissionSet."Role ID", UserGroupPermissionSet."App ID", UserGroupPermissionSet.Scope, CustomUserGroupInPlan."Company Name");
            until UserGroupPermissionSet.Next() = 0;
    end;

    procedure RemovePermissionSetsFromUserGroup(CustomUserGroupInPlan: Record "Custom User Group In Plan")
    var
        AllUserGroupPermissionSet: Record "User Group Permission Set";
        AssignedUserGroupPermissionSet: Record "User Group Permission Set";
        AssignedCustomUserGroupInPlan: Record "Custom User Group In Plan";
        PlanConfiguration: Codeunit "Plan Configuration";
        CountReferences: Integer;
        ShouldDeleteCustomPermissions: Boolean;
    begin
        // Remove permission sets related to the user group
        AllUserGroupPermissionSet.SetRange("User Group Code", CustomUserGroupInPlan."User Group Code");
        if AllUserGroupPermissionSet.FindSet() then
            repeat
                CountReferences := 0;

                AssignedCustomUserGroupInPlan.SetRange("Plan ID", CustomUserGroupInPlan."Plan ID");
                AssignedCustomUserGroupInPlan.SetRange("Company Name", CustomUserGroupInPlan."Company Name");
                if AssignedCustomUserGroupInPlan.FindSet() then
                    repeat
                        AssignedUserGroupPermissionSet.SetRange("User Group Code", AssignedCustomUserGroupInPlan."User Group Code");
                        AssignedUserGroupPermissionSet.SetRange("Role ID", AllUserGroupPermissionSet."Role ID");
                        AssignedUserGroupPermissionSet.SetRange("App ID", AllUserGroupPermissionSet."App ID");
                        AssignedUserGroupPermissionSet.SetRange(Scope, AllUserGroupPermissionSet.Scope);

                        if not AssignedUserGroupPermissionSet.IsEmpty() then
                            CountReferences := CountReferences + 1;

                    until AssignedCustomUserGroupInPlan.Next() = 0;

                ShouldDeleteCustomPermissions := CountReferences <= 1;

                if ShouldDeleteCustomPermissions then
                    PlanConfiguration.RemoveCustomPermissionSetFromPlan(CustomUserGroupInPlan."Plan ID", AllUserGroupPermissionSet."Role ID", AllUserGroupPermissionSet."App ID", AllUserGroupPermissionSet.Scope, CustomUserGroupInPlan."Company Name");
            until AllUserGroupPermissionSet.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Plan Configuration", 'OnCustomPermissionSetChange', '', false, false)]
    local procedure CheckAssignedUserGroups(PlanId: Guid; RoleId: COde[20]; Scope: Option; AppId: Guid; Company: Text[30])
    var
        AssignedCustomUserGroupsInLicense: Record "Custom User Group In Plan";
        AssignedUserGroupPermissionSets: Record "User Group Permission Set";
        AssignedUserGroupsTxt: TextBuilder;
        ErrorTxt: Text;
    begin
        AssignedCustomUserGroupsInLicense.SetRange("Plan ID", PlanId);
        AssignedCustomUserGroupsInLicense.SetRange("Company Name", Company);

        if not AssignedCustomUserGroupsInLicense.FindSet() then
            exit;

        repeat
            AssignedUserGroupPermissionSets.Reset();
            AssignedUserGroupPermissionSets.SetRange("User Group Code", AssignedCustomUserGroupsInLicense."User Group Code");
            AssignedUserGroupPermissionSets.SetRange("Role ID", RoleId);
            AssignedUserGroupPermissionSets.SetRange(Scope, Scope);
            AssignedUserGroupPermissionSets.SetRange("App ID", AppId);

            if not AssignedUserGroupPermissionSets.IsEmpty() then begin
                AssignedUserGroupsTxt.Append(AssignedCustomUserGroupsInLicense."User Group Code");
                AssignedUserGroupsTxt.Append(', ');
            end;
        until AssignedCustomUserGroupsInLicense.Next() = 0;

        if AssignedUserGroupsTxt.Length() > 0 then begin
            AssignedUserGroupsTxt.Remove(AssignedUserGroupsTxt.Length() - 1, 2); // remove the last comma (,)
            ErrorTxt := StrSubstNo(PermissionSetInUserGroupErr, RoleId, AssignedUserGroupsTxt.ToText());
            Error(ErrorTxt);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Permission Manager", 'OnAssignCustomPermissionsToUser', '', true, true)]
    local procedure OnAssignPermissionsForUser(UserSecurityID: Guid; PlanId: Guid; var PermissionsAssigned: Boolean)
    begin
        if AssignCustomPermissionsToUserForPlan(UserSecurityID, PlanId) then
            PermissionsAssigned := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Default Permission Set In Plan", 'OnGetDefaultPermissions', '', false, false)]
    local procedure AddDefaultPermissionsInPlan(PlanId: Guid; var Sender: Codeunit "Default Permission Set In Plan")
    var
        UserGroupPlan: Record "User Group Plan";
        UserGroupPermissionSet: Record "User Group Permission Set";
    begin
        UserGroupPlan.SetRange("Plan ID", PlanId);

        if not UserGroupPlan.FindSet() then
            exit;

        repeat
            UserGroupPermissionSet.SetRange("User Group Code", UserGroupPlan."User Group Code");

            if UserGroupPermissionSet.FindSet() then
                repeat
                    Sender.AddPermissionSetToPlan(UserGroupPermissionSet."Role ID", UserGroupPermissionSet."App ID", UserGroupPermissionSet.Scope);
                until UserGroupPermissionSet.Next() = 0;
        until UserGroupPlan.Next() = 0;
    end;

    #region Telemetry
    [EventSubscriber(ObjectType::Table, Database::"Custom User Group In Plan", 'OnAfterDeleteEvent', '', false, false)]
    local procedure LogTelemeteryOnDeleteCustomUserGroup(var Rec: Record "Custom User Group In Plan")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GLM', PlanConfigurationFeatureNameTxt, Enum::"Feature Uptake Status"::"Set up", false, GetTelemetryDimensions(Rec, false));

        Session.LogSecurityAudit(PlanConfigurationFeatureNameTxt, SecurityOperationResult::Success,
            StrSubstNo(CustomUserGroupInPlanRemovedLbl, Rec."User Group Code", Rec."Company Name", Rec."Plan ID"), AuditCategory::UserManagement);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Custom User Group In Plan", 'OnAfterInsertEvent', '', false, false)]
    local procedure LogTelemeteryOnInsertCustomUserGroup(var Rec: Record "Custom User Group In Plan")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GLN', PlanConfigurationFeatureNameTxt, Enum::"Feature Uptake Status"::"Set up", false, GetTelemetryDimensions(Rec, true));

        Session.LogSecurityAudit(PlanConfigurationFeatureNameTxt, SecurityOperationResult::Success,
            StrSubstNo(CustomUserGroupInPlanAddedLbl, Rec."User Group Code", Rec."Company Name", Rec."Plan ID"), AuditCategory::UserManagement);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Custom User Group In Plan", 'OnAfterModifyEvent', '', false, false)]
    local procedure LogTelemeteryOnModifyCustomUserGroup(var Rec: Record "Custom User Group In Plan"; var xRec: Record "Custom User Group In Plan")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GLO', PlanConfigurationFeatureNameTxt, Enum::"Feature Uptake Status"::"Set up", false, GetTelemetryDimensions(Rec, true));
        FeatureTelemetry.LogUptake('0000GPU', PlanConfigurationFeatureNameTxt, Enum::"Feature Uptake Status"::"Set up", false, GetTelemetryDimensions(xRec, false));

        Session.LogSecurityAudit(PlanConfigurationFeatureNameTxt, SecurityOperationResult::Success,
            StrSubstNo(CustomUserGroupInPlanModifiedLbl, xRec."User Group Code", xRec."Company Name", xRec."Plan ID", Rec."User Group Code", Rec."Company Name", Rec."Plan ID"), AuditCategory::UserManagement);
    end;

    local procedure GetTelemetryDimensions(CustomUserGroupInPlan: Record "Custom User Group In Plan"; UserGroupAdded: Boolean) TelemetryDimensions: Dictionary of [Text, Text]
    begin
        Clear(TelemetryDimensions);

        TelemetryDimensions.Add('PlanId', Format(CustomUserGroupInPlan."Plan ID", 0, 4));
        TelemetryDimensions.Add('UserGroupCompany', CustomUserGroupInPlan."Company Name");
        TelemetryDimensions.Add('UserGroupAdded', Format(UserGroupAdded));
    end;
    #endregion

    var
        PermissionSetInUserGroupErr: Label 'The permission set %1 is contained in the user group %2. The line cannot be modified.', Comment = '%1 = permssion set name like ''D365 READ''; %2 = list of user group names like ''D365 TEAM MEMBER''';
        PlanConfigurationFeatureNameTxt: Label 'Custom Permissions Assignment Per Plan', Locked = true;
        CustomUserGroupInPlanAddedLbl: Label 'Custom User Group In Plan was added with user group %1, company %2 and plan %3.', Locked = true;
        CustomUserGroupInPlanRemovedLbl: Label 'Custom User Group In Plan was removed with user group %1, company %2 and plan %3', Locked = true;
        CustomUserGroupInPlanModifiedLbl: Label 'Custom User Group In Plan was modified from user group %1, company %2 and plan %3 to user group %4, company %5 and plan %6.', Locked = true;
}