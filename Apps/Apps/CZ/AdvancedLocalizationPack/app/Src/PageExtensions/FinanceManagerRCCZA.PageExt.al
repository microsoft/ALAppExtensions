// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

using Microsoft.Finance.GeneralLedger.Reports;

pageextension 31260 "Finance Manager RC CZA" extends "Finance Manager Role Center"
{
    actions
    {
        addlast(Group)
        {
            action("G/L Entry Applying CZA")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'G/L Entry Applying';
                RunObject = report "G/L Entry Applying CZA";
                ToolTip = 'Apply the G/L Entries.';
            }
        }
        addlast(Group10)
        {
            action("Open G/L Entries To Date CZA")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open G/L Entries To Date';
                RunObject = report "Open G/L Entries To Date CZA";
                ToolTip = 'View the list of open G/L entries to specific date.';
            }
            action("Inventory Account To Date CZA")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Inventory Account to the date';
                RunObject = report "Inventory Account To Date CZA";
                ToolTip = 'View the inventory account to specific date.';
            }
        }
    }
}
