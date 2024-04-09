// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Setup;

pageextension 14606 "IS Sales & Receivables Setup" extends "Sales & Receivables Setup"
{
    layout
    {
        addafter(Printing)
        {
            field("Electronic Invoicing Reminder"; Rec."Electronic Invoicing Reminder")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the company complies with the requirement of tracking invoicing electronically, when printing invoices in single copy.';
#if not CLEAN24
                Visible = IsISCoreAppEnabled;
                Enabled = IsISCoreAppEnabled;
#endif
            }
        }
    }
}
