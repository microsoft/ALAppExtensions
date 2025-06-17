// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.RoleCenters;

pageextension 8011 "Acc. Payable Administrator RC" extends "Acc. Payable Administrator RC"
{
    actions
    {
        addlast(CreatePurchaseDocuments)
        {
            action(VendorContract)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Vendor Contract';
                Image = FileContract;
                ToolTip = 'Create a vendor contract.';
                RunObject = Page "Vendor Contract";
                RunPageMode = Create;
            }
        }
    }
}
