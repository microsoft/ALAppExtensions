// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List page that contains table fields.
/// </summary>
page 9806 "Fields Lookup"
{
    Extensible = false;
    Editable = false;
    PageType = List;
    SourceTable = "Field";

    layout
    {
        area(content)
        {
            repeater(Control2)
            {
                ShowCaption = false;
                field(TableNo; TableNo)
                {
                    ApplicationArea = All;
                    Caption = 'Table No.';
                    ToolTip = 'Specifies the number of the table this field belongs to.';
                    Visible = false;
                }
                field(TableName; TableName)
                {
                    ApplicationArea = All;
                    Caption = 'Table Name';
                    ToolTip = 'Specifies the name of the table this field belongs to.';
                    Visible = TableNameVisible;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                    ToolTip = 'Specifies the number of the field.';
                }
                field(FieldName; FieldName)
                {
                    ApplicationArea = All;
                    Caption = 'Field Name';
                    ToolTip = 'Specifies the name of the field.';
                }
                field("Field Caption"; "Field Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Field Caption';
                    ToolTip = 'Specifies the caption of the field, that is, the name that will be shown in the user interface.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        LastTableNo: Integer;
    begin
        FindLast();
        LastTableNo := TableNo;
        FindFirst();
        TableNameVisible := LastTableNo <> TableNo;
    end;

    var
        TableNameVisible: Boolean;

    /// <summary>
    /// Gets the currently selected fields.
    /// </summary>
    /// <param name="SelectedField">A record that contains the currently selected fields</param>
    [Scope('OnPrem')]
    procedure GetSelectedFields(var SelectedField: Record "Field")
    var
        "Field": Record "Field";
    begin
        if SelectedField.IsTemporary() then begin
            SelectedField.Reset();
            SelectedField.DeleteAll();
            CurrPage.SetSelectionFilter(Field);
            if Field.FindSet() then
                repeat
                    SelectedField.Copy(Field);
                    SelectedField.Insert();
                until Field.Next() = 0;
        end else begin
            CurrPage.SetSelectionFilter(SelectedField);
            SelectedField.FindSet();
        end;
    end;
}

