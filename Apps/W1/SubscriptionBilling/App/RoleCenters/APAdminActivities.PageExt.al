// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.SubscriptionBilling;

using Microsoft.Finance.RoleCenters;

pageextension 8013 "A/P Admin Activities" extends "A/P Admin Activities"
{
    layout
    {
        addafter("Purch. Invoices Due Next Week")
        {
            field("Vendor Contracts"; this.VendorContracts)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Vendor Contracts';
                DrillDownPageID = "Vendor Contracts";
                Tooltip = 'Specifies the number of vendor contracts.';
            }
        }
    }

    var
        VendorContracts: Integer;

    trigger OnOpenPage()
    var
        VendorContract: Record "Vendor Subscription Contract";
    begin
        this.VendorContracts := VendorContract.Count();
    end;
}
