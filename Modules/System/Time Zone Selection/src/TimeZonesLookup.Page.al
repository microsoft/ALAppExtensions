// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List page that contains all Time zones.
/// </summary>
page 9216 "Time Zones Lookup"
{
    Caption = 'Time Zones';
    PageType = List;
    SourceTable = "Time Zone";
    Permissions = tabledata "Time Zone" = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the time zone.';
                }
                field("Display Name"; Rec."Display Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the full name of the time zone.';
                }
            }
        }
    }

    actions
    {
    }
}

