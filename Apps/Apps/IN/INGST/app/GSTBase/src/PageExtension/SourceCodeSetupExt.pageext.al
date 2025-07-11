// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.AuditCodes;

pageextension 18014 "Source Code Setup Ext" extends "Source Code Setup"
{
    layout
    {
        // Add changes to page layout here
        addlast(General)
        {
            field("Service Transfer Shipment"; Rec."Service Transfer Shipment")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for Service transfer shipment.';
            }
            field("Service Transfer Receipt"; Rec."Service Transfer Receipt")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for Service transfer receipt.';
            }
            field("GST Credit Adjustment Journal"; Rec."GST Credit Adjustment Journal")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for GST credit adjustment journal';
            }
            field("GST Settlement"; Rec."GST Settlement")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for GST settlement.';
            }
            field("GST Distribution"; Rec."GST Distribution")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for GST distribution.';
            }
            field("GST Liability Adjustment"; Rec."GST Liability Adjustment")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for GST liability adjustment.';
            }
            field("GST Adjustment Journal"; Rec."GST Adjustment Journal")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for the GST adjustment journal.';
            }
            field("GST Liability - Job Work"; Rec."GST Liability - Job Work")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the identification code for GST liability for job work transaction.';
            }
            field("GST Receipt - Job Work"; Rec."GST Receipt - Job Work")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the identification code for GST receipt for job work transaction.';
            }
        }
    }
}
