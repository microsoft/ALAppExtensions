// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A list part factbox to view related entities for Word templates.
/// </summary>
page 9982 "Word Templates Related FactBox"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'Related Entities';
    SourceTable = "Word Templates Related Table";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Permissions = tabledata "Word Templates Related Table" = r;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Tables)
            {
                Caption = 'Related Entities';

                field("Table ID"; Rec."Related Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the id of the related entity.';
                    Visible = false;
                }
                field("Table Caption"; Rec."Related Table Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the related entity.';
                    Editable = false;
                }
                field("Related Table Code"; Rec."Related Table Code")
                {
                    ApplicationArea = All;
                    Caption = 'Field Prefix';
                    ToolTip = 'Specifies a prefix that will indicate that the field is from the related entity when you are setting up the template. For example, if you enter SALES, the field names are prefixed with SALES_. The prefix must be unique.';
                }
            }
        }
    }
}