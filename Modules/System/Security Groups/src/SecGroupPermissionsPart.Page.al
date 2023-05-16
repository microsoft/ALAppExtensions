// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// View the permission sets associated with a security group in a page part or factbox.
/// </summary>
page 9867 "Sec. Group Permissions Part"
{
    Caption = 'Permission Sets';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Access Control";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Role ID"; Rec."Role ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of a permission set.';
                    Caption = 'Permission Set';

                    trigger OnDrillDown()
                    var
                        PermissionSetRelation: Codeunit "Permission Set Relation";
                    begin
                        PermissionSetRelation.OpenPermissionSetPage('', Rec."Role ID", Rec."App ID", Rec.Scope);
                    end;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the company that the permission set applies to.';
                }
            }
        }
    }
}

