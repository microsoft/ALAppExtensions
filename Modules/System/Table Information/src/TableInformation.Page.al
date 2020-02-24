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
    SourceTableView = sorting("Table Name");
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
                }

                field("Record Size (Byte)"; "Record Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'A value expressing the average size of a record, calculated as 1024 x Size (KB)/Records';
                }

                field("Size (KB)"; "Size (KB)")
                {
                    ApplicationArea = All;
                    ToolTip = 'How much space the table occupies in the database (in kilobytes)';
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
            SetFilter("Company Name", '=%1|%2', CompanyName, '')
        else
            SetRange("Company Name", CompanyName);
        FilterGroup(0);
    end;
}