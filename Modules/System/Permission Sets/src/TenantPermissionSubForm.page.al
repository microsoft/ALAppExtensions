// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// ListPart for viewing and editing the permissions of a tenant permission set.
/// </summary>
page 9859 "Tenant Permission Subform"
{
    PageType = ListPart;
    SourceTable = "Tenant Permission";
    Caption = 'Permissions';
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Permissions)
            {
                field("Role ID"; Rec."Role ID")
                {
                    ApplicationArea = All;
                    Caption = 'Permission Set';
                    ToolTip = 'Specifies the permission set.';
                    Visible = false;
                    Editable = false;
                }
                field(Name; Rec."Role Name")
                {
                    ApplicationArea = All;
                    Caption = 'Permission Set Name';
                    ToolTip = 'Specifies the name of the permission set.';
                    Visible = false;
                    Editable = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies the type of permission.';

                    trigger OnValidate()
                    begin
                        PermissionImpl.UpdatePermissionLine(true, Rec, ObjectCaption, ObjectName, ReadPermissionAsTxt, InsertPermissionAsTxt, ModifyPermissionAsTxt, DeletePermissionAsTxt, ExecutePermissionAsTxt);
                    end;
                }
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    Enabled = AllowChangePrimaryKey;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies the type of object that the permissions apply to in the current database.';

                    trigger OnValidate()
                    begin
                        ActivateControls();
                        PermissionImpl.UpdatePermissionLine(true, Rec, ObjectCaption, ObjectName, ReadPermissionAsTxt, InsertPermissionAsTxt, ModifyPermissionAsTxt, DeletePermissionAsTxt, ExecutePermissionAsTxt);
                    end;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    Enabled = AllowChangePrimaryKey;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies the ID of the object to which the permissions apply.';
                    Lookup = true;

                    trigger OnValidate()
                    begin
                        ActivateControls();
                        PermissionImpl.UpdatePermissionLine(false, Rec, ObjectCaption, ObjectName, ReadPermissionAsTxt, InsertPermissionAsTxt, ModifyPermissionAsTxt, DeletePermissionAsTxt, ExecutePermissionAsTxt);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(PermissionImpl.LookupPermission(Rec."Object Type", Text))
                    end;
                }
                field("Object Name"; ObjectName)
                {
                    ApplicationArea = All;
                    Enabled = IsTableData;
                    Editable = false;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    Caption = 'Object Name';
                    ToolTip = 'Specifies the name of the object to which the permissions apply.';
                }
                field("Read Permission"; ReadPermissionAsTxt)
                {
                    ApplicationArea = All;
                    Enabled = IsTableData;
                    Editable = CurrPageIsEditable and IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    LookupPageID = "Permission Lookup List";
                    TableRelation = "Permission Lookup Buffer"."Option Caption" where("Lookup Type" = field(Type));
                    Caption = 'Read Permission';
                    ToolTip = 'Specifies if the permission set has read permission to this object.';

                    trigger OnValidate()
                    begin
                        Rec."Read Permission" := PermissionImpl.GetPermission(Rec.Type, ReadPermissionAsTxt);
                    end;
                }
                field("Insert Permission"; InsertPermissionAsTxt)
                {
                    ApplicationArea = All;
                    Enabled = IsTableData;
                    Editable = CurrPageIsEditable and IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    LookupPageID = "Permission Lookup List";
                    TableRelation = "Permission Lookup Buffer"."Option Caption" where("Lookup Type" = field(Type));
                    Caption = 'Insert Permission';
                    ToolTip = 'Specifies if the permission set has insert permission to this object.';

                    trigger OnValidate()
                    begin
                        Rec."Insert Permission" := PermissionImpl.GetPermission(Rec.Type, InsertPermissionAsTxt);
                    end;
                }
                field("Modify Permission"; ModifyPermissionAsTxt)
                {
                    ApplicationArea = All;
                    Enabled = IsTableData;
                    Editable = CurrPageIsEditable and IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    LookupPageID = "Permission Lookup List";
                    TableRelation = "Permission Lookup Buffer"."Option Caption" where("Lookup Type" = field(Type));
                    Caption = 'Modify Permission';
                    ToolTip = 'Specifies if the permission set has modify permission to this object.';

                    trigger OnValidate()
                    begin
                        Rec."Modify Permission" := PermissionImpl.GetPermission(Rec.Type, ModifyPermissionAsTxt);
                    end;
                }
                field("Delete Permission"; DeletePermissionAsTxt)
                {
                    ApplicationArea = All;
                    Enabled = IsTableData;
                    Editable = CurrPageIsEditable and IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    LookupPageID = "Permission Lookup List";
                    TableRelation = "Permission Lookup Buffer"."Option Caption" where("Lookup Type" = field(Type));
                    Caption = 'Delete Permission';
                    ToolTip = 'Specifies if the permission set has delete permission to this object.';

                    trigger OnValidate()
                    begin
                        Rec."Delete Permission" := PermissionImpl.GetPermission(Rec.Type, DeletePermissionAsTxt);
                    end;
                }
                field("Execute Permission"; ExecutePermissionAsTxt)
                {
                    ApplicationArea = All;
                    Enabled = not IsTableData;
                    Editable = CurrPageIsEditable and not IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    LookupPageID = "Permission Lookup List";
                    TableRelation = "Permission Lookup Buffer"."Option Caption" where("Lookup Type" = field(Type));
                    Caption = 'Execute Permission';
                    ToolTip = 'Specifies if the permission set has execute permission to this object.';

                    trigger OnValidate()
                    begin
                        Rec."Execute Permission" := PermissionImpl.GetPermission(Rec.Type, ExecutePermissionAsTxt);
                    end;
                }
                field("Security Filter"; Rec."Security Filter")
                {
                    ApplicationArea = All;
                    Enabled = IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies a security filter that applies to this permission set to limit the access that this permission set has to the data contained in this table.';

                    trigger OnAssistEdit()
                    var
                        PermissionSetRelation: Codeunit "Permission Set Relation";
                        OutputSecurityFilter: Text;
                    begin
                        // User cannot edit Security filter field for Extensions but can edit for user created types.
                        // Since this field is empty and GUID exists for Extensions it can be used as a flag for them.
                        if (Format(Rec."Security Filter") = '') and (not IsNullGuid(CurrentAppID)) then
                            exit;

                        PermissionSetRelation.OnShowSecurityFilterForTenantPermission(Rec, OutputSecurityFilter);

                        if OutputSecurityFilter <> '' then
                            Evaluate(Rec."Security Filter", OutputSecurityFilter);
                    end;

                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SelectPermissions)
            {
                ApplicationArea = All;
                Caption = 'Select Objects';
                ToolTip = 'Add two or more objects.';
                Image = NewItem;
                Ellipsis = true;
                Enabled = CurrPageIsEditable;
                Scope = Page;

                trigger OnAction()
                var
                    PermissionImpl: Codeunit "Permission Impl.";
                    PermissionSetRelation: Codeunit "Permission Set Relation";
                begin
                    PermissionSetRelation.VerifyUserCanEditPermissionSet(CurrentAppID);

                    if PermissionImpl.SelectPermissions(CurrentAppId, CopyStr(CurrentRoleId, 1, 20)) then
                        RefreshTreeView();
                end;
            }

            action(AddRelatedTablesAction)
            {
                AccessByPermission = TableData "Tenant Permission" = I;
                ApplicationArea = All;
                Image = Relationship;
                Enabled = CurrPageIsEditable and IsTableData;
                Caption = 'Add Read Permission to Related Tables';
                ToolTip = 'Add read access to tables that are related to the selected tables.';

                trigger OnAction()
                var
                    TenantPermission: Record "Tenant Permission";
                    PermissionSetCopyImpl: Codeunit "Permission Set Copy Impl.";
                begin
                    if not Confirm(AddRelatedTablesQst) then
                        exit;

                    TenantPermission.Copy(Rec);
                    CurrPage.SetSelectionFilter(TenantPermission);
                    if TenantPermission.FindSet() then
                        repeat
                            PermissionSetCopyImpl.AddReadAccessToRelatedTables(TenantPermission, Rec."App ID", Rec."Role ID");
                        until TenantPermission.Next() = 0;
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ActivateControls();
        PermissionImpl.UpdatePermissionLine(false, Rec, ObjectCaption, ObjectName, ReadPermissionAsTxt, InsertPermissionAsTxt, ModifyPermissionAsTxt, DeletePermissionAsTxt, ExecutePermissionAsTxt);

        PermissionRecExists := not IsNewRecord;
        AllowChangePrimaryKey := not PermissionRecExists;
        ZeroObjStyleExpr := PermissionRecExists and (Rec."Object ID" = 0);
    end;

    trigger OnAfterGetRecord()
    begin
        PermissionImpl.UpdatePermissionLine(false, Rec, ObjectCaption, ObjectName, ReadPermissionAsTxt, InsertPermissionAsTxt, ModifyPermissionAsTxt, DeletePermissionAsTxt, ExecutePermissionAsTxt);

        IsNewRecord := false;
        ZeroObjStyleExpr := Rec."Object ID" = 0;
    end;

    trigger OnDeleteRecord(): Boolean
    var
        TenantPermission: Record "Tenant Permission";
        PermissionSetRelation: Codeunit "Permission Set Relation";
    begin
        PermissionSetRelation.VerifyUserCanEditPermissionSet(CurrentAppID);

        CurrPage.SetSelectionFilter(TenantPermission);
        TenantPermission.DeleteAll(true); // Record needs to be deleted before refreshing tree
        RefreshTreeView();

        exit(false);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        PermissionSetRelation: Codeunit "Permission Set Relation";
    begin
        PermissionSetRelation.VerifyUserCanEditPermissionSet(CurrentAppID);

        if PermissionImpl.IsPermissionEmpty(Rec) then
            exit(false);

        PermissionImpl.VerifyPermissionAlreadyExists(Rec);
        PermissionImpl.EmptyIrrelevantPermissionFields(Rec);

        PermissionRecExists := true;
        IsNewRecord := false;
        ZeroObjStyleExpr := Rec."Object ID" = 0;

        Rec.Insert(true); // Record needs to be inserted before refreshing tree
        RefreshTreeView();
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        PermissionSetRelation: Codeunit "Permission Set Relation";
    begin
        PermissionSetRelation.VerifyUserCanEditPermissionSet(CurrentAppID);

        PermissionRecExists := true;
        IsNewRecord := false;

        Rec.Modify(true); // Record needs to be modified before refreshing tree
        RefreshTreeView();
        exit(false);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ActivateControls();
        PermissionRecExists := false;
        IsNewRecord := true;
        PermissionImpl.UpdatePermissionLine(true, Rec, ObjectCaption, ObjectName, ReadPermissionAsTxt, InsertPermissionAsTxt, ModifyPermissionAsTxt, DeletePermissionAsTxt, ExecutePermissionAsTxt);
    end;

    trigger OnInit()
    begin
        CurrPageIsEditable := true;
    end;

#if not CLEAN22
    [Obsolete('No longer used.', '22.0')]
    procedure SetPageVariables(AppId: Guid)
    begin
        CurrentAppID := AppId;
    end;
#endif

    internal procedure SetPermissionSet(RoleId: Code[30]; AppId: Guid; Tenant: Boolean)
    begin
        if Tenant then
            CurrentScope := CurrentScope::Tenant
        else
            CurrentScope := CurrentScope::System;

        CurrentRoleID := RoleId;
        CurrentAppID := AppId;
    end;

    internal procedure SetPermissionSetRelation(var PermissionSetRelationImplVar: Codeunit "Permission Set Relation Impl.")
    begin
        PermissionSetRelationImpl := PermissionSetRelationImplVar;
    end;

    local procedure ActivateControls()
    begin
        IsTableData := Rec."Object Type" = Rec."Object Type"::"Table Data";
        CurrPageIsEditable := CurrPage.Editable();
    end;

    local procedure RefreshTreeView()
    begin
        PermissionSetRelationImpl.RefreshPermissionSets(CurrentRoleID, CurrentAppID, CurrentScope);
        CurrPage.Update(false);
    end;

    var
        PermissionImpl: Codeunit "Permission Impl.";
        PermissionSetRelationImpl: Codeunit "Permission Set Relation Impl.";
        CurrentScope: Option System,Tenant;
        CurrentRoleID: Code[30];
        CurrentAppID: Guid;
        [InDataSet]
        IsTableData: Boolean;
        IsNewRecord: Boolean;
        PermissionRecExists: Boolean;
        AllowChangePrimaryKey: Boolean;
        CurrPageIsEditable: Boolean;
        ObjectCaption: Text;
        ObjectName: Text;
        ReadPermissionAsTxt: Text[50];
        InsertPermissionAsTxt: Text[50];
        ModifyPermissionAsTxt: Text[50];
        DeletePermissionAsTxt: Text[50];
        ExecutePermissionAsTxt: Text[50];
        ZeroObjStyleExpr: Boolean;
        AddRelatedTablesQst: Label 'Do you want to add the read permissions to all related tables?';
}