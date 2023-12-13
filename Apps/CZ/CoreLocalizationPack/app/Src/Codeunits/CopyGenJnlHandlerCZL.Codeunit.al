// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.GeneralLedger.Setup;

codeunit 31063 "Copy Gen. Jnl. Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Gen. Journal Mgt.", 'OnAfterInsertGenJournalLine', '', false, false)]
    local procedure ReplaceVATDateOnAfterInsertGenJournalLine(PostedGenJournalLine: Record "Posted Gen. Journal Line"; CopyGenJournalParameters: Record "Copy Gen. Journal Parameters"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."VAT Reporting Date" := PostedGenJournalLine."VAT Date CZL";
#if not CLEAN22
#pragma warning disable AL0432
        if CopyGenJournalParameters."Replace VAT Date CZL" <> 0D then begin
            GenJournalLine."VAT Date CZL" := CopyGenJournalParameters."Replace VAT Date CZL";
            GenJournalLine."VAT Reporting Date" := CopyGenJournalParameters."Replace VAT Date CZL";
        end;
#pragma warning restore AL0432
#else
        if CopyGenJournalParameters."Replace VAT Date CZL" <> 0D then
            GenJournalLine."VAT Reporting Date" := CopyGenJournalParameters."Replace VAT Date CZL";
#endif
        GenJournalLine.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Gen. Journal Mgt.", 'OnAfterInsertGenJournalLine', '', false, false)]
    local procedure ReverseSignCorrectionOnAfterInsertGenJournalLine(CopyGenJournalParameters: Record "Copy Gen. Journal Parameters"; var GenJournalLine: Record "Gen. Journal Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if not CopyGenJournalParameters."Reverse Sign" then
            exit;

        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Mark Cr. Memos as Corrections" then begin
            GenJournalLine.Validate(Correction, true);
            GenJournalLine.Modify();
        end;
    end;
}
