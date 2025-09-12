// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Sales.ExcelReports;
using Microsoft.Sales.Reminder;
using Microsoft.Finance.ExcelReports;

pageextension 4435 "EXR Reminder" extends Reminder
{
    actions
    {
        addafter("Customer - Detail Trial Bal.")
        {
            action("Aged Accounts Receivable - Excel")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Aged Accounts Receivable (Excel)';
                Image = "Report";
                RunObject = Report "EXR Aged Accounts Rec Excel";
                ToolTip = 'View an overview of when customer payments are due or overdue, divided into four periods. You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
            }
        }
    }
}