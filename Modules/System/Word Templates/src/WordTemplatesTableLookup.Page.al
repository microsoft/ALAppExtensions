// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A look-up page to select a table to be used in a Word template.
/// </summary>
page 9988 "Word Templates Table Lookup"
{
    PageType = List;
    Caption = 'Word Templates Tables';
    SourceTable = "Word Templates Table";
    Permissions = tabledata "Word Templates Table" = r;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ID; "Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Table ID.';
                    Caption = 'Id';
                }
                field(Name; "Table Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Caption';
                    ToolTip = 'Specifies the table caption.';
                }
            }
        }
    }

    procedure GetRecord(var SelectedWordTemplatesTable: Record "Word Templates Table")
    begin
        SelectedWordTemplatesTable := Rec;
    end;
}
