// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Shows the list of tables belonging to an archive.
/// </summary>
page 631 "Data Archive Table List"
{
    ApplicationArea = All;
    Caption = 'Data Archive Tables';
    PageType = List;
    SourceTable = "Data Archive Table";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the entry number for the data archive table.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Table No."; Rec."Table No.")
                {
                    ToolTip = 'Specifies the table number in the data archive table record.';
                    ApplicationArea = All;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ToolTip = 'Specifies the table name in the data archive table record.';
                    ApplicationArea = All;
                }
                field("Created On"; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    Caption = 'Created On';
                    ToolTip = 'Specifies when this data archive table record was created.';
                }
                field(HasReadPermission; Rec.HasReadPermission())
                {
                    ApplicationArea = All;
                    Caption = 'Read Permission';
                    ToolTip = 'Specifies whether you have read permission to this data.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description for this data archive table record.';
                }
                field("No. of Records"; Rec."No. of Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of records stored in this data archive table record.';
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
                Image = ExportFile;

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
