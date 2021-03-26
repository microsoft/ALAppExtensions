// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to manage configuration settings of universal Printers.
/// </summary>
page 2753 "Universal Print Shares List"
{
    Caption = 'Print Shares';
    Editable = false;
    PageType = List;
    SourceTable = "Universal Print Share Buffer";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Name")
                      ORDER(Ascending);
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Name; Rec."Name")
                {
                    Caption = 'Print Share Name';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the print share.';
                }
                field(ID; Rec.ID)
                {
                    Caption = 'ID';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the id of the printer.';
                    Visible = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.FillRecordBuffer();
    end;
}