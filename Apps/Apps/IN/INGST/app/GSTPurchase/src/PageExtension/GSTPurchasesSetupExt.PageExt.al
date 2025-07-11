// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Setup;

pageextension 18088 "GST Purchases Setup Ext" extends "Purchases & Payables Setup"
{
    layout
    {
        addlast("Number Series")
        {
            field("GST Liability Adj. Jnl Nos."; Rec."GST Liability Adj. Jnl Nos.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for the number series that will be used to assign numbers to GST liability journal.';
            }
            field("RCM Exempt start Date (Unreg)"; Rec."RCM Exempt start Date (Unreg)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the RCM Exepmt Start Date.';
            }
            field("RCM Exempt End Date (Unreg)"; Rec."RCM Exempt End Date (Unreg)")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the RCM Exepmt End Date.';
            }
            field("Delivery Challan Nos."; Rec."Delivery Challan Nos.")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies the number series code used for delivery challan.';
            }
            field("Posted Delivery Challan Nos."; Rec."Posted Delivery Challan Nos.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number series code used for posted delivery challan.';
            }
            field("Multiple Subcon. Order Det Nos"; Rec."Multiple Subcon. Order Det Nos")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies the number series code used for multiple subcontracting order details document.';
            }
            field("Subcontracting Order Nos."; Rec."Subcontracting Order Nos.")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies the number series code used for subcontracting order.';
            }
            field("Posted SC Comp. Rcpt. Nos."; Rec."Posted SC Comp. Rcpt. Nos.")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies the identification code for posted subcontracting component receipt numbers for receipt number transaction.';
            }
        }
    }
}
