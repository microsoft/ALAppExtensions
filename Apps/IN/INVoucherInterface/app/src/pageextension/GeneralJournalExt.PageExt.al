// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

pageextension 18939 "General Journal Ext" extends "General Journal"
{
    layout
    {
        addafter("Bank Payment Type")
        {
            field("Cheque Date"; "Cheque Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cheque date of the journal entry.';
            }
            field("Cheque No."; "Cheque No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cheque number of the journal entry.';
            }
            field("Check Printed"; "Check Printed")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if cheque is printed for the journal entry.';
            }
        }
    }
}
