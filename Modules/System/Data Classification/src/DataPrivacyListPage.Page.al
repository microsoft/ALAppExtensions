// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 1181 "Data Privacy ListPage"
{
    Extensible = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Data Privacy Records";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Editable = false;
                    Enabled = false;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the name of the field.';
                }
                field("Field Value"; "Field Value")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the value in the field.';
                }
            }
        }
    }

    actions
    {
    }
}

