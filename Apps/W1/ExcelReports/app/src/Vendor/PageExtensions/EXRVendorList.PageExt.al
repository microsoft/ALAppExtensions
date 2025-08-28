// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Purchases.ExcelReports;

using Microsoft.Purchases.Vendor;
using Microsoft.Finance.ExcelReports;

pageextension 4418 "EXR Vendor List" extends "Vendor List"
{
    actions
    {
        addafter("Vendor - Labels")
        {
            action("Vendor Top List - Excel")
            {
                ApplicationArea = Suite;
                Caption = 'Vendor - Top List (Excel)';
                Image = "Report";
                RunObject = Report "EXR Vendor Top List";
                ToolTip = 'View a list of the vendors from whom you purchase the most or to whom you owe the most.';
            }
        }
        addfirst("Financial Management")
        {
            action("Aged Accounts Payable - Excel")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Aged Accounts Payable (Excel)';
                Image = "Report";
                RunObject = Report "EXR Aged Acc Payable Excel";
                ToolTip = 'View a list of aged remaining balances for each vendor.';
            }
        }
    }
}