// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
                    Caption = 'Permission Set';
                    ApplicationArea = All;
                    ToolTip = 'Name of Permission Set';
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