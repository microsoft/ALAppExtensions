// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

using Microsoft.Finance.TDS.TDSBase;

pageextension 18687 "TDS-VendorCard" extends "Vendor Card"
{
    actions
    {
        addafter("Ven&dor")
        {
            action("Vendor Sections")
            {
                Caption = 'Allowed Sections';
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;
                Image = Process;
                RunObject = Page "Allowed Sections";
                ToolTip = 'View or add TDS section for the record.';
                RunPageLink = "Vendor No" = field("No.");
            }
            action("TDS Concessional Codes")
            {
                Caption = 'TDS Concessional Codes';
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Category9;
                PromotedIsBig = true;
                Image = ServiceCode;
                ToolTip = 'View or add TDS concessional code of allowed TDS section for the record.';
                RunObject = Page "TDS Concessional Codes";
                RunPageLink = "Vendor No." = field("No.");
            }
        }
    }
}
