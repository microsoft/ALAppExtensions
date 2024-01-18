// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.AuditCodes;

pageextension 11784 "Source Code Setup CZL" extends "Source Code Setup"
{
    layout
    {
        addafter("Compress Cust. Ledger")
        {
            field("Sales VAT Delay CZL"; Rec."Sales VAT Delay CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the source code for sales VAT delay.';
            }
        }
        addafter("Compress Vend. Ledger")
        {
            field("Purchase VAT Delay CZL"; Rec."Purchase VAT Delay CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the source code for purchase VAT delay.';
            }
            field("VAT LCY Correction CZL"; Rec."VAT LCY Correction CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the source code for VAT correction in LCY.';
            }
        }
        addafter("Close Income Statement")
        {
            field("Close Balance Sheet CZL"; Rec."Close Balance Sheet CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the source code for close balance sheet.';
            }
            field("Open Balance Sheet CZL"; Rec."Open Balance Sheet CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the source code for open balance sheet.';
            }
        }
    }
}
