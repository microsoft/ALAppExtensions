// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

codeunit 31431 "Reconciliation Handler CZL"
{
    [EventSubscriber(ObjectType::Page, Page::Reconciliation, 'OnAfterSetGenJnlLine', '', false, false)]
    local procedure OnAfterSetGenJnlLine(var GLAccountNetChange: Record "G/L Account Net Change"; var GenJnlLine: Record "Gen. Journal Line")
    var
        GenJnlAlloccation: Record "Gen. Jnl. Allocation";
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
    begin
        GLAccountNetChange.DeleteAll();
        if GenJnlLine.FindSet() then
            repeat
                TempGenJournalLine := GenJnlLine;
                GLAccountNetChange.SaveNetChangeCZL(TempGenJournalLine);
                Codeunit.Run(Codeunit::"Exchange Acc. G/L Journal Line", TempGenJournalLine);
                GLAccountNetChange.SaveNetChangeCZL(TempGenJournalLine);

                GenJnlAlloccation.SetRange("Journal Template Name", TempGenJournalLine."Journal Template Name");
                GenJnlAlloccation.SetRange("Journal Batch Name", TempGenJournalLine."Journal Batch Name");
                GenJnlAlloccation.SetRange("Journal Line No.", TempGenJournalLine."Line No.");
                if GenJnlAlloccation.FindSet() then
                    repeat
                        TempGenJournalLine.Init();
                        TempGenJournalLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
                        TempGenJournalLine.CopyFromGenJnlAllocation(GenJnlAlloccation);
                        GLAccountNetChange.SaveNetChangeCZL(TempGenJournalLine);
                    until GenJnlAlloccation.Next() = 0;
            until GenJnlLine.Next() = 0;

        GLAccountNetChange.Reset();
        GLAccountNetChange.SetCurrentKey("Acc. Type CZL", "Account No. CZL");
    end;

    [EventSubscriber(ObjectType::Page, Page::Reconciliation, 'OnBeforeSaveNetChange', '', false, false)]
    local procedure OnBeforeSaveNetChange(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
#if not CLEAN27
    internal procedure RaiseOnSetSaveNetChangeBeforeModifyGLAccountNetChange(var GLAccountNetChange: Record "G/L Account Net Change"; GenJournalLine: Record "Gen. Journal Line"; NetChangeLCY: Decimal; NetChange: Decimal)
    begin
        OnSetSaveNetChangeBeforeModifyGLAccountNetChange(GLAccountNetChange, GenJournalLine, NetChangeLCY, NetChange);
    end;

    internal procedure RaiseOnSetSaveNetChangeBeforeInsertGLAccountNetChange(var GLAccountNetChange: Record "G/L Account Net Change"; GenJournalLine: Record "Gen. Journal Line"; NetChangeLCY: Decimal; NetChange: Decimal)
    begin
        OnSetSaveNetChangeBeforeInsertGLAccountNetChange(GLAccountNetChange, GenJournalLine, NetChangeLCY, NetChange);
    end;

    [Obsolete('Replaced by OnSaveNetChangeCZLOnBeforeModify event in tableextension 31047 "G/L Account Net Change CZL"', '27.0')]
    [IntegrationEvent(false, false)]
    local procedure OnSetSaveNetChangeBeforeModifyGLAccountNetChange(var GLAccountNetChange: Record "G/L Account Net Change"; GenJournalLine: Record "Gen. Journal Line"; NetChangeLCY: Decimal; NetChange: Decimal)
    begin
    end;

    [Obsolete('Replaced by OnSaveNetChangeCZLOnBeforeInsert event in tableextension 31047 "G/L Account Net Change CZL"', '27.0')]
    [IntegrationEvent(false, false)]
    local procedure OnSetSaveNetChangeBeforeInsertGLAccountNetChange(var GLAccountNetChange: Record "G/L Account Net Change"; GenJournalLine: Record "Gen. Journal Line"; NetChangeLCY: Decimal; NetChange: Decimal)
    begin
    end;
#endif
}
