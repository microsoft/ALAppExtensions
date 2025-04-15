// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.ExcelReports;
using Microsoft.Finance.RoleCenters;
using Microsoft.Finance.ExcelReports;

pageextension 4437 "EXR Acc. Pay. Coordinator RC" extends "Acc. Payables Coordinator RC"
{
    actions
    {
        addafter("Vendor - &Balance to date")
        {
            action(EXRAgedAccountsPayExcel)
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