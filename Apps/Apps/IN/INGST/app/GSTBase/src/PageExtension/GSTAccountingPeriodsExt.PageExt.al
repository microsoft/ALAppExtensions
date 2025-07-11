// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

pageextension 18000 "GST Accounting Periods Ext" extends "Tax Accounting Periods"
{
    layout
    {
        addlast(General)
        {
            field("Credit Memo Locking Date"; Rec."Credit Memo Locking Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a date beyond which credit memo posting will not be allowed for a specific accounting period.';
            }
            field("Annual Return Filed Date"; Rec."Annual Return Filed Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a date by which GST annual return should be filed.';
            }
        }
    }
}
