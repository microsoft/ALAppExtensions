// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

pageextension 18943 "Cash Receipt Voucher" extends "Cash Receipt Voucher"
{
    layout
    {
        addafter("Bal. Account No.")
        {
            field("Cheque No."; "Cheque No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cheque number of the journal entry.';
            }
            field("Cheque Date"; "Cheque Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the cheque date of the journal entry.';
            }
        }
    }
}
