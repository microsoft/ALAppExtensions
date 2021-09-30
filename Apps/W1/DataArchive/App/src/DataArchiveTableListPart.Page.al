// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Shows the tables belonging to an archive
/// </summary>
page 632 "Data Archive Table ListPart"
{
    ApplicationArea = All;
    Caption = 'Data Archive Tables';
    PageType = ListPart;
    Editable = false;
    SourceTable = "Data Archive Table";
    SourceTableView = sorting("Table No.", "Created On");
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the table that is stored in this record.';
                }
                field("No. of Records"; Rec."No. of Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of records stored in this record.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SaveAsExcel)
            {
                ApplicationArea = All;
                Caption = 'Save as Excel';
                ToolTip = 'Saves the contents of this data archive record as Excel.';
                Image = ExportToExcel;

                trigger OnAction()
                var
                    DataArchiveTable: Record "Data Archive Table";
                begin
                    DataArchiveTable.SetRange("Data Archive Entry No.", Rec."Data Archive Entry No.");
                    DataArchiveTable.SetRange("Table No.", Rec."Table No.");
                    DataArchiveTable.SetRange("Entry No.", Rec."Entry No.");
                    Codeunit.Run(Codeunit::"Data Archive Export To Excel", DataArchiveTable);
                end;
            }
            action(SaveToCSV)
            {
                ApplicationArea = All;
                Caption = 'Save as CSV';
                ToolTip = 'Saves the contents of this data archive record in a CSV format.';
                image = ExportFile;

                trigger OnAction()
                var
                    DataArchiveTable: Record "Data Archive Table";
                begin
                    DataArchiveTable.SetRange("Data Archive Entry No.", Rec."Data Archive Entry No.");
                    DataArchiveTable.SetRange("Table No.", Rec."Table No.");
                    DataArchiveTable.SetRange("Entry No.", Rec."Entry No.");
                    Codeunit.Run(Codeunit::"Data Archive Export To CSV", DataArchiveTable);
                end;
            }
        }
    }
}
