// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Account;

using Microsoft.Finance.GeneralLedger.Reports;

pageextension 31259 "Chart of Accounts CZA" extends "Chart of Accounts"
{
    actions
    {
        addlast(reporting)
        {
            action("Open G/L Entries To Date CZA")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open G/L Entries To Date';
                Image = EntriesList;
                RunObject = Report "Open G/L Entries To Date CZA";
                ToolTip = 'View the list of open G/L entries to specific date.';
            }

            action("Inventory Account To Date CZA")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Inventory Account to the date';
                Image = Inventory;
                RunObject = Report "Inventory Account To Date CZA";
                ToolTip = 'View the inventory account to specific date.';
            }
        }
        addlast("Periodic Activities")
        {
            action("G/L Entry Applying CZA")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'G/L Entry Applying';
                Image = ApplyEntries;
                RunObject = Report "G/L Entry Applying CZA";
                ToolTip = 'Apply the G/L Entries.';
            }
        }
        addfirst(Category_Report)
        {
            actionref("Open G/L Entries To Date CZA_Promoted"; "Open G/L Entries To Date CZA")
            {
            }
            actionref("Inventory Account To Date CZA_Promoted"; "Inventory Account To Date CZA")
            {
            }
        }
        addfirst(Category_Process)
        {
            actionref("G/L Entry Applying CZA_Promoted"; "G/L Entry Applying CZA")
            {
            }
        }
    }
}
