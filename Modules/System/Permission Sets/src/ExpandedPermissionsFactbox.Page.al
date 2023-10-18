// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

/// <summary>
/// Factbox for viewing the expanded permissions of a permission set.
/// </summary>
page 9863 "Expanded Permissions Factbox"
{
    PageType = ListPart;
    Editable = false;
    SourceTable = "Expanded Permission";

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
                }
                field(Name; Rec."Role Name")
                {
                    ApplicationArea = All;
                    Caption = 'Permission Set Name';
                    ToolTip = 'Specifies the name of the permission set.';
                    Visible = false;
                }
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of object that the permissions apply to in the current database.';
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the object to which the permissions apply.';
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the object to which the permissions apply.';
                }
                field("Read Permission"; Rec."Read Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the permission set has read permission to this object.';
                }
                field("Insert Permission"; Rec."Insert Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the permission set has insert permission to this object.';
                }
                field("Modify Permission"; Rec."Modify Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the permission set has modify permission to this object.';
                }
                field("Delete Permission"; Rec."Delete Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the permission set has delete permission to this object.';
                }
                field("Execute Permission"; Rec."Execute Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the permission set has execute permission to this object.';
                }
                field("Security Filter"; Rec."Security Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a security filter that applies to this permission set to limit the access that this permission set has to the data contained in this table.';
                }
            }
        }
    }
}