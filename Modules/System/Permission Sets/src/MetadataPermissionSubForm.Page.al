// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

/// <summary>
/// ListPart for viewing the permissions of a metadata permission set.
/// </summary>
page 9856 "Metadata Permission Subform"
{
    PageType = ListPart;
    SourceTable = "Metadata Permission";
    Caption = 'Permissions';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

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
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies whether this is an include or exclude permission.';
                }
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies the type of object that the permissions apply to in the current database.';
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies the ID of the object to which the permissions apply.';
                }
                field("Object Name"; ObjectName)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    Caption = 'Object Name';
                    ToolTip = 'Specifies the name of the object to which the permissions apply.';
                }
                field("Object Caption"; ObjectCaption)
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    Caption = 'Object Caption';
                    ToolTip = 'Specifies the caption of the object that the permissions apply to.';
                }
                field("Read Permission"; Rec."Read Permission")
                {
                    ApplicationArea = All;
                    Enabled = IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies information about whether the permission set has read permission to this object. The values for the field are blank, Yes, and Indirect. Indirect means permission only through another object. If the field is empty, the permission set does not have read permission.';
                }
                field("Insert Permission"; Rec."Insert Permission")
                {
                    ApplicationArea = All;
                    Enabled = IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies information about whether the permission set has insert permission to this object. The values for the field are blank, Yes, and Indirect. Indirect means permission only through another object. If the field is empty, the permission set does not have insert permission.';
                }
                field("Modify Permission"; Rec."Modify Permission")
                {
                    ApplicationArea = All;
                    Enabled = IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies information about whether the permission set has modify permission to this object. The values for the field are blank, Yes, and Indirect. Indirect means permission only through another object. If the field is empty, the permission set does not have modify permission.';

                }
                field("Delete Permission"; Rec."Delete Permission")
                {
                    ApplicationArea = All;
                    Enabled = IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies information about whether the permission set has delete permission to this object. The values for the field are blank, Yes, and Indirect. Indirect means permission only through another object. If the field is empty, the permission set does not have delete permission.';

                }
                field("Execute Permission"; Rec."Execute Permission")
                {
                    ApplicationArea = All;
                    Enabled = not IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies information about whether the permission set has execute permission to this object. The values for the field are blank, Yes, and Indirect. Indirect means permission only through another object. If the field is empty, the permission set does not have execute permission.';

                }
                field("Security Filter"; Rec."Security Filter")
                {
                    ApplicationArea = All;
                    Enabled = IsTableData;
                    Style = Strong;
                    StyleExpr = ZeroObjStyleExpr;
                    ToolTip = 'Specifies the security filter that is being applied to this permission set to limit the access that this permission set has to the data contained in this table.';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        MetadataPermission: Record "Metadata Permission";
        PermissionImpl: Codeunit "Permission Impl.";
    begin
        IsTableData := Rec."Object Type" = Rec."Object Type"::"Table Data";
        PermissionImpl.GetObjectCaptionAndName(Rec, ObjectCaption, ObjectName);
        if not IsNewRecord then begin
            MetadataPermission := Rec;
            PermissionRecExists := not MetadataPermission.IsEmpty();
        end else
            PermissionRecExists := false;
        ZeroObjStyleExpr := PermissionRecExists and (Rec."Object ID" = 0);
    end;

    trigger OnAfterGetRecord()
    var
        PermissionImpl: Codeunit "Permission Impl.";
    begin
        PermissionImpl.GetObjectCaptionAndName(Rec, ObjectCaption, ObjectName);
        ZeroObjStyleExpr := Rec."Object ID" = 0;
        IsNewRecord := false;
    end;

    var
        IsTableData: Boolean;
        IsNewRecord: Boolean;
        PermissionRecExists: Boolean;
        ObjectCaption: Text;
        ObjectName: Text;
        ZeroObjStyleExpr: Boolean;
}