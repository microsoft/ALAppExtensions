// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// ListPart for viewing and including/excluding permission sets.
/// </summary>
page 9857 "Permission Set Tree"
{
    PageType = ListPart;
    SourceTable = "Permission Set Relation Buffer";
    SourceTableTemporary = true;
    Caption = 'Permission Sets';
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(PermissionSets)
            {
                TreeInitialState = CollapseAll;
                IndentationColumn = Rec.Indent;
                IndentationControls = "Related Role ID As Text", "Related Scope";
                ShowAsTree = true;

                field("Related Role ID As Text"; Rec."Related Role ID As Text")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExprRoleID;
                    Editable = false;
                    Caption = 'Permission Set';
                    ToolTip = 'Specifies the permission set.';
                }
                field("Related Name"; Rec."Related Name")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the permission set.';
                    Editable = false;
                }
                field("Related Scope"; Rec."Related Scope")
                {
                    Caption = 'Scope';
                    ToolTip = 'Specifies the scope of the permission set.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Inclusion Status"; Rec."Inclusion Status")
                {
                    Caption = 'Inclusion Status';
                    ToolTip = 'Specifies the inclusion status.';
                    StyleExpr = StyleExprInclusionStatus;
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group("&Line")
            {
                action(ExcludeSelectedPermissionSet)
                {
                    ApplicationArea = All;
                    Caption = 'Exclude';
                    ToolTip = 'Excludes the selected permission set.';
                    Image = Cancel;
                    Enabled = Rec."Role ID" <> '';
                    Visible = (CurrScope = CurrScope::Tenant) and (Rec.Type = Rec.Type::Include);
                    Scope = Repeater;

                    trigger OnAction()
                    begin
                        if PermissionSetRelationImpl.ExcludePermissionSet(CurrAppId, CurrRoleId, CurrScope, Rec."Related App ID", Rec."Related Role ID", Rec."Related Scope", Rec.Type::Exclude) then
                            RefreshTreeView();
                    end;
                }

                action(ViewPermissionSet)
                {
                    ApplicationArea = All;
                    Caption = 'View Permission Set';
                    ToolTip = 'View Permission Set';
                    Image = View;
                    Enabled = Rec."Role ID" <> '';
                    Scope = Repeater;

                    trigger OnAction()
                    var
                        TempPermissionSetBuffer: Record "PermissionSet Buffer" temporary;
                    begin
                        Rec.Validate("Related App ID");

                        TempPermissionSetBuffer.Init();
                        TempPermissionSetBuffer."App ID" := Rec."Related App ID";
                        TempPermissionSetBuffer."Role ID" := Rec."Related Role ID";
                        TempPermissionSetBuffer.Scope := Rec."Related Scope";
                        Page.Run(Page::"Permission Set", TempPermissionSetBuffer);
                    end;
                }

                action(ViewPermisions)
                {
                    ApplicationArea = All;
                    Image = Permission;
                    Scope = Repeater;
                    Enabled = Rec."Role ID" <> '';
                    Caption = 'View Permissions In Set';
                    ToolTip = 'View a flat list of the permissions in the set.';
                    RunObject = page "Expanded Permissions";
                    RunPageLink = "Role ID" = field("Related Role ID"), "App ID" = field("Related App ID");
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        RefreshTreeView();
    end;

    trigger OnAfterGetRecord()
    begin
        PermissionSetRelationImpl.SetStyleExpr(Rec, StyleExprRoleID, StyleExprInclusionStatus);
    end;

    internal procedure SetPermissionSet(RoleId: Code[30]; AppId: Guid; Tenant: Boolean)
    begin
        if Tenant then
            CurrScope := CurrScope::Tenant
        else
            CurrScope := CurrScope::System;

        CurrRoleId := RoleId;
        CurrAppId := AppId;
    end;

    internal procedure SetPermissionSetRelation(var PermissionSetRelationImplVar: Codeunit "Permission Set Relation Impl.")
    begin
        PermissionSetRelationImpl := PermissionSetRelationImplVar;
    end;

    local procedure RefreshTreeView()
    begin
        PermissionSetRelationImpl.RefreshPermissionSets(CurrRoleId, CurrAppId, CurrScope);
        Rec.SetCurrentKey(Position);
        CurrPage.Update(false);
    end;

    internal procedure GetSourceRecord(var PermissionSetRelationBuffer: Record "Permission Set Relation Buffer")
    begin
        PermissionSetRelationBuffer.Copy(Rec, true);
    end;

    var
        PermissionSetRelationImpl: Codeunit "Permission Set Relation Impl.";
        StyleExprRoleID: Text;
        StyleExprInclusionStatus: Text;
        CurrRoleId: Code[30];
        CurrAppId: Guid;
        [InDataSet]
        CurrScope: Option System,Tenant;
}