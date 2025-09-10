// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Purchases.ExcelReports;

using Microsoft.Purchases.Document;
using Microsoft.Finance.ExcelReports;

pageextension 4419 "EXR Purchase Credit Memos" extends "Purchase Credit Memos"
{
    actions
    {
        addfirst(Sales)
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
        addafter("<Report Vendor - Detail Trial ")
        {
            action("Aged Accounts Payable - Excel")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Aged Accounts Payable (Excel)';
                Image = "Report";
                RunObject = Report "EXR Aged Acc Payable Excel";
                ToolTip = 'View an overview of when your payables to vendors are due or overdue (divided into four periods). You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
            }
        }
    }
}