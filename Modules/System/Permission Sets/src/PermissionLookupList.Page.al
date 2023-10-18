// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

/// <summary>
/// Buffer table for permission options
/// </summary>
page 9865 "Permission Lookup List"
{
    Caption = 'Permission Lookup List';
    Editable = false;
    PageType = List;
    SourceTable = "Permission Lookup Buffer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Option Caption"; Rec."Option Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Permission';
                    ToolTip = 'Specifies the value for the permission to this object.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        PermissionImpl: Codeunit "Permission Impl.";
    begin
        PermissionImpl.FillLookupBuffer(Rec);
        Rec.SetCurrentKey(ID);
    end;
}