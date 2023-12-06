// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Sales.Document;

pageextension 31219 "Sales Hist.Sell-to FactBox CZZ" extends "Sales Hist. Sell-to FactBox"
{
    layout
    {
        addlast(Control23)
        {
            field(AdvancesCZZ; AdvancesCZZ)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advances';
                ToolTip = 'Specifies the number of advance payments that exist for the customer.';

                trigger OnDrillDown()
                begin
                    DrillDownPurchAdvanceLetters();
                end;
            }
        }
        addlast(Control2)
        {
            field(CueAdvancesCZZ; AdvancesCZZ)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Advances';
                ToolTip = 'Specifies the number of advance payments that exist for the customer.';

                trigger OnDrillDown()
                begin
                    DrillDownPurchAdvanceLetters();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        AdvancesCZZ := Rec.GetSalesAdvancesCountCZZ();
    end;

    var
        AdvancesCZZ: Integer;

    local procedure DrillDownPurchAdvanceLetters()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvanceLettersCZZ: Page "Sales Advance Letters CZZ";
    begin
        SalesAdvLetterHeaderCZZ.SetRange("Bill-to Customer No.", Rec."No.");
        SalesAdvLetterHeaderCZZ.SetFilter(Status, '%1|%2', SalesAdvLetterHeaderCZZ.Status::"To Pay", SalesAdvLetterHeaderCZZ.Status::"To Use");
        SalesAdvanceLettersCZZ.SetTableView(SalesAdvLetterHeaderCZZ);
        SalesAdvanceLettersCZZ.Run();
    end;
}
