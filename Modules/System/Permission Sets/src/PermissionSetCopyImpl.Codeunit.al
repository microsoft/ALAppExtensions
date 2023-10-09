// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Telemetry;
using System.Reflection;

codeunit 9863 "Permission Set Copy Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        PermissionSetExistsErr: Label 'Permission set already exists.';
        ComposablePermissionSetsTok: Label 'Composable Permission Sets', Locked = true;

    procedure CopyPermissionSet(NewRoleId: Code[30]; NewName: Text; SourceRoleId: Code[30]; SourceAppId: Guid; SourceScope: Option System,Tenant; CopyType: Enum "Permission Set Copy Type")
    begin
        CreateNewTenantPermissionSet(NewRoleId, NewName);

        case CopyType of
            CopyType::Reference:
                CopyPermissionSetByReference(NewRoleId, NewName, SourceRoleId, SourceAppId, SourceScope);
            CopyType::Flat:
                CopyPermissionSetByFlatten(NewRoleId, NewName, SourceRoleId, SourceAppId, SourceScope);
            CopyType::Clone:
                CopyPermissionSetByClone(NewRoleId, NewName, SourceRoleId, SourceAppId, SourceScope);
        end;
    end;

    local procedure CopyPermissionSetByFlatten(NewRoleId: Code[30]; NewName: Text; SourceRoleId: Code[30]; SourceAppId: Guid; SourceScope: Option System,Tenant)
    var
#pragma warning disable AL0432
        SourcePermission: Record Permission;
#pragma warning restore
        SourceExpandedPermission: Record "Expanded Permission";
    begin
        case SourceScope of
            SourceScope::System:
                begin
                    SourcePermission.SetRange("Role ID", SourceRoleId);
                    if SourcePermission.FindSet() then
                        repeat
                            CopyPermissionToNewTenantPermission(NewRoleId, SourcePermission);
                        until SourcePermission.Next() = 0;
                end;
            SourceScope::Tenant:
                begin
                    SourceExpandedPermission.SetRange("App ID", SourceAppId);
                    SourceExpandedPermission.SetRange("Role ID", SourceRoleId);
                    if SourceExpandedPermission.FindSet() then
                        repeat
                            CopyExpandedPermissionToNewTenantPermission(NewRoleId, SourceExpandedPermission);
                        until SourceExpandedPermission.Next() = 0;
                end;
        end;

        // Copying by flatten is for legacy support, so no uptake logging for composable permission sets. 
        FeatureTelemetry.LogUsage('0000HZO', ComposablePermissionSetsTok, 'Permission set copied by flatten.', GetCustomDimensions(NewRoleID, NewName, SourceRoleId, SourceAppId, SourceScope));
    end;

    local procedure CopyPermissionSetByClone(NewRoleId: Code[30]; NewName: Text; SourceRoleId: Code[30]; SourceAppId: Guid; SourceScope: Option System,Tenant)
    var
        SourceMetadataPermission: Record "Metadata Permission";
        SourceTenantPermission: Record "Tenant Permission";
        MetadataPermissionSetRel: Record "Metadata Permission Set Rel.";
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
    begin
        // Copying a permission set both discover, set up and uses the feature.
        FeatureTelemetry.LogUptake('0000HZK', ComposablePermissionSetsTok, Enum::"Feature Uptake Status"::Discovered);
        FeatureTelemetry.LogUptake('0000HZL', ComposablePermissionSetsTok, Enum::"Feature Uptake Status"::"Set up");
        FeatureTelemetry.LogUptake('0000KR1', ComposablePermissionSetsTok, Enum::"Feature Uptake Status"::Used);

        case SourceScope of
            SourceScope::System:
                begin
                    SourceMetadataPermission.SetRange("Role ID", SourceRoleId);
                    if SourceMetadataPermission.FindSet() then
                        repeat
                            CopyMetadataPermissionToNewTenantPermission(NewRoleId, SourceMetadataPermission);
                        until SourceMetadataPermission.Next() = 0;

                    MetadataPermissionSetRel.SetRange("App ID", SourceAppId);
                    MetadataPermissionSetRel.SetRange("Role ID", SourceRoleId);
                    if MetadataPermissionSetRel.FindSet() then
                        repeat
                            CreateTenantPermissionSetRelation(NewRoleId, MetadataPermissionSetRel."Related Role ID", MetadataPermissionSetRel."Related App ID", SourceScope::System, MetadataPermissionSetRel.Type);
                        until MetadataPermissionSetRel.Next() = 0;
                end;
            SourceScope::Tenant:
                begin
                    SourceTenantPermission.SetRange("App ID", SourceAppId);
                    SourceTenantPermission.SetRange("Role ID", SourceRoleId);
                    if SourceTenantPermission.FindSet() then
                        repeat
                            CopyTenantPermissionToNewTenantPermission(NewRoleId, SourceTenantPermission);
                        until SourceTenantPermission.Next() = 0;

                    TenantPermissionSetRel.SetRange("App ID", SourceAppId);
                    TenantPermissionSetRel.SetRange("Role ID", SourceRoleId);
                    if TenantPermissionSetRel.FindSet() then
                        repeat
                            CreateTenantPermissionSetRelation(NewRoleId, TenantPermissionSetRel."Related Role ID", TenantPermissionSetRel."Related App ID", TenantPermissionSetRel."Related Scope", TenantPermissionSetRel.Type);
                        until TenantPermissionSetRel.Next() = 0;
                end;
        end;

        FeatureTelemetry.LogUsage('0000HZP', ComposablePermissionSetsTok, 'Permission set copied by clone.', GetCustomDimensions(NewRoleID, NewName, SourceRoleId, SourceAppId, SourceScope));
    end;

    local procedure CopyPermissionSetByReference(NewRoleId: Code[30]; NewName: Text; SourceRoleId: Code[30]; SourceAppId: Guid; SourceScope: Option System,Tenant)
    var
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
    begin
        // Copying a permission set both discover, set up and uses the feature.
        FeatureTelemetry.LogUptake('0000HZM', ComposablePermissionSetsTok, Enum::"Feature Uptake Status"::Discovered);
        FeatureTelemetry.LogUptake('0000HZN', ComposablePermissionSetsTok, Enum::"Feature Uptake Status"::"Set up");
        FeatureTelemetry.LogUptake('0000KR2', ComposablePermissionSetsTok, Enum::"Feature Uptake Status"::Used);

        CreateTenantPermissionSetRelation(NewRoleId, SourceRoleId, SourceAppId, SourceScope, TenantPermissionSetRel.Type::Include);

        FeatureTelemetry.LogUsage('0000HZQ', ComposablePermissionSetsTok, 'Permission set copied by reference.', GetCustomDimensions(NewRoleID, NewName, SourceRoleId, SourceAppId, SourceScope));
    end;

    local procedure CreateNewTenantPermissionSet(NewRoleID: Code[30]; NewName: Text)
    var
        TenantPermissionSet: Record "Tenant Permission Set";
        NullGuid: Guid;
    begin
        if TenantPermissionSet.Get(NullGuid, NewRoleID) then
            Error(PermissionSetExistsErr);

        TenantPermissionSet.Init();
        TenantPermissionSet."App ID" := NullGuid;
        TenantPermissionSet."Role ID" := CopyStr(NewRoleID, 1, MaxStrLen(TenantPermissionSet."Role ID"));
        TenantPermissionSet.Name := CopyStr(NewName, 1, MaxStrLen(TenantPermissionSet.Name));
        TenantPermissionSet.Insert();
    end;

    local procedure CreateTenantPermissionSetRelation(RoleId: Code[30]; RelatedRoleID: Code[30]; RelatedAppId: Guid; RelatedScope: Option System,Tenant; PermissionType: Option Include,Exclude)
    var
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
        NullGuid: Guid;
    begin
        TenantPermissionSetRel.Init();
        TenantPermissionSetRel."Role ID" := CopyStr(RoleId, 1, MaxStrLen(TenantPermissionSetRel."Role ID"));
        TenantPermissionSetRel."App ID" := NullGuid;
        TenantPermissionSetRel."Related Role ID" := RelatedRoleID;
        TenantPermissionSetRel."Related App ID" := RelatedAppId;
        TenantPermissionSetRel."Related Scope" := RelatedScope;
        TenantPermissionSetRel.Type := PermissionType;
        TenantPermissionSetRel.Insert();
    end;

#pragma warning disable AL0432
    local procedure CopyPermissionToNewTenantPermission(NewRoleID: Code[30]; FromPermission: Record Permission)
#pragma warning restore
    var
        TenantPermission: Record "Tenant Permission";
        NullGuid: Guid;
    begin
        if TenantPermission.Get(NullGuid, NewRoleID, FromPermission."Object Type", FromPermission."Object ID") then
            exit;

        TenantPermission.Init();
        TenantPermission."App ID" := NullGuid;
        TenantPermission."Role ID" := CopyStr(NewRoleID, 1, MaxStrLen(TenantPermission."Role ID"));
        TenantPermission."Object Type" := FromPermission."Object Type";
        TenantPermission."Object ID" := FromPermission."Object ID";
        TenantPermission."Read Permission" := FromPermission."Read Permission";
        TenantPermission."Insert Permission" := FromPermission."Insert Permission";
        TenantPermission."Modify Permission" := FromPermission."Modify Permission";
        TenantPermission."Delete Permission" := FromPermission."Delete Permission";
        TenantPermission."Execute Permission" := FromPermission."Execute Permission";
        TenantPermission."Security Filter" := FromPermission."Security Filter";
        TenantPermission.Insert();
    end;

    local procedure CopyMetadataPermissionToNewTenantPermission(NewRoleID: Code[30]; FromMetadataPermission: Record "Metadata Permission")
    var
        TenantPermission: Record "Tenant Permission";
        NullGuid: Guid;
    begin
        if TenantPermission.Get(FromMetadataPermission."App ID", NewRoleID, FromMetadataPermission."Object Type", FromMetadataPermission."Object ID") then
            exit;

        TenantPermission.Init();
        TenantPermission."App ID" := NullGuid;
        TenantPermission."Role ID" := CopyStr(NewRoleID, 1, MaxStrLen(TenantPermission."Role ID"));
        TenantPermission."Object Type" := FromMetadataPermission."Object Type";
        TenantPermission."Object ID" := FromMetadataPermission."Object ID";
        TenantPermission."Read Permission" := FromMetadataPermission."Read Permission";
        TenantPermission."Insert Permission" := FromMetadataPermission."Insert Permission";
        TenantPermission."Modify Permission" := FromMetadataPermission."Modify Permission";
        TenantPermission."Delete Permission" := FromMetadataPermission."Delete Permission";
        TenantPermission."Execute Permission" := FromMetadataPermission."Execute Permission";
        TenantPermission."Security Filter" := FromMetadataPermission."Security Filter";
        TenantPermission.Type := FromMetadataPermission.Type;
        TenantPermission.Insert();
    end;

    local procedure CopyTenantPermissionToNewTenantPermission(NewRoleID: Code[30]; FromTenantPermission: Record "Tenant Permission")
    var
        TenantPermission: Record "Tenant Permission";
        NullGuid: Guid;
    begin
        if TenantPermission.Get(FromTenantPermission."App ID", NewRoleID, FromTenantPermission."Object Type", FromTenantPermission."Object ID") then
            exit;

        TenantPermission := FromTenantPermission;
        TenantPermission."App ID" := NullGuid;
        TenantPermission."Role ID" := CopyStr(NewRoleID, 1, MaxStrLen(TenantPermission."Role ID"));
        TenantPermission.Insert();
    end;

    local procedure CopyExpandedPermissionToNewTenantPermission(NewRoleID: Code[30]; FromExpandedPermission: Record "Expanded Permission")
    var
        TenantPermission: Record "Tenant Permission";
        NullGuid: Guid;
    begin
        if TenantPermission.Get(FromExpandedPermission."App ID", NewRoleID, FromExpandedPermission."Object Type", FromExpandedPermission."Object ID") then
            exit;

        TenantPermission.Init();
        TenantPermission."App ID" := NullGuid;
        TenantPermission."Role ID" := CopyStr(NewRoleID, 1, MaxStrLen(TenantPermission."Role ID"));
        TenantPermission."Object Type" := FromExpandedPermission."Object Type";
        TenantPermission."Object ID" := FromExpandedPermission."Object ID";
        TenantPermission."Read Permission" := FromExpandedPermission."Read Permission";
        TenantPermission."Insert Permission" := FromExpandedPermission."Insert Permission";
        TenantPermission."Modify Permission" := FromExpandedPermission."Modify Permission";
        TenantPermission."Delete Permission" := FromExpandedPermission."Delete Permission";
        TenantPermission."Execute Permission" := FromExpandedPermission."Execute Permission";
        TenantPermission."Security Filter" := FromExpandedPermission."Security Filter";
        TenantPermission.Insert();
    end;

    internal procedure AddToTenantPermission(AppID: Guid; RoleID: Code[30]; ObjectType: Option; ObjectID: Integer; AddRead: Option; AddInsert: Option; AddModify: Option; AddDelete: Option; AddExecute: Option): Boolean
    var
        TenantPermission: Record "Tenant Permission";
        LogActivityPermissions: Codeunit "Log Activity Permissions";
    begin
        TenantPermission.LockTable();
        if not TenantPermission.Get(AppID, RoleID, ObjectType, ObjectID) then begin
            TenantPermission."App ID" := AppID;
            TenantPermission."Role ID" := CopyStr(RoleID, 1, MaxStrLen(TenantPermission."Role ID"));
            TenantPermission."Object Type" := ObjectType;
            TenantPermission."Object ID" := ObjectID;
            TenantPermission."Read Permission" := AddRead;
            TenantPermission."Insert Permission" := AddInsert;
            TenantPermission."Modify Permission" := AddModify;
            TenantPermission."Delete Permission" := AddDelete;
            TenantPermission."Execute Permission" := AddExecute;
            TenantPermission.Insert();
        end else begin
            TenantPermission."Read Permission" := LogActivityPermissions.GetMaxPermission(TenantPermission."Read Permission", AddRead);
            TenantPermission."Insert Permission" := LogActivityPermissions.GetMaxPermission(TenantPermission."Insert Permission", AddInsert);
            TenantPermission."Modify Permission" := LogActivityPermissions.GetMaxPermission(TenantPermission."Modify Permission", AddModify);
            TenantPermission."Delete Permission" := LogActivityPermissions.GetMaxPermission(TenantPermission."Delete Permission", AddDelete);
            TenantPermission."Execute Permission" := LogActivityPermissions.GetMaxPermission(TenantPermission."Execute Permission", AddExecute);
            TenantPermission.Modify();
        end;
    end;

    internal procedure AddReadAccessToRelatedTables(var TempTenantPermission: Record "Tenant Permission" temporary; AppID: Guid; RoleID: Code[30])
    var
        TableRelationsMetadata: Record "Table Relations Metadata";
    begin
        if TempTenantPermission."Object Type" <> TempTenantPermission."Object Type"::"Table Data" then
            exit;
        if TempTenantPermission."Object ID" = 0 then
            exit;

        TableRelationsMetadata.SetRange("Table ID", TempTenantPermission."Object ID");
        TableRelationsMetadata.SetFilter("Related Table ID", '>0&<>%1', TempTenantPermission."Object ID");
        if TableRelationsMetadata.FindSet() then
            repeat
                AddToTenantPermission(
                  AppID, RoleID, TempTenantPermission."Object Type"::"Table Data", TableRelationsMetadata."Related Table ID", TempTenantPermission."Read Permission"::Yes,
                  TempTenantPermission."Insert Permission"::" ", TempTenantPermission."Modify Permission"::" ", TempTenantPermission."Delete Permission"::" ", TempTenantPermission."Execute Permission"::" ");
            until TableRelationsMetadata.Next() = 0;
    end;

    local procedure GetCustomDimensions(NewRoleId: Code[30]; NewName: Text; SourceRoleId: Code[30]; SourceAppId: Guid; SourceScope: Option System,Tenant) CustomDimensions: Dictionary of [Text, Text]
    begin
        CustomDimensions.Add('NewRoleId', NewRoleId);
        CustomDimensions.Add('NewName', NewName);
        CustomDimensions.Add('SourceRoleId', SourceRoleId);
        CustomDimensions.Add('SourceAppId', SourceAppId);
        CustomDimensions.Add('SourceScope', Format(SourceScope));
    end;
}