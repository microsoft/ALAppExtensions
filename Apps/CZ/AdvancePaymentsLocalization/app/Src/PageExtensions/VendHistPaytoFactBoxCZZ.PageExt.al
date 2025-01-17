// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Payables;

pageextension 31218 "Vend.Hist.Pay-to FactBox CZZ" extends "Vendor Hist. Pay-to FactBox"
{
    layout
    {
        addlast(Control23)
        {
            field(AdvancesCZZ; AdvancesCZZ)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advances';
                ToolTip = 'Specifies the number of advance payments that exist for the vendor.';

                trigger OnDrillDown()
                begin
                    DrillDownPurchAdvanceLetters();
                end;
            }
        }
        addlast(Control1)
        {
            field(CueAdvancesCZZ; AdvancesCZZ)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advances';
                ToolTip = 'Specifies the number of advance payments that exist for the vendor.';

                trigger OnDrillDown()
                begin
                    DrillDownPurchAdvanceLetters();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        AdvancesCZZ := Rec.GetPurchaseAdvancesCountCZZ();
    end;

    var
        AdvancesCZZ: Integer;

    local procedure DrillDownPurchAdvanceLetters()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvanceLettersCZZ: Page "Purch. Advance Letters CZZ";
    begin
        PurchAdvLetterHeaderCZZ.SetRange("Pay-to Vendor No.", Rec."No.");
        PurchAdvLetterHeaderCZZ.SetFilter(Status, '%1|%2', PurchAdvLetterHeaderCZZ.Status::"To Pay", PurchAdvLetterHeaderCZZ.Status::"To Use");
        PurchAdvanceLettersCZZ.SetTableView(PurchAdvLetterHeaderCZZ);
        PurchAdvanceLettersCZZ.Run();
    end;
}
