// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Xmlport for importing permission sets.
/// </summary>
xmlport 9864 "Import Permission Sets"
{
    Caption = 'Import Permission Sets';
    Direction = Import;
    Encoding = UTF8;
    PreserveWhiteSpace = true;

    schema
    {
        textelement(PermissionSets)
        {
            textattribute(Version)
            {
                TextType = Text;
                Description = 'Version';
            }
            tableelement(TempTenantPermissionSet; "Tenant Permission Set")
            {
                MinOccurs = Zero;
                XmlName = 'TenantPermissionSet';
                SourceTableView = sorting("App ID", "Role ID");
                UseTemporary = true;
                fieldattribute(AppID; TempTenantPermissionSet."App ID")
                {
                    Occurrence = Optional;
                }
                fieldattribute(RoleID; TempTenantPermissionSet."Role ID")
                {
                }
                fieldattribute(RoleName; TempTenantPermissionSet.Name)
                {
                }
                fieldattribute(Assignable; TempTenantPermissionSet.Assignable)
                {
                }
                tableelement(TempTenantPermissionSetRel; "Tenant Permission Set Rel.")
                {
                    LinkTable = TempTenantPermissionSet;
                    LinkFields = "App ID" = Field("App ID"), "Role ID" = field("Role ID");
                    MinOccurs = Zero;
                    XmlName = 'TenantPermissionSetRel';
                    SourceTableView = sorting("App ID", "Role ID", "Related App ID", "Related Role ID");
                    UseTemporary = true;
                    fieldelement(ObjectType; TempTenantPermissionSetRel.Type)
                    {
                    }
                    fieldelement(ObjectRelatedScope; TempTenantPermissionSetRel."Related Scope")
                    {
                    }
                    fieldelement(ObjectRelatedRoleId; TempTenantPermissionSetRel."Related Role ID")
                    {
                    }
                    fieldelement(ObjectRelatedAppId; TempTenantPermissionSetRel."Related App ID")
                    {
                    }
                }
                tableelement(TempTenantPermission; "Tenant Permission")
                {
                    LinkFields = "App ID" = field("App ID"), "Role ID" = FIELD("Role ID");
                    LinkTable = TempTenantPermissionSet;
                    MinOccurs = Zero;
                    XmlName = 'TenantPermission';
                    SourceTableView = SORTING("Role ID", "Object Type", "Object ID");
                    UseTemporary = true;
                    fieldelement(ObjectType; TempTenantPermission."Object Type")
                    {
                    }
                    fieldelement(ObjectID; TempTenantPermission."Object ID")
                    {
                    }
                    fieldelement(ReadPermission; TempTenantPermission."Read Permission")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(InsertPermission; TempTenantPermission."Insert Permission")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ModifyPermission; TempTenantPermission."Modify Permission")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(DeletePermission; TempTenantPermission."Delete Permission")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ExecutePermission; TempTenantPermission."Execute Permission")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(SecurityFilter; TempTenantPermission."Security Filter")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(PermissionType; TempTenantPermission.Type)
                    {
                        MinOccurs = Zero;
                    }

                    trigger OnAfterInitRecord()
                    begin
                        TempTenantPermission."Read Permission" := TempTenantPermission."Read Permission"::" ";
                        TempTenantPermission."Insert Permission" := TempTenantPermission."Insert Permission"::" ";
                        TempTenantPermission."Modify Permission" := TempTenantPermission."Modify Permission"::" ";
                        TempTenantPermission."Delete Permission" := TempTenantPermission."Delete Permission"::" ";
                        TempTenantPermission."Execute Permission" := TempTenantPermission."Execute Permission"::" ";
                    end;
                }

                trigger OnBeforeInsertRecord()
                begin
                    if TempTenantPermissionSet.Get(TempTenantPermissionSet."App ID", TempTenantPermissionSet."Role ID") then
                        currXMLport.Skip();
                end;
            }
            tableelement(TempMetadataPermissionSet; "Metadata Permission Set")
            {
                MinOccurs = Zero;
                XmlName = 'PermissionSet';
                UseTemporary = true;
                fieldattribute(AppID; TempMetadataPermissionSet."App ID")
                {
                    Occurrence = Optional;
                }
                fieldattribute(RoleID; TempMetadataPermissionSet."Role ID")
                {
                }
                fieldattribute(RoleName; TempMetadataPermissionSet.Name)
                {
                }
                fieldattribute(Assignable; TempMetadataPermissionSet.Assignable)
                {
                }
                tableelement(TempMetadataPermissionSetRel; "Metadata Permission Set Rel.")
                {
                    LinkTable = TempMetadataPermissionSet;
                    LinkFields = "App ID" = Field("App ID"), "Role ID" = field("Role ID");
                    MinOccurs = Zero;
                    XmlName = 'PermissionSetRel';
                    SourceTableView = sorting("App ID", "Role ID", "Related App ID", "Related Role ID");
                    UseTemporary = true;
                    fieldelement(ObjectType; TempMetadataPermissionSetRel.Type)
                    {
                    }
                    fieldelement(ObjectRelatedRoleId; TempMetadataPermissionSetRel."Related Role ID")
                    {
                    }
                    fieldelement(ObjectRelatedAppId; TempMetadataPermissionSetRel."Related App ID")
                    {
                    }
                }
                tableelement(TempMetadataPermission; "Metadata Permission")
                {
                    LinkFields = "App ID" = field("App ID"), "Role ID" = FIELD("Role ID");
                    LinkTable = TempMetadataPermissionSet;
                    MinOccurs = Zero;
                    XmlName = 'Permission';
                    SourceTableView = SORTING("Role ID", "Object Type", "Object ID");
                    UseTemporary = true;
                    fieldelement(ObjectType; TempMetadataPermission."Object Type")
                    {
                    }
                    fieldelement(ObjectID; TempMetadataPermission."Object ID")
                    {
                    }
                    fieldelement(ReadPermission; TempMetadataPermission."Read Permission")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(InsertPermission; TempMetadataPermission."Insert Permission")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ModifyPermission; TempMetadataPermission."Modify Permission")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(DeletePermission; TempMetadataPermission."Delete Permission")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ExecutePermission; TempMetadataPermission."Execute Permission")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(SecurityFilter; TempMetadataPermission."Security Filter")
                    {
                        MinOccurs = Zero;
                    }

                    trigger OnAfterInitRecord()
                    begin
                        TempMetadataPermission."Read Permission" := TempMetadataPermission."Read Permission"::" ";
                        TempMetadataPermission."Insert Permission" := TempMetadataPermission."Insert Permission"::" ";
                        TempMetadataPermission."Modify Permission" := TempMetadataPermission."Modify Permission"::" ";
                        TempMetadataPermission."Delete Permission" := TempMetadataPermission."Delete Permission"::" ";
                        TempMetadataPermission."Execute Permission" := TempMetadataPermission."Execute Permission"::" ";
                    end;
                }

                trigger OnBeforeInsertRecord()
                begin
                    if TempMetadataPermissionSet.Get(TempMetadataPermissionSet."App ID", TempMetadataPermissionSet."Role ID") then
                        currXMLport.Skip();
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
        }
    }

    var
        UpdatePermissions: Boolean;
        CannotManagePermissionsErr: Label 'Only users with the SUPER or the SECURITY permission set can create or edit permission sets.';

    trigger OnPreXmlPort()
    begin
        DisallowEditingPermissionSetsForNonAdminUsers();
        OnAfterOnPreXmlPort(UpdatePermissions);
    end;

    trigger OnPostXmlPort()
    var
    begin
        if TempMetadataPermissionSet.FindSet() then
            repeat
                ProcessSystemPermissionSet(TempMetadataPermissionSet);
            until TempMetadataPermissionSet.Next() = 0;
        if TempTenantPermissionSet.FindSet() then
            repeat
                ProcessTenantPermissionSet(TempTenantPermissionSet);
            until TempTenantPermissionSet.Next() = 0;
    end;

    procedure SetUpdatePermissions(NewUpdatePermissions: Boolean)
    begin
        UpdatePermissions := NewUpdatePermissions;
    end;

    local procedure ProcessSystemPermissionSet(MetadataPermissionSet: Record "Metadata Permission Set")
    begin
        TempMetadataPermission.SetRange("App ID", MetadataPermissionSet."App ID");
        TempMetadataPermission.SetRange("Role ID", MetadataPermissionSet."Role ID");
        TempMetadataPermissionSetRel.SetRange("App ID", MetadataPermissionSet."App ID");
        TempMetadataPermissionSetRel.SetRange("Role ID", MetadataPermissionSet."Role ID");
        InsertSystemPermissionSet(MetadataPermissionSet);
        if TempMetadataPermissionSetRel.FindSet() then
            repeat
                InsertSystemPermissionSetRelation(TempMetadataPermissionSetRel);
            until TempMetadataPermissionSetRel.Next() = 0;
        if TempMetadataPermission.FindSet() then
            repeat
                InsertSystemPermission(TempMetadataPermission);
            until TempMetadataPermission.Next() = 0;
    end;

    local procedure InsertSystemPermissionSet(SourceMetadataPermissionSet: Record "Metadata Permission Set")
    var
        TenantPermissionSet: Record "Tenant Permission Set";
        NullGuid: Guid;
    begin
        if TenantPermissionSet.Get(NullGuid, SourceMetadataPermissionSet."Role ID") then
            exit;

        TenantPermissionSet.Init();
        TenantPermissionSet.TransferFields(SourceMetadataPermissionSet);
        TenantPermissionSet."App ID" := NullGuid;
        TenantPermissionSet.Insert();
    end;

    local procedure InsertSystemPermissionSetRelation(SourceMetadataPermissionSetRel: Record "Metadata Permission Set Rel.")
    var
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
        NullGuid: Guid;
    begin
        if TenantPermissionSetRel.Get(NullGuid, SourceMetadataPermissionSetRel."Role ID", SourceMetadataPermissionSetRel."Related App ID", SourceMetadataPermissionSetRel."Related Role ID") then
            exit;

        TenantPermissionSetRel.Init();
        TenantPermissionSetRel.TransferFields(SourceMetadataPermissionSetRel);
        TenantPermissionSetRel."App ID" := NullGuid;
        TenantPermissionSetRel.Insert();
    end;

    local procedure InsertSystemPermission(SourceMetadataPermission: Record "Metadata Permission")
    var
        TenantPermission: Record "Tenant Permission";
        NullGuid: Guid;
    begin
        if not TenantPermission.Get(NullGuid, SourceMetadataPermission."Role ID", SourceMetadataPermission."Object Type", SourceMetadataPermission."Object ID") then begin
            TenantPermission.Init();
            TenantPermission."App ID" := NullGuid;
            TenantPermission."Role ID" := CopyStr(SourceMetadataPermission."Role ID", 1, MaxStrLen(TenantPermission."Role ID"));
            TenantPermission."Object Type" := SourceMetadataPermission."Object Type";
            TenantPermission."Object ID" := SourceMetadataPermission."Object ID";
            TenantPermission."Read Permission" := SourceMetadataPermission."Read Permission";
            TenantPermission."Insert Permission" := SourceMetadataPermission."Insert Permission";
            TenantPermission."Modify Permission" := SourceMetadataPermission."Modify Permission";
            TenantPermission."Delete Permission" := SourceMetadataPermission."Delete Permission";
            TenantPermission."Execute Permission" := SourceMetadataPermission."Execute Permission";
            TenantPermission."Security Filter" := SourceMetadataPermission."Security Filter";
            TenantPermission.Type := SourceMetadataPermission.Type;
            TenantPermission.Insert();
        end else begin
            if IsFirstPermissionHigherThanSecond(SourceMetadataPermission."Read Permission", TenantPermission."Read Permission") then
                TenantPermission."Read Permission" := SourceMetadataPermission."Read Permission";
            if IsFirstPermissionHigherThanSecond(SourceMetadataPermission."Insert Permission", TenantPermission."Insert Permission") then
                TenantPermission."Insert Permission" := SourceMetadataPermission."Insert Permission";
            if IsFirstPermissionHigherThanSecond(SourceMetadataPermission."Modify Permission", TenantPermission."Modify Permission") then
                TenantPermission."Modify Permission" := SourceMetadataPermission."Modify Permission";
            if IsFirstPermissionHigherThanSecond(SourceMetadataPermission."Delete Permission", TenantPermission."Delete Permission") then
                TenantPermission."Delete Permission" := SourceMetadataPermission."Delete Permission";
            if IsFirstPermissionHigherThanSecond(SourceMetadataPermission."Execute Permission", TenantPermission."Execute Permission") then
                TenantPermission."Execute Permission" := SourceMetadataPermission."Execute Permission";
            TenantPermission.Modify();
        end;
    end;

    local procedure ProcessTenantPermissionSet(TenantPermissionSet: Record "Tenant Permission Set")
    begin
        TempTenantPermission.SetRange("App ID", TenantPermissionSet."App ID");
        TempTenantPermission.SetRange("Role ID", TenantPermissionSet."Role ID");
        TempTenantPermissionSetRel.SetRange("App ID", TenantPermissionSet."App ID");
        TempTenantPermissionSetRel.SetRange("Role ID", TenantPermissionSet."Role ID");
        InsertTenantPermissionSet(TenantPermissionSet);
        if TempTenantPermissionSetRel.FindSet() then
            repeat
                InsertTenantPermissionSetRelation(TempTenantPermissionSetRel);
            until TempTenantPermissionSetRel.Next() = 0;
        if TempTenantPermission.FindSet() then
            repeat
                InsertTenantPermission(TempTenantPermission);
            until TempTenantPermission.Next() = 0;
    end;

    local procedure InsertTenantPermissionSetRelation(SourceTenantPermissionSetRel: Record "Tenant Permission Set Rel.")
    var
        TenantPermissionSetRel: Record "Tenant Permission Set Rel.";
    begin
        if TenantPermissionSetRel.Get(SourceTenantPermissionSetRel."App ID", SourceTenantPermissionSetRel."Role ID", SourceTenantPermissionSetRel."Related App ID", SourceTenantPermissionSetRel."Related Role ID") then
            exit;

        TenantPermissionSetRel.Init();
        TenantPermissionSetRel.TransferFields(SourceTenantPermissionSetRel);
        TenantPermissionSetRel.Insert();
    end;

    local procedure InsertTenantPermissionSet(SourceTenantPermissionSet: Record "Tenant Permission Set")
    var
        TenantPermissionSet: Record "Tenant Permission Set";
    begin
        if TenantPermissionSet.Get(SourceTenantPermissionSet."App ID", SourceTenantPermissionSet."Role ID") then
            exit;

        TenantPermissionSet.Init();
        TenantPermissionSet.TransferFields(SourceTenantPermissionSet);
        TenantPermissionSet.Assignable := true;
        TenantPermissionSet.Insert();
    end;

    local procedure InsertTenantPermission(SourceTenantPermission: Record "Tenant Permission")
    var
        TenantPermission: Record "Tenant Permission";
    begin
        if not TenantPermission.Get(SourceTenantPermission."App ID", SourceTenantPermission."Role ID", SourceTenantPermission."Object Type", SourceTenantPermission."Object ID") then begin
            TenantPermission.Init();
            TenantPermission.TransferFields(SourceTenantPermission);
            TenantPermission.Insert();
        end else begin
            if IsFirstPermissionHigherThanSecond(SourceTenantPermission."Read Permission", TenantPermission."Read Permission") then
                TenantPermission."Read Permission" := SourceTenantPermission."Read Permission";
            if IsFirstPermissionHigherThanSecond(SourceTenantPermission."Insert Permission", TenantPermission."Insert Permission") then
                TenantPermission."Insert Permission" := SourceTenantPermission."Insert Permission";
            if IsFirstPermissionHigherThanSecond(SourceTenantPermission."Modify Permission", TenantPermission."Modify Permission") then
                TenantPermission."Modify Permission" := SourceTenantPermission."Modify Permission";
            if IsFirstPermissionHigherThanSecond(SourceTenantPermission."Delete Permission", TenantPermission."Delete Permission") then
                TenantPermission."Delete Permission" := SourceTenantPermission."Delete Permission";
            if IsFirstPermissionHigherThanSecond(SourceTenantPermission."Execute Permission", TenantPermission."Execute Permission") then
                TenantPermission."Execute Permission" := SourceTenantPermission."Execute Permission";
            TenantPermission.Modify();
        end;
    end;

    local procedure IsFirstPermissionHigherThanSecond(First: Option; Second: Option): Boolean
    var
        ExpandedPermission: Record "Expanded Permission";
    begin
        case First of
            ExpandedPermission."Read Permission"::" ":
                exit(false);
            ExpandedPermission."Read Permission"::Indirect:
                exit(Second = ExpandedPermission."Read Permission"::" ");
            ExpandedPermission."Read Permission"::Yes:
                exit(Second in [ExpandedPermission."Read Permission"::Indirect, ExpandedPermission."Read Permission"::" "]);
        end;
    end;

    local procedure DisallowEditingPermissionSetsForNonAdminUsers()
    var
        UserPermissions: Codeunit "User Permissions";
    begin
        if not UserPermissions.CanManageUsersOnTenant(UserSecurityId()) then
            Error(CannotManagePermissionsErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterOnPreXmlPort(var UpdatePermissions: Boolean)
    begin
    end;
}