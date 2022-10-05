// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// ListPart for viewing and including/excluding permission sets.
/// </summary>
page 9864 "Permission Set Subform"
{
    PageType = ListPart;
    SourceTable = "Permission Set Relation Buffer";
    SourceTableTemporary = true;
    SourceTableView = sorting(Type, "Related Role ID")
                      order(Ascending);
    Caption = 'Permission Sets';
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(PermissionSets)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExprRoleID;
                    Caption = 'Type';
                    ToolTip = 'Specifies whether to include or exclude the permission set';

                    trigger OnValidate()
                    begin
                        if PermissionSetRelationImpl.ModifyPermissionSetType(CurrAppId, CurrRoleId, CurrScope, Rec."Related App ID", Rec."Related Role ID", Rec.Type) then
                            RefreshTreeView();
                    end;
                }

                field("Related Role ID"; Rec."Related Role ID")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleExprRoleID;
                    Editable = false;
                    Caption = 'Permission Set';
                    ToolTip = 'Specifies the permission set';

                    trigger OnDrillDown()
                    begin
                        if PermissionSetRelationImpl.ModifyPermissionSet(CurrAppId, CurrRoleId, CurrScope, Rec."Related App ID", Rec."Related Role ID", Rec.Type) then
                            RefreshTreeView();
                    end;
                }
                field("Related Scope"; Rec."Related Scope")
                {
                    Caption = 'Scope';
                    ToolTip = 'Specifies the scope of the permission set.';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        PermissionSetRelationImpl.RemovePermissionSet(CurrAppId, CurrRoleId, Rec."Related App ID", Rec."Related Role ID");
        RefreshTreeView();
    end;

    trigger OnOpenPage()
    begin
        RefreshTreeView();
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

    internal procedure GetSourceRecord(var PermissionSetRelationBuffer: Record "Permission Set Relation Buffer")
    begin
        PermissionSetRelationBuffer.Copy(Rec, true);
    end;

    local procedure RefreshTreeView()
    begin
        PermissionSetRelationImpl.RefreshPermissionSets(CurrRoleId, CurrAppId, CurrScope);
        CurrPage.Update(false);
    end;

    var
        PermissionSetRelationImpl: Codeunit "Permission Set Relation Impl.";
        StyleExprRoleID: Text;
        CurrRoleId: Code[30];
        CurrAppId: Guid;
        [InDataSet]
        CurrScope: Option System,Tenant;
}