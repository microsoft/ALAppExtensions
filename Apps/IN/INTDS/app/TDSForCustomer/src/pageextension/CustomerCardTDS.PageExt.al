// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

using Microsoft.Finance.TDS.TDSForCustomer;

pageextension 18663 "Customer Card TDS" extends "Customer Card"
{
    actions
    {
        addafter("&Customer")
        {
            action("TDS Customer Allowed Sections")
            {
                Caption = 'TDS Customer Allowed Sections';
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;
                Image = LinkAccount;
                RunObject = Page "Customer Allowed Sections";
                RunPageLink = "Customer No" = field("No.");
                ToolTip = 'Specifies the Allowed Sections on Customer.';
            }
            action("TDS Customer Concessional Codes")
            {
                Caption = 'TDS Customer Concessional Codes';
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Category9;
                Image = LinkAccount;
                RunObject = Page "TDS Cust Concessional Codes";
                RunPageLink = "Customer No." = field("No.");
                ToolTip = 'Specify the Concessional Code if concessional rate is applicable.';
            }
        }
    }
}
