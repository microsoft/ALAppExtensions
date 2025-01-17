// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.GeneralLedger.Reports;

pageextension 11777 "General Journal Batches CZL" extends "General Journal Batches"
{
    layout
    {
        addlast(Control1)
        {
            field("Allow Hybrid Document CZL"; Rec."Allow Hybrid Document CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether disabling balance check by Correction field.';
            }
        }
    }
    actions
    {
        addafter(Action10)
        {
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
