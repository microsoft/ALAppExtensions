// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Finance.GeneralLedger.Journal;

pageextension 30124 "Shpfy Cash Receipt Journal" extends "Cash Receipt Journal"
{
    actions
    {
        addlast(processing)
        {
            action(SuggestShopifyPayments)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Suggest Shopify Payments';
                Ellipsis = true;
                Image = SuggestPayment;
                ToolTip = 'Create payment suggestions from Shopify transactions as lines in the cash receipt journal.';
                Visible = ShopifyActionVisible;

                trigger OnAction()
                var
                    SuggestPayments: Report "Shpfy Suggest Payments";
                begin
                    Clear(SuggestPayments);
                    SuggestPayments.SetGenJournalLine(Rec);
                    SuggestPayments.RunModal();
                end;
            }
        }
        addbefore("Category_Request Approval")
        {
            group(Category_Prepare)
            {
                Caption = 'Prepare';

                actionref(SuggestShopifyPayments_Promoted; SuggestShopifyPayments)
                {
                }
            }
        }
    }

    var
        ShopifyActionVisible: Boolean;

    trigger OnOpenPage()
    var
        Shop: Record "Shpfy Shop";
        OrderTransaction: Record "Shpfy Order Transaction";
    begin
        Shop.SetRange(Enabled, true);
        if not Shop.IsEmpty() then
            if not OrderTransaction.IsEmpty() then
                ShopifyActionVisible := true;
    end;
}