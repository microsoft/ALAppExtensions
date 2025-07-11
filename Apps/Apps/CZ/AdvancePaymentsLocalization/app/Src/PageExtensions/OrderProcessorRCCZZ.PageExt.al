// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.RoleCenters;

pageextension 31105 "Order Processor RC CZZ" extends "Order Processor Role Center"
{
    actions
    {
        addafter(SalesOrders)
        {
            action(SalesAdvLettersAfterOrdersCZZ)
            {
                Caption = 'Sales Advance Letters';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Show sales advance letters.';
                RunObject = Page "Sales Advance Letters CZZ";
                RunPageView = where(Status = filter(New | "To Pay" | "To Use"));
            }
        }
        addafter("Sales Credit Memos")
        {
            action(SalesAdvLettersAfterCMCZZ)
            {
                Caption = 'Sales Advance Letters';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Show sales advance letters.';
                RunObject = Page "Sales Advance Letters CZZ";
                RunPageView = where(Status = filter(New | "To Pay" | "To Use"));
            }
        }
        addafter("Purchase Credit Memos")
        {
            action(PurchAdvLettersCZZ)
            {
                Caption = 'Purchase Advance Letters';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Show purchase advance letters.';
                RunObject = Page "Purch. Advance Letters CZZ";
                RunPageView = where(Status = filter(New | "To Pay" | "To Use"));
            }
        }
    }
}
