// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Implementation codeunit that provides functions for copying permission sets, including/excluding permission sets and getting the permission set tree.
/// </summary>
codeunit 9856 "Permission Set Relation Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        TempPermissionSetRelationBufferList: Record "Permission Set Relation Buffer" temporary;
        TempPermissionSetRelationBufferTree: Record "Permission Set Relation Buffer" temporary;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        PermissionTypeOption: Option Include,Exclude;
        CannotChangeExtensionPermissionErr: Label 'You cannot change permissions sets of type Extension.';
        CannotManagePermissionsErr: Label 'Only users with the SUPER or the SECURITY permission set can create or edit permission sets.';
        CannotIncludeItselfErr: Label 'You cannot include the permission set you are currently modifying.';
        CannotExcludeItselfErr: Label 'You cannot exclude the permission set you are currently modifying.';
        PermissionSetAlreadyIncludedErr: Label 'The %1 permission set is already included.', Comment = '%1 - the role ID of the permission set';
        PermissionSetAlreadyExcludedErr: Label 'The %1 permission set is already excluded.', Comment = '%1 - the role ID of the permission set';
        RoleIdTok: Label '%1 (%2)', Locked = true;
        ComposablePermissionSetsTok: Label 'Composable Permission Sets', Locked = true;

    procedure AddPermissionSetRelationBufferList(var PermissionSetRelationBuffer: Record "Permission Set Relation Buffer" temporary)
    begin
        TempPermissionSetRelationBufferList.Copy(PermissionSetRelationBuffer, true);
    end;

    procedure AddPermissionSetRelationBufferTree(var PermissionSetRelationBuffer: Record "Permission Set Relation Buffer" temporary)
    begin
        TempPermissionSetRelationBufferTree.Copy(PermissionSetRelationBuffer, true);
    end;

    procedure OpenPermissionSetPage(Name: Text; RoleId: Code[30]; AppId: Guid; Scope: Option System,Tenant)
    var
        TempPermissionSetBuffer: Record "PermissionSet Buffer" temporary;
    begin
        TempPermissionSetBuffer.Init();
        TempPermissionSetBuffer."App ID" := AppId;
        TempPermissionSetBuffer."Role ID" := RoleId;
        TempPermissionSetBuffer.Scope := Scope;
        Page.Run(Page::"Permission Set", TempPermissionSetBuffer);
    end;

    procedure VerifyUserCanEditPermissionSet(AppID: Guid)
    var
        UserPermissions: Codeunit "User Permissions";
    begin
        if not IsNullGuid(AppID) then
            Error(CannotChangeExtensionPermissionErr);

        if not UserPermissions.CanManageUsersOnTenant(UserSecurityId()) then
            Error(CannotManagePermissionsErr);
    end;

    procedure SelectPermissionSets(CurrAppId: Guid; CurrRoleID: Code[30]; CurrScope: Option System,Tenant): Boolean
    var
        TempAggregatePermissionSet: Record "Aggregate Permission Set" temporary;
        PermissionType: Option Include,Exclude;
    begin
        VerifyUserCanEditPermissionSet(CurrAppId);

        if not LookupPermissionSet(true, TempAggregatePermissionSet) then
            exit(false);

        if TempAggregatePermissionSet.FindSet() then
            repeat
                AddNewPermissionSet(CurrAppId, CurrRoleID, CurrScope, TempAggregatePermissionSet."App ID", TempAggregatePermissionSet."Role ID", TempAggregatePermissionSet.Scope, PermissionType::Include)
            until TempAggregatePermissionSet.Next() = 0;

        exit(ValidatePermissionSet(CurrAppId, CurrRoleID, CurrScope))
    end;

    procedure AddNewPermissionSetRelation(CurrAppId: Guid; CurrRoleID: Code[30]; CurrScope: Option System,Tenant; RelatedAppId: Guid; RelatedRoleId: Code[30]; RelatedScope: Option System,Tenant; PermissionType: Option Include,Exclude) Success: Boolean
    begin
        VerifyUserCanEditPermissionSet(CurrAppId);

        exit(AddNewPermissionSet(CurrAppId, CurrRoleID, CurrScope, RelatedAppId, RelatedRoleId, RelatedScope, PermissionType));
    end;

    procedure ModifyPermissionSet(CurrAppId: Guid; CurrRoleID: Code[30]; CurrScope: Option System,Tenant; RelatedAppId: Guid; RelatedRoleId: Code[30]; PermissionType: Option Include,Exclude): Boolean
    var
        TempAggregatePermissionSet: Record "Aggregate Permission Set" temporary;
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
    begin
        VerifyUserCanEditPermissionSet(CurrAppId);

        if not LookupPermissionSet(false, TempAggregatePermissionSet) then
            exit(false);

        if TenantPermissionSetRel.Get(CurrAppId, CurrRoleID, RelatedAppId, RelatedRoleId) then
            TenantPermissionSetRel.Delete();

        exit(AddNewPermissionSet(CurrAppId, CurrRoleID, CurrScope, TempAggregatePermissionSet."App ID", TempAggregatePermissionSet."Role ID", TempAggregatePermissionSet.Scope, PermissionType));
    end;

    procedure ModifyPermissionSetType(CurrAppId: Guid; CurrRoleID: Code[30]; CurrScope: Option System,Tenant; RelatedAppId: Guid; RelatedRoleID: Code[30]; PermissionType: Option Include,Exclude): Boolean
    var
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
    begin
        VerifyUserCanEditPermissionSet(CurrAppId);

        if TenantPermissionSetRel.Get(CurrAppId, CurrRoleID, RelatedAppId, RelatedRoleID) then begin
            if TenantPermissionSetRel.Type = PermissionType then
                exit(false);

            TenantPermissionSetRel.Type := PermissionType;
            TenantPermissionSetRel.Modify();
        end;

        exit(ValidatePermissionSet(CurrAppId, CurrRoleID, CurrScope));
    end;

    procedure ExcludePermissionSet(CurrAppId: Guid; CurrRoleID: Code[30]; CurrScope: Option System,Tenant; RelatedAppId: Guid; RelatedRoleID: Code[30]; RelatedScope: Option System,Tenant; PermissionType: Option Include,Exclude): Boolean
    var
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
    begin
        VerifyUserCanEditPermissionSet(CurrAppId);

        if TenantPermissionSetRel.Get(CurrAppId, CurrRoleID, RelatedAppId, RelatedRoleId) then
            exit(ModifyPermissionSetType(CurrAppId, CurrRoleID, CurrScope, RelatedAppId, RelatedRoleID, PermissionType))
        else
            exit(AddNewPermissionSet(CurrAppId, CurrRoleID, CurrScope, RelatedAppId, RelatedRoleID, RelatedScope, PermissionType));
    end;

    procedure RemovePermissionSet(CurrAppId: Guid; CurrRoleID: Code[30]; RelatedAppId: Guid; RelatedRoleID: Code[30])
    var
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
    begin
        VerifyUserCanEditPermissionSet(CurrAppId);

        if TenantPermissionSetRel.Get(CurrAppId, CurrRoleId, RelatedAppId, RelatedRoleID) then
            TenantPermissionSetRel.Delete();
    end;

    procedure RefreshPermissionSets(RoleId: Code[30]; AppId: Guid; Scope: Option)
    begin
        RefreshPermissionSetList(RoleId, AppId, Scope, TempPermissionSetRelationBufferList);
        RefreshPermissionSetTree(RoleId, AppId, Scope, TempPermissionSetRelationBufferTree);
    end;

    procedure RefreshPermissionSetList(RoleId: Code[30]; AppId: Guid; Scope: Option Tenant,System; var PermissionSetRelationBuffer: Record "Permission Set Relation Buffer" temporary)
    var
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
        MetadataPermissionSetRel: Record "Metadata Permission Set Rel.";
        UserAccountHelper: DotNet NavUserAccountHelper;
        PermissionSetRelationArray: DotNet NavPermissionSetRelationArray;
    begin
        PermissionSetRelationBuffer.DeleteAll();
        PermissionSetRelationArray := UserAccountHelper.GetPermissionSetRelations(RoleId, AppId, Scope, GetMaxTreeLevel());

        TenantPermissionSetRel.SetRange("Role ID", RoleId);
        TenantPermissionSetRel.SetRange("App ID", AppId);
        MetaDataPermissionSetRel.SetRange("Role ID", RoleId);
        MetaDataPermissionSetRel.SetRange("App ID", AppId);

        if TenantPermissionSetRel.FindSet() then
            repeat
                PermissionSetRelationBuffer.Init();
                PermissionSetRelationBuffer."App ID" := TenantPermissionSetRel."App ID";
                PermissionSetRelationBuffer."Role ID" := TenantPermissionSetRel."Role ID";
                PermissionSetRelationBuffer."Related App ID" := TenantPermissionSetRel."Related App ID";
                PermissionSetRelationBuffer."Related Role ID" := TenantPermissionSetRel."Related Role ID";
                PermissionSetRelationBuffer."Related Scope" := TenantPermissionSetRel."Related Scope";
                PermissionSetRelationBuffer.Type := TenantPermissionSetRel.Type;
                PermissionSetRelationBuffer.Insert();
            until TenantPermissionSetRel.Next() = 0;

        if MetaDataPermissionSetRel.FindSet() then
            repeat
                PermissionSetRelationBuffer.Init();
                PermissionSetRelationBuffer."App ID" := MetaDataPermissionSetRel."App ID";
                PermissionSetRelationBuffer."Role ID" := MetaDataPermissionSetRel."Role ID";
                PermissionSetRelationBuffer."Related App ID" := MetaDataPermissionSetRel."Related App ID";
                PermissionSetRelationBuffer."Related Role ID" := MetaDataPermissionSetRel."Related Role ID";
                PermissionSetRelationBuffer."Related Scope" := TenantPermissionSetRel."Related Scope"::System;
                PermissionSetRelationBuffer.Type := MetaDataPermissionSetRel.Type;
                PermissionSetRelationBuffer.Insert();
            until MetaDataPermissionSetRel.Next() = 0;
    end;

    procedure RefreshPermissionSetTree(RoleId: Code[30]; AppId: Guid; Scope: Option; var PermissionSetRelationBuffer: Record "Permission Set Relation Buffer" temporary)
    var
        UserAccountHelper: DotNet NavUserAccountHelper;
        PermissionSetRelationArray: DotNet NavPermissionSetRelationArray;
        ExcludedSets: Dictionary of [Text, Boolean];
    begin
        PermissionSetRelationBuffer.DeleteAll();
        PermissionSetRelationArray := UserAccountHelper.GetPermissionSetRelations(RoleId, AppId, Scope, GetMaxTreeLevel());

        // Get top level exclusions
        GetPermissionSetsOfType(PermissionTypeOption::Exclude, PermissionSetRelationArray, ExcludedSets);

        // Add included permission sets to buffer
        RefreshPermissionSetTree(PermissionSetRelationArray, ExcludedSets, PermissionTypeOption::Include, TempPermissionSetRelationBufferTree);
        if PermissionSetRelationBuffer.FindFirst() then;
    end;

    procedure SetStyleExpr(var PermissionSetRelationBuffer: Record "Permission Set Relation Buffer" temporary; var StyleExprRoleID: Text; var StyleExprInclusionStatus: Text)
    begin
        StyleExprInclusionStatus := '';
        if PermissionSetRelationBuffer.Type = PermissionSetRelationBuffer.Type::Exclude then begin
            StyleExprRoleID := 'Subordinate';
            StyleExprInclusionStatus := 'Subordinate';
        end else
            if PermissionSetRelationBuffer.Indent = 0 then begin
                StyleExprRoleID := 'Strong';
                if PermissionSetRelationBuffer.Status = PermissionSetRelationBuffer.Status::PartiallyIncluded then
                    StyleExprInclusionStatus := 'Ambiguous'
                else
                    StyleExprInclusionStatus := 'Favorable';
            end else
                if PermissionSetRelationBuffer.Status = PermissionSetRelationBuffer.Status::PartiallyIncluded then begin
                    StyleExprInclusionStatus := 'Ambiguous';
                    StyleExprRoleID := 'Ambiguous';
                end else begin
                    StyleExprInclusionStatus := 'Favorable';
                    StyleExprRoleID := '';
                end;
    end;

    procedure UpdateIncludedPermissionSets(PermissionSetRoleId: Text; var PermissionSetBuffer: Record "PermissionSet Buffer" temporary)
    var
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
        MetaDataPermissionSetRel: Record "Metadata Permission Set Rel.";
    begin
        // Clear previously related permission sets
        PermissionSetBuffer.DeleteAll();

        TenantPermissionSetRel.SetRange("Role ID", PermissionSetRoleId);
        TenantPermissionSetRel.SetRange(Type, TenantPermissionSetRel.Type::Include);
        MetaDataPermissionSetRel.SetRange("Role ID", PermissionSetRoleId);
        MetaDataPermissionSetRel.SetRange(Type, MetaDataPermissionSetRel.Type::Include);

        if TenantPermissionSetRel.FindSet() then
            repeat
                PermissionSetBuffer.Init();
                PermissionSetBuffer.Scope := PermissionSetBuffer.Scope::Tenant;
                PermissionSetBuffer."App ID" := TenantPermissionSetRel."Related App ID";
                PermissionSetBuffer."Role ID" := TenantPermissionSetRel."Related Role ID";
                PermissionSetBuffer.Insert();
            until TenantPermissionSetRel.Next() = 0;

        if MetaDataPermissionSetRel.FindSet() then
            repeat
                PermissionSetBuffer.Init();
                PermissionSetBuffer.Scope := PermissionSetBuffer.Scope::System;
                PermissionSetBuffer."App ID" := MetaDataPermissionSetRel."Related App ID";
                PermissionSetBuffer."Role ID" := MetaDataPermissionSetRel."Related Role ID";
                PermissionSetBuffer.Insert();
            until MetaDataPermissionSetRel.Next() = 0;
    end;

    local procedure AddNewPermissionSet(CurrAppId: Guid; CurrRoleID: Code[30]; CurrScope: Option System,Tenant; RelatedAppId: Guid; RelatedRoleId: Code[30]; RelatedScope: Option System,Tenant; PermissionType: Option Include,Exclude) Success: Boolean
    var
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
    begin
        if ((RelatedScope = CurrScope) and (RelatedAppId = CurrAppId) and (RelatedRoleId = CurrRoleID)) then
            if PermissionType = PermissionType::Include then
                Error(CannotIncludeItselfErr)
            else
                Error(CannotExcludeItselfErr);

        if TenantPermissionSetRel.Get(CurrAppId, CurrRoleId, RelatedAppId, RelatedRoleId) then
            if TenantPermissionSetRel.Type = PermissionType then
                if PermissionType = PermissionType::Include then
                    Error(PermissionSetAlreadyIncludedErr, TenantPermissionSetRel."Related Role ID")
                else
                    Error(PermissionSetAlreadyExcludedErr, TenantPermissionSetRel."Related Role ID")
            else
                TenantPermissionSetRel.Delete();

        TenantPermissionSetRel."App ID" := CurrAppId;
        TenantPermissionSetRel."Role ID" := CurrRoleId;
        TenantPermissionSetRel."Related App ID" := RelatedAppId;
        TenantPermissionSetRel."Related Role ID" := RelatedRoleId;
        TenantPermissionSetRel."Related Scope" := RelatedScope;
        TenantPermissionSetRel.Type := PermissionType;
        TenantPermissionSetRel.Insert();

        Success := ValidatePermissionSet(CurrAppId, CurrRoleID, CurrScope);

        // Including or excluding a permission set is both a set up and usage action
        FeatureTelemetry.LogUptake('0000HZR', ComposablePermissionSetsTok, Enum::"Feature Uptake Status"::"Set up");

        if PermissionType = PermissionType::Include then
            FeatureTelemetry.LogUsage('0000HZS', ComposablePermissionSetsTok, 'Permission set included.', GetCustomDimensions(CurrRoleID, CurrAppId, RelatedRoleId, RelatedAppId, RelatedScope))
        else
            FeatureTelemetry.LogUsage('0000HZT', ComposablePermissionSetsTok, 'Permission set excluded.', GetCustomDimensions(CurrRoleID, CurrAppId, RelatedRoleId, RelatedAppId, RelatedScope));
    end;

    local procedure GetPermissionSetsOfType(PermissionType: Option Include,Exclude; PermissionSetRelationArray: DotNet NavPermissionSetRelationArray; var ExcludedSets: Dictionary of [Text, Boolean])
    var
        PermissionSetRelation: DotNet NavPermissionSetRelation;
        Index: Integer;
    begin
        Index := 0;
        while Index < PermissionSetRelationArray.Length do begin
            PermissionSetRelation := PermissionSetRelationArray.GetValue(Index);

            if (PermissionSetRelation.Indent = 0) and (PermissionSetRelation.RelationType = PermissionType) then
                ExcludedSets.Set(StrSubstNo(RoleIdTok, PermissionSetRelation.RelatedRoleId, PermissionSetRelation.RelatedAppId), true);

            Index += 1;
        end;
    end;

    local procedure RefreshPermissionSetTree(PermissionSetRelationArray: DotNet NavPermissionSetRelationArray; ExcludedSets: Dictionary of [Text, Boolean]; PermissionType: Option Include,Exclude; var PermissionSetRelationBuffer: Record "Permission Set Relation Buffer" temporary)
    var
        PermissionSetRelation: DotNet NavPermissionSetRelation;
        Index, Offset, PrevIndent : Integer;
        ShouldAddToBuffer: Boolean;
    begin
        Index := 0;
        Offset := 0;
        PrevIndent := 1;

        while Index < PermissionSetRelationArray.Length do begin
            PermissionSetRelation := PermissionSetRelationArray.GetValue(Index);

            if PermissionSetRelation.Indent <= PrevIndent then begin
                ShouldAddToBuffer := PermissionSetRelation.RelationType = PermissionType;
                PrevIndent := PermissionSetRelation.Indent;
            end;

            if ShouldAddToBuffer then begin
                PermissionSetRelationBuffer.Init();
                PermissionSetRelationBuffer."Role ID" := PermissionSetRelation.RoleId;
                PermissionSetRelationBuffer."App ID" := PermissionSetRelation.AppId;
                PermissionSetRelationBuffer."Related Role ID As Text" := PermissionSetRelation.RelatedRoleId;
                PermissionSetRelationBuffer."Related Role ID" := PermissionSetRelation.RelatedRoleId;
                PermissionSetRelationBuffer."Related App ID" := PermissionSetRelation.RelatedAppId;
                PermissionSetRelationBuffer."Related Scope" := PermissionSetRelation.RelatedScope;
                PermissionSetRelationBuffer.Indent := PermissionSetRelation.Indent;
                PermissionSetRelationBuffer.Type := PermissionSetRelation.RelationType;
                PermissionSetRelationBuffer.Editable := not PermissionSetRelation.ExcludedByParent;
                PermissionSetRelationBuffer.Status := PermissionSetRelation.Status;
                PermissionSetRelationBuffer.Position := Offset;

                if not PermissionSetRelationBuffer.Editable then begin
                    PermissionSetRelationBuffer.Type := PermissionSetRelationBuffer.Type::Exclude;
                    PermissionSetRelationBuffer.Editable := ExcludedSets.ContainsKey(StrSubstNo(RoleIdTok, PermissionSetRelation.RelatedRoleId, PermissionSetRelation.RelatedAppId));
                end;

                PermissionSetRelationBuffer."Inclusion Status" := Format(PermissionSetRelationBuffer.Status);

                PermissionSetRelationBuffer.Insert();
                Offset += 1;
            end;

            Index += 1;
        end;
    end;

    local procedure ValidatePermissionSet(AppId: Guid; RoleId: Code[30]; Scope: Option System,Tenant): Boolean
    var
        UserAccountHelper: DotNet NavUserAccountHelper;
        ValidationErrors: DotNet StringArray;
    begin
        if UserAccountHelper.IsPermissionSetValid(RoleId, AppId, Scope, ValidationErrors) then
            exit(true);

        RaisePermissionSetValidationErrors(ValidationErrors);
    end;

    [ErrorBehavior(ErrorBehavior::Collect)]
    local procedure RaisePermissionSetValidationErrors(ValidationErrors: DotNet StringArray)
    var
        ErrorMsg: DotNet String;
    begin
        foreach ErrorMsg in ValidationErrors do
            Error(ErrorInfo.Create(ErrorMsg, true));
    end;

    local procedure GetCustomDimensions(SourceRoleID: Code[30]; SourceAppId: Guid; RelatedRoleId: Code[30]; RelatedAppId: Guid; RelatedScope: Option System,Tenant) CustomDimensions: Dictionary of [Text, Text]
    begin
        CustomDimensions.Add('SourceRoleId', SourceRoleID);
        CustomDimensions.Add('SourceAppId', SourceAppId);
        CustomDimensions.Add('RelatedRoleId', RelatedRoleId);
        CustomDimensions.Add('RelatedAppId', RelatedAppId);
        CustomDimensions.Add('RelatedScope', Format(RelatedScope));
    end;

    local procedure GetMaxTreeLevel(): Integer
    begin
        exit(10);
    end;

    procedure LookupPermissionSet(AllowMultiselect: Boolean; var AggregatePermissionSet: Record "Aggregate Permission Set"): Boolean
    var
        LookupPermissionSetPage: Page "Lookup Permission Set";
    begin
        LookupPermissionSetPage.LookupMode(true);
        if LookupPermissionSetPage.RunModal() = Action::LookupOK then begin
            if AllowMultiselect then
                LookupPermissionSetPage.GetSelectedRecords(AggregatePermissionSet)
            else
                LookupPermissionSetPage.GetSelectedRecord(AggregatePermissionSet);
            exit(true);
        end;
        exit(false);
    end;
}