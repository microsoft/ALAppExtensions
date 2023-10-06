// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

/// <summary>
/// Factbox for viewing the first level related permission sets.
/// </summary>
page 9849 "Included PermissionSet FactBox"
{
    PageType = ListPart;
    SourceTable = "PermissionSet Buffer";
    SourceTableTemporary = true;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;
    ShowFilter = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(PermissionSets)
            {
                field("Role ID"; Rec."Role ID")
                {
                    ApplicationArea = All;
                    Caption = 'Permission Set';
                    ToolTip = 'Specifies the permission set.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the permission set.';
                }
            }
        }
    }

    procedure UpdateIncludedPermissionSets(PermissionSetRoleId: Text)
    var
        PermissionSetRelationImpl: Codeunit "Permission Set Relation Impl.";
    begin
        PermissionSetRelationImpl.UpdateIncludedPermissionSets(PermissionSetRoleId, Rec);
        CurrPage.Update(false);
    end;
}