// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.DataAdministration;

/// <summary>
/// The Table Information Cache Part page shows information about database tables.
/// </summary>
page 8701 "Table Information Cache Part"
{
    Caption = 'Table Information';
    AdditionalSearchTerms = 'Database,Size,Storage';
    PageType = ListPart;
    Extensible = false;
    SourceTable = "Table Information Cache";
    SourceTableView = sorting("Data Size (KB)") order(descending);
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Permissions = tabledata "Table Information Cache" = r;


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                FreezeColumn = "Table Name";

                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the table.';
                }

                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the company the table belongs to.';
                }

                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the table.';
                    Visible = false;
                }

                field("No. of Records"; Rec."No. of Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total number of records stored in the table.';

                    trigger OnDrillDown()
                    var
                        TableInformationCacheImpl: Codeunit "Table Information Cache Impl.";
                    begin
                        Hyperlink(TableInformationCacheImpl.GetTableUrl(Rec."Company Name", Rec."Table No."));
                    end;
                }

                field("Record Size (Byte)"; Rec."Record Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the average record size (in bytes).';
                    Visible = false;
                }

                field("Size (KB)"; Rec."Size (KB)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total amount of space the table occupies in the database (in kilobytes).';
                    Visible = false;
                }

                field("Data Size (KB)"; Rec."Data Size (KB)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how much space the table data occupies in the database (in kilobytes).';
                }

                field("Index Size (KB)"; Rec."Index Size (KB)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how much space the table indexes (keys) occupy in the database (in kilobytes).';
                    Visible = false;
                }

                field("Compression"; Rec."Compression")
                {
                    ApplicationArea = All;
                    OptionCaption = 'None,Row,Page,,';
                    ToolTip = 'Specifies the type of compression that is applied to the table in the database.';
                    Visible = false;
                }
                field("Last Period Size"; Rec."Last Period Data Size (KB)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how much space the table occupied in the database 30 days ago (in kilobytes).';
                }
                field("Last Period No. of Records"; Rec."Last Period No. of Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of records in the table 30 days ago.';
                    visible = false;
                }
                field("Growth %"; Rec."Growth %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how much the table size grew in 30 days (in percent).';
                }
            }
        }
    }

    trigger OnInit()
    var
        TableInformationCacheImpl: Codeunit "Table Information Cache Impl.";
    begin
        TableInformationCacheImpl.SetBiggestTablesFilter(Rec);
    end;
}
