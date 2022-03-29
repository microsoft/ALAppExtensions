// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List part page to integrate the plan configurations.
/// </summary>
page 9065 "Plan Configurations Part"
{
    Caption = 'License Configurations';
    Editable = false;
    PageType = ListPart;
    SourceTable = "Plan Configuration";
    CardPageID = "Plan Configuration Card";
    Permissions = tabledata "Plan Configuration" = r;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Plan Name"; Rec."Plan Name")
                {
                    ApplicationArea = All;
                    Caption = 'Licenses';
                    ToolTip = 'Specifies the name of the license.';
                }
                field(Customized; Rec.Customized)
                {
                    ApplicationArea = All;
                    Caption = 'Permissions Customized';
                    ToolTip = 'Specifies if the permissions are customized.';
                }
            }
        }
    }
}
