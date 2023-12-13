// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Counting.Journal;

using Microsoft.Inventory.Reports;

pageextension 31002 "Phys. Invt. Ledger Entries CZL" extends "Phys. Inventory Ledger Entries"
{
    actions
    {
#pragma warning disable AL0432
        addlast(reporting)
#pragma warning restore AL0432
        {
            action(PhysInventoryDocumentCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Counting Document';
                Image = Print;
                Ellipsis = true;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Print physical inventory counting document.';

                trigger OnAction()
                var
                    PhysInventoryLedgerEntry: Record "Phys. Inventory Ledger Entry";
                begin
                    PhysInventoryLedgerEntry.SetRange("Document No.", Rec."Document No.");
                    PhysInventoryLedgerEntry.SetRange("Posting Date", Rec."Posting Date");
                    Report.Run(Report::"Phys. Inventory Document CZL", true, false, PhysInventoryLedgerEntry);
                end;
            }
        }
    }
}
