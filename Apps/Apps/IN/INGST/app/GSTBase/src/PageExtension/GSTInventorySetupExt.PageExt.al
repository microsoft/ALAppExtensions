// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Setup;

pageextension 18006 "GST Inventory Setup Ext" extends "Inventory Setup"
{
    layout
    {
        addlast(Numbering)
        {
            field("Service Transfer Order Nos."; Rec."Service Transfer Order Nos.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number series that will be used to assign numbers to service transfer orders.';
            }
            field("Posted Serv. Trans. Rcpt. Nos."; Rec."Posted Serv. Trans. Rcpt. Nos.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number series that will be used to assign numbers to posted service transfer receipts.';
            }
            field("Posted Serv. Trans. Shpt. Nos."; Rec."Posted Serv. Trans. Shpt. Nos.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number series that will be used to assign numbers to posted service transfer shipments.';
            }
            field("Service Rounding Account"; Rec."Service Rounding Account")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the rounding account for service transfer posting.';
            }
            group(TaxInformation)
            {
                Caption = 'Tax Information';
                field("Sub. Component Location"; Rec."Sub. Component Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location from which item will be transferred to subcontracting location or vice versa.';
                }
                field("Job Work Return Period"; Rec."Job Work Return Period")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the stipulated time period for return of material from subcontracting location.';
                }
            }
        }
    }
}
