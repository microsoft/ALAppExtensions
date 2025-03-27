namespace Microsoft.eServices.EDocument;

using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Document;

page 6104 "E-Doc. A/P Admin Activities"
{
    Caption = 'Activities';
    PageType = CardPart;
    SourceTable = "E-Doc. Account Payable Cue";

    layout
    {
        area(Content)
        {
            cuegroup(WideCues)
            {
                CuegroupLayout = Wide;
                ShowCaption = false;

                field("Purchase This Month"; Rec."Purchase This Month")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Purchase Invoices";
                    ToolTip = 'Specifies the total amount of purchase invoices for the current month.';

                    trigger OnDrillDown()
                    var
                        VendorLedgerEntry: Record "Vendor Ledger Entry";
                    begin
                        VendorLedgerEntry.SetFilter("Document Type", '%1|%2',
                            VendorLedgerEntry."Document Type"::Invoice, VendorLedgerEntry."Document Type"::"Credit Memo");
                        VendorLedgerEntry.SetRange("Posting Date", CalcDate('<-CM>', Rec.GetDefaultWorkDate()), Rec.GetDefaultWorkDate());
                        Page.Run(Page::"Vendor Ledger Entries", VendorLedgerEntry);
                    end;
                }
                field("Overdue Purchase Documents"; Rec."Overdue Purchase Documents")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDownPageID = "Vendor Ledger Entries";
                    ToolTip = 'Specifies the number of purchase invoices where your payment is late.';
                }

            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        Rec.SetFilter("Overdue Date Filter", '<=%1', WorkDate());
        Rec.SetRange("Posting Date Filter", CalcDate('<-CM>', Rec.GetDefaultWorkDate()), Rec.GetDefaultWorkDate());
    end;
}
