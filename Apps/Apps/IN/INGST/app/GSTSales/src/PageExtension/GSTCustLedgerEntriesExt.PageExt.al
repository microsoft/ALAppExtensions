// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Receivables;

pageextension 18141 "GST Cust. Ledger Entries Ext" extends "Customer Ledger Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("GST Group Code"; Rec."GST Group Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an unique identifier for the GST group code used to calculate and post GST.';
            }
            field("HSN/SAC Code"; Rec."HSN/SAC Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an unique identifier for the type of HSN or SAC that is used to calculate and post GST.';
            }

            field("GST on Advance Payment"; Rec."GST on Advance Payment")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if GST is required to be calculated on Advance Payment.';
            }

            field("GST Without Payment of Duty"; Rec."GST Without Payment of Duty")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the GST is paid without duty.';
            }

            field("GST Customer Type"; Rec."GST Customer Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of the customer. For example, Registered, Unregistered, Export etc..';
            }
            field("Seller State Code"; Rec."Seller State Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Customer state code that the entry is posted to.';
            }

            field("Seller GST Reg. No."; Rec."Seller GST Reg. No.")
            {
                ToolTip = 'Specifies the GST registration number of the Seller specified on the journal line.';
                ApplicationArea = Basic, Suite;
            }

            field("Location Code"; Rec."Location Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the location code for which the journal lines will be posted.';
            }

            field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type related to GST jurisdiction. For example interstate/intrastate.';
            }

            field("Location State Code"; Rec."Location State Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the location state of the posted entry.';
            }

            field("Location GST Reg. No."; Rec."Location GST Reg. No.")
            {
                ToolTip = 'Specifies the GST Registration number of the location used in posted entry.';
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
