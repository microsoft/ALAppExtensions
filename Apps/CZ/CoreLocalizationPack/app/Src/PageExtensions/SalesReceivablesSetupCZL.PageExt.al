// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Sales.Setup;

pageextension 11718 "Sales & Receivables Setup CZL" extends "Sales & Receivables Setup"
{
    layout
    {
        addlast(General)
        {
            field("Print QR Payment CZL"; Rec."Print QR Payment CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether to print a code for QR payment on Sales Invoices and Advances';
            }
        }
    }
}

