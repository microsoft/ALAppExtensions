// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.VAT;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;

codeunit 31127 "VAT Rep. Date Mgt. Handler CZZ"
{
    Access = Internal;
    Permissions = tabledata "Purch. Adv. Letter Entry CZZ" = m,
                  tabledata "Sales Adv. Letter Entry CZZ" = m,
                  tabledata "G/L Entry" = m,
                  tabledata "VAT Entry" = m;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VAT Reporting Date Mgt", 'OnBeforeUpdateLinkedEntries', '', false, false)]
    local procedure CheckRelatedVATEntriesOnBeforeUpdateLinkedEntries(VATEntry: Record "VAT Entry"; var IsHandled: Boolean)
    var
        RelatedVATEntry: Record "VAT Entry";
        TempVATEntry: Record "VAT Entry" temporary;
        ConfVATEntUpdateMgtCZL: Codeunit "Conf. VAT Ent. Update Mgt. CZL";
    begin
        if IsHandled then
            exit;

        FilterRelatedVATEntries(VATEntry, RelatedVATEntry);
        if not RelatedVATEntry.IsEmpty() then begin
            RelatedVATEntry.ToTemporaryCZL(TempVATEntry);
            if not ConfVATEntUpdateMgtCZL.GetResponseOrDefault(TempVATEntry, true) then
                Error('');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VAT Reporting Date Mgt", 'OnAfterUpdateLinkedEntries', '', false, false)]
    local procedure UpdateAdvanceLedgerEntriesOnAfterUpdateLinkedEntries(VATEntry: Record "VAT Entry")
    var
        PurchAdvLetterEntry: Record "Purch. Adv. Letter Entry CZZ";
        SalesAdvLetterEntry: Record "Sales Adv. Letter Entry CZZ";
    begin
        case VATEntry.Type of
            VATEntry.Type::Sale:
                begin
                    SalesAdvLetterEntry.LoadFields("Entry No.", "Document No.", "Posting Date", "VAT Date");
                    SalesAdvLetterEntry.SetCurrentKey("Document No.", "Posting Date");
                    SalesAdvLetterEntry.SetRange("Document No.", VATEntry."Document No.");
                    SalesAdvLetterEntry.SetRange("Posting Date", VATEntry."Posting Date");
                    SalesAdvLetterEntry.SetFilter("VAT Date", '<>%1', 0D);
                    SalesAdvLetterEntry.ModifyAll("VAT Date", VATEntry."VAT Reporting Date");
                end;
            VATEntry.Type::Purchase:
                begin
                    PurchAdvLetterEntry.LoadFields("Entry No.", "Document No.", "Posting Date", "VAT Date");
                    PurchAdvLetterEntry.SetCurrentKey("Document No.", "Posting Date");
                    PurchAdvLetterEntry.SetRange("Document No.", VATEntry."Document No.");
                    PurchAdvLetterEntry.SetRange("Posting Date", VATEntry."Posting Date");
                    PurchAdvLetterEntry.SetFilter("VAT Date", '<>%1', 0D);
                    PurchAdvLetterEntry.ModifyAll("VAT Date", VATEntry."VAT Reporting Date");
                end;
        end;

        UpdateRelatedVATEntries(VATEntry);
        UpdateRelatedGLEntries(VATEntry);
    end;

    local procedure FilterRelatedVATEntries(VATEntry: Record "VAT Entry"; var RelatedVATEntry: Record "VAT Entry")
    begin
        RelatedVATEntry.SetFilter("Entry No.", '<>%1', VATEntry."Entry No.");
        RelatedVATEntry.SetFilter("VAT Reporting Date", '<>%1', VATEntry."VAT Reporting Date");
        RelatedVATEntry.SetRange(Type, VATEntry.Type);
        RelatedVATEntry.SetRange("Document No.", VATEntry."Document No.");
        RelatedVATEntry.SetRange("Posting Date", VATEntry."Posting Date");
    end;

    local procedure FilterRelatedGLEntries(VATEntry: Record "VAT Entry"; var RelatedGLEntry: Record "G/L Entry")
    begin
        RelatedGLEntry.SetFilter("Transaction No.", '<>%1', VATEntry."Transaction No.");
        RelatedGLEntry.SetFilter("VAT Reporting Date", '<>%1', VATEntry."VAT Reporting Date");
        RelatedGLEntry.SetRange("Document No.", VATEntry."Document No.");
        RelatedGLEntry.SetRange("Posting Date", VATEntry."Posting Date");
    end;

    local procedure UpdateRelatedVATEntries(VATEntry: Record "VAT Entry")
    var
        RelatedVATEntry: Record "VAT Entry";
    begin
        RelatedVATEntry.LoadFields("Entry No.", Type, "Document No.", "Posting Date", "VAT Reporting Date");
        FilterRelatedVATEntries(VATEntry, RelatedVATEntry);
        RelatedVATEntry.ModifyAll("VAT Reporting Date", VATEntry."VAT Reporting Date")
    end;

    local procedure UpdateRelatedGLEntries(VATEntry: Record "VAT Entry")
    var
        RelatedGLEntry: Record "G/L Entry";
    begin
        RelatedGLEntry.LoadFields("Entry No.", "Document No.", "Posting Date", "Transaction No.", "VAT Reporting Date");
        FilterRelatedGLEntries(VATEntry, RelatedGLEntry);
        RelatedGLEntry.ModifyAll("VAT Reporting Date", VATEntry."VAT Reporting Date")
    end;
}
