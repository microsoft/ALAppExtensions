// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.GeneralLedger.Journal;

pageextension 31269 "Reconciliation CZP" extends Reconciliation
{
    procedure SetCashDocumentHeaderCZP(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        Rec.DeleteAll();
        Rec.SaveNetChangeCZL(PopulateGenJournalLineFrom(CashDocumentHeaderCZP));

        CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
        if CashDocumentLineCZP.FindSet() then
            repeat
                Rec.SaveNetChangeCZL(PopulateGenJournalLineFrom(CashDocumentLineCZP));
            until CashDocumentLineCZP.Next() = 0;

        Rec.Reset();
        Rec.SetCurrentKey("Acc. Type CZL", "Account No. CZL");
    end;

    local procedure PopulateGenJournalLineFrom(CashDocumentHeaderCZP: Record "Cash Document Header CZP") GenJournalLine: Record "Gen. Journal Line"
    var
        TotalCashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        TotalCashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
        TotalCashDocumentLineCZP.CalcSums(Amount, "VAT Amount", "Amount (LCY)", "VAT Amount (LCY)");

        GenJournalLine."Account Type" := Enum::"Net Change Account Type CZL"::"Cash Desk CZP";
        GenJournalLine."Account No." := CashDocumentHeaderCZP."Cash Desk No.";
        GenJournalLine."Currency Code" := CashDocumentHeaderCZP."Currency Code";
        GenJournalLine."Amount" := -TotalCashDocumentLineCZP."Amount";
        GenJournalLine."VAT Amount" := -TotalCashDocumentLineCZP."VAT Amount";
        GenJournalLine."Amount (LCY)" := -TotalCashDocumentLineCZP."Amount (LCY)";
        GenJournalLine."VAT Amount (LCY)" := -TotalCashDocumentLineCZP."VAT Amount (LCY)";
    end;

    local procedure PopulateGenJournalLineFrom(CashDocumentLineCZP: Record "Cash Document Line CZP") GenJournalLine: Record "Gen. Journal Line"
    begin
        GenJournalLine."Account Type" := CashDocumentLineCZP.AccountTypeToNetChangeAccountType();
        GenJournalLine."Account No." := CashDocumentLineCZP."Account No.";
        GenJournalLine."Currency Code" := CashDocumentLineCZP."Currency Code";
        GenJournalLine."Amount" := CashDocumentLineCZP."Amount";
        GenJournalLine."VAT Amount" := CashDocumentLineCZP."VAT Amount";
        GenJournalLine."Amount (LCY)" := CashDocumentLineCZP."Amount (LCY)";
        GenJournalLine."VAT Amount (LCY)" := CashDocumentLineCZP."VAT Amount (LCY)";
    end;
}
