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
    PageType = List;
    ApplicationArea = All;
    Extensible = false;
    UsageCategory = Lists;
    SourceTable = "Table Information";
    SourceTableView = sorting("Size (KB)") order(descending);
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The name of the company the table belongs to';
                }

                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The name of the table';
                }

                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The ID number for the table';
                }

                field("No. of Records"; "No. of Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'The number of records in the table';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(GetUrl(CLIENTTYPE::Web, CompanyName, ObjectType::Table, "Table No."));
                    end;
                }

                field("Record Size (Byte)"; "Record Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'The average size of a record (in bytes)';
                }

                field("Size (KB)"; "Size (KB)")
                {
                    ApplicationArea = All;
                    ToolTip = 'How much space the table occupies in the database (in kilobytes)';
                }
                field("Compression"; "Compression")
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
        FilterGroup(2);
        if UserPermissions.IsSuper(UserSecurityId()) then
            SetRange("Company Name")
        else
            SetRange("Company Name", CompanyName);
        FilterGroup(0);
    end;
}