// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Shows the list of data archives. This is the main page for this app.
/// </summary>
page 630 "Data Archive List"
{
    ApplicationArea = All;
    Caption = 'Data Archive List';
    PageType = List;
    InsertAllowed = false;
    SourceTable = "Data Archive";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = Administration;
    AdditionalSearchTerms = 'archive, saved, stored';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'This field specifies the entry number for the data archive.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'This field specifies a description for this data archive.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = All;
                    Caption = 'Created On';
                    Editable = false;
                    ToolTip = 'This field specifies when the data archive was created.';
                }
                field(CreatedBy; Rec."Created by User")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'This field specifies which user created the data archive.';
                }
                field("No. of Tables"; Rec."No. of Tables")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'This field specifies the number of tables archived in this data archive.';
                }
                field("No. of Records"; Rec."No. of Records")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'This field specifies the tota number of records archived in this data archive.';
                }
            }
        }
        area(FactBoxes)
        {
            part(ArchiveTables; "Data Archive Table ListPart")
            {
                ApplicationArea = All;
                SubPageLink = "Data Archive Entry No." = FIELD("Entry No.");
            }

        }
    }
    actions
    {
        area(Processing)
        {
            action(NewArchive)
            {
                ApplicationArea = All;
                Caption = 'Create new archive';
                ToolTip = 'Opens the Data Archive - New Archive page that allows you to do a recording of all subsequent deletions in this session.';
                Image = New;
                Promoted = true;

                trigger OnAction()
                begin
                    Page.Run(page::"Data Archive - New Archive");
                end;
            }
        }
        area(Navigation)
        {
            action(SaveAsExcel)
            {
                ApplicationArea = All;
                Caption = 'Save as Excel';
                ToolTip = 'Saves this Data Archive to Excel with one sheet per table.';
                Image = ExportToExcel;
                Promoted = true;

                trigger OnAction()
                var
                    DataArchiveTable: Record "Data Archive Table";
                begin
                    DataArchiveTable.SetRange("Data Archive Entry No.", Rec."Entry No.");
                    Codeunit.Run(Codeunit::"Data Archive Export To Excel", DataArchiveTable);
                end;
            }
            action(SaveToCSV)
            {
                ApplicationArea = All;
                Caption = 'Save as CSV';
                ToolTip = 'Saves this Data Archive to a zip file with one csv file per table.';
                Image = ExportFile;
                Promoted = true;

                trigger OnAction()
                var
                    DataArchiveTable: Record "Data Archive Table";
                begin
                    DataArchiveTable.SetRange("Data Archive Entry No.", Rec."Entry No.");
                    Codeunit.Run(Codeunit::"Data Archive Export to CSV", DataArchiveTable);
                end;
            }
        }
    }
}
