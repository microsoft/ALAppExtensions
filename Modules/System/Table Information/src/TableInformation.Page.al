// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The Table Information page shows information about database tables.
/// </summary>
page 8700 "Table Information"
{
    Caption = 'Table Information';
    AdditionalSearchTerms = 'Database,Size,Storage';
    PageType = List;
    ApplicationArea = All;
    Extensible = true;
    UsageCategory = Lists;
    SourceTable = "Table Information";
    SourceTableView = sorting("Size (KB)") order(descending);
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Permissions = tabledata "Table Information" = r;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The name of the company the table belongs to';
                }

                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The name of the table';
                }

                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The ID number for the table';
                }

                field("No. of Records"; Rec."No. of Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'The number of records in the table';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(GetUrl(CLIENTTYPE::Web, CompanyName, ObjectType::Table, "Table No."));
                    end;
                }

                field("Record Size (Byte)"; Rec."Record Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'The average size of a record (in bytes)';
                }

                field("Size (KB)"; Rec."Size (KB)")
                {
                    ApplicationArea = All;
                    ToolTip = 'How much space the table occupies in the database (in kilobytes)';
                }

                field("Data Size (KB)"; Rec."Data Size (KB)")
                {
                    ApplicationArea = All;
                    ToolTip = 'How much space the table data occupies in the database (in kilobytes)';
                }

                field("Index Size (KB)"; Rec."Index Size (KB)")
                {
                    ApplicationArea = All;
                    ToolTip = 'How much space the table indexes occupy in the database (in kilobytes)';
                }

                field("Compression"; Rec."Compression")
                {
                    ApplicationArea = All;
                    OptionCaption = 'None,Row,Page,,';
                    ToolTip = 'The compression state of the table in the database';
                }
            }
        }
    }

    trigger OnInit()
    var
        UserPermissions: codeunit "User Permissions";
    begin
        Rec.FilterGroup(2);
        if UserPermissions.IsSuper(UserSecurityId()) then
            Rec.SetRange("Company Name")
        else
            Rec.SetFilter("Company Name", '%1|%2', '', CompanyName);
        FilterGroup(0);
    end;
}