// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Receivables;

pageextension 31017 "Cust. Ledg.Entries Preview CZL" extends "Cust. Ledg. Entries Preview"
{
    layout
    {
        addafter("Message to Recipient")
        {
            field("Customer Name CZL"; Rec."Customer Name")
            {
                ApplicationArea = Basic, Suite;
                DrillDown = false;
                ToolTip = 'Specifies the name of customer that you shipped the items.';
                Visible = false;
            }
            field("Customer Posting Group CZL"; Rec."Customer Posting Group")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the customer''s market type to link business transactions to.';
                Visible = false;
            }
        }
    }
}
