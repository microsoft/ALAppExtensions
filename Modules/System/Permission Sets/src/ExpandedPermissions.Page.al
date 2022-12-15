// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Page for viewing the expanded permissions of a permission set.
/// </summary>
page 9862 "Expanded Permissions"
{
    PageType = List;
    Editable = false;
    SourceTable = "Expanded Permission";
    Caption = 'Expanded Permissions';

    layout
    {
        area(Content)
        {
            repeater(Permissions)
            {
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of object that the permissions apply to in the current database.';
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the object to which the permissions apply.';
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                }
                field("Object Name"; ObjectName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the object to which the permissions apply.';
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                }
                field("Read Permission"; Rec."Read Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the permission set has read permission to this object.';
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                }
                field("Insert Permission"; Rec."Insert Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the permission set has insert permission to this object.';
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                }
                field("Modify Permission"; Rec."Modify Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the permission set has modify permission to this object.';
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                }
                field("Delete Permission"; Rec."Delete Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the permission set has delete permission to this object.';
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                }
                field("Execute Permission"; Rec."Execute Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the permission set has execute permission to this object.';
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                }
                field("Security Filter"; Rec."Security Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a security filter that applies to this permission set to limit the access that this permission set has to the data contained in this table.';
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        PermissionImpl.GetObjectName(Rec, ObjectName);
        ZeroObjStyleExpr := Rec."Object ID" = 0;
    end;

    var
        PermissionImpl: Codeunit "Permission Impl.";
        ObjectName: Text;
        ZeroObjStyleExpr: Boolean;
}