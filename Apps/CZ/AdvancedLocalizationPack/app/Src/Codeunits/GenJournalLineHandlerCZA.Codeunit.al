// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

using Microsoft.Finance.GeneralLedger.Ledger;

codeunit 31380 "Gen. Journal Line Handler CZA"
{
    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterClearCustVendApplnEntry', '', false, false)]
    local procedure GLEntryPostApplicationOnAfterClearCustVendApplnEntry(xGenJournalLine: Record "Gen. Journal Line"; AccType: Enum "Gen. Journal Account Type"; AccNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        case AccType of
            AccType::"G/L Account":
                begin
                    GLEntry.Reset();
                    if xGenJournalLine."Applies-to ID" <> '' then begin
                        GLEntry.SetCurrentKey("G/L Account No.", "Closed CZA");
                        GLEntry.SetRange("G/L Account No.", AccNo);
                        GLEntry.SetRange("Applies-to ID CZA", xGenJournalLine."Applies-to ID");
                        GLEntry.SetRange("Closed CZA", false);
                        if GLEntry.FindSet(true) then
                            repeat
                                GLEntry."Amount to Apply CZA" := 0;
                                GLEntry."Applies-to ID CZA" := '';
                                Codeunit.Run(Codeunit::"G/L Entry - Edit CZA", GLEntry);
                            until GLEntry.Next() = 0;
                    end else
                        if xGenJournalLine."Applies-to Doc. No." <> '' then begin
                            GLEntry.SetCurrentKey("Document No.");
                            GLEntry.SetRange("Document No.", xGenJournalLine."Applies-to Doc. No.");
                            GLEntry.SetRange("Document Type", xGenJournalLine."Applies-to Doc. Type");
                            GLEntry.SetRange("G/L Account No.", AccNo);
                            GLEntry.SetRange("Closed CZA", false);
                            if GLEntry.FindSet(true) then
                                repeat
                                    GLEntry."Amount to Apply CZA" := 0;
                                    GLEntry."Applies-to ID CZA" := '';
                                    Codeunit.Run(Codeunit::"G/L Entry - Edit CZA", GLEntry);
                                until GLEntry.Next() = 0;
                        end;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"General Journal", 'OnAfterEnableApplyEntriesAction', '', false, false)]
    local procedure ApplyEntriesActionEnabledOnAfterEnableApplyEntriesActionGeneralJournal(GenJournalLine: Record "Gen. Journal Line"; var ApplyEntriesActionEnabled: Boolean)
    begin
        ApplyEntriesActionEnabled := ApplyEntriesActionEnabled or
          (GenJournalLine."Account Type" = GenJournalLine."Account Type"::"G/L Account") or (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"G/L Account");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Payment Journal", 'OnAfterEnableApplyEntriesAction', '', false, false)]
    local procedure ApplyEntriesActionEnabledOnAfterEnableApplyEntriesActionPaymentJournal(GenJournalLine: Record "Gen. Journal Line"; var ApplyEntriesActionEnabled: Boolean)
    begin
        ApplyEntriesActionEnabled := ApplyEntriesActionEnabled or
          (GenJournalLine."Account Type" = GenJournalLine."Account Type"::"G/L Account") or (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"G/L Account");
    end;
}
