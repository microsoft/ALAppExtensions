// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 358 Objects
{
    Extensible = false;
    Editable = false;
    PageType = List;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = AllObjWithCaption;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Object Type"; "Object Type")
                {
                    ApplicationArea = All;
                    Caption = 'Type';
                    ToolTip = 'Specifies the object type.';
                    Visible = false;
                }
                field("Object ID"; "Object ID")
                {
                    ApplicationArea = All;
                    Caption = 'ID';
                    ToolTip = 'Specifies the object ID.';
                }
                field("Object Caption"; "Object Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Object Caption';
                    DrillDown = false;
                    ToolTip = 'Specifies the caption of the object.';
                }
                field("Object Name"; "Object Name")
                {
                    ApplicationArea = All;
                    Caption = 'Object Name';
                    ToolTip = 'Specifies the name of the object.';
                    Visible = false;
                }
                field(ExtensionName; ExtensionName)
                {
                    ApplicationArea = All;
                    Caption = 'Extension Name';
                    ToolTip = 'Specifies the name of the extension the object comes from.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    // Used to set the Extension Name field
    // in case the object comes from an installed extension.
    trigger OnAfterGetRecord()
    var
        NAVApp: Record "NAV App";
    begin
        ExtensionName := '';

        if IsNullGuid("App Package ID") then
            exit;

        if NAVApp.Get("App Package ID") then
            ExtensionName := NAVApp.Name;
    end;

    var
        ExtensionName: Text;
}

