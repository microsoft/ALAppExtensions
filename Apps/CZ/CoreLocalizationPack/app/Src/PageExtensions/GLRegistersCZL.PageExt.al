// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Ledger;

using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Reports;

pageextension 11764 "G/L Registers CZL" extends "G/L Registers"
{
    actions
    {
        addafter("G/L Register")
        {
            action("Accounting Sheets CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Accounting Sheets';
                Image = Report;
                RunObject = report "Accounting Sheets CZL";
                ToolTip = 'View, print, or send a report that shows how a general ledger document was posted on G/L Accounts. You can use this report to document your general ledger transactions with signatures of responsibility persons.';
            }
            action("General Journal CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'General Journal';
                Image = Report;
                RunObject = report "General Journal CZL";
                ToolTip = 'View, print, or send a report that shows a list of general ledger entries sorted by date of posting. You can use this report at the close of an accounting period or fiscal year and to document your general ledger transactions according law requirements.';
            }
            action("G/L Account Group Posting Check CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'G/L Account Group Posting Check';
                Image = Report;
                RunObject = report "G/L Acc. Group Post. Check CZL";
                ToolTip = 'View, print, or send a report that shows a list of general ledger entries sorted by date of posting and document number with different G/L account groups.';
            }
            action("General Ledger Document CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'General Ledger Document';
                Image = Report;
                RunObject = report "General Ledger Document CZL";
                ToolTip = 'View, print, or send a report of transactions posted to general ledger in form of a document.';
            }
        }
    }
}
