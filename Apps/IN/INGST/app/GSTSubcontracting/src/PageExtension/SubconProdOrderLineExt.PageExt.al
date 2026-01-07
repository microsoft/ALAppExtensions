// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Document;

using Microsoft.Finance.GST.Subcontracting;
using Microsoft.Purchases.Document;

pageextension 18466 "Subcon ProdOrder Line Ext" extends "Released Prod. Order Lines"
{
    layout
    {
        addafter("Cost Amount")
        {
            field("Subcontracting Order No."; Rec."Subcontracting Order No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the subcontracting order number.';

                trigger OnDrillDown()
                begin
                    PurchaseHeader.Reset();
                    PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
                    PurchaseHeader.SetRange("No.", Rec."Subcontracting Order No.");
                    PurchaseHeader.SetRange(Subcontracting, true);

                    Page.Run(Page::"Subcontracting Order List", PurchaseHeader);
                end;
            }
            field("Subcontractor Code"; Rec."Subcontractor Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the subcontracting vendor number the order belongs to.';
            }
        }
    }
    var
        PurchaseHeader: Record "Purchase Header";
}
