// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSOnReceipt;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TCS.TCSBase;

codeunit 18900 "Pay-TCS"
{
    procedure PayTCS(var GenJournalLine: Record "Gen. Journal Line")
    var
        TCSEntry: Record "TCS Entry";
        PagePayTCS: Page "Pay TCS";
        TCSEntriesErr: Label 'There are no TCS entries for Account No. %1.', Comment = '%1=Account No.';
    begin
        GenJournalLine.TestField("Document No.");
        GenJournalLine.TestField("Account No.");
        GenJournalLine.TestField("T.C.A.N. No.");
        GenJournalLine."Pay TCS" := true;
        GenJournalLine.Modify();

        Clear(PagePayTCS);
        TCSEntry.SetRange("Account No.", GenJournalLine."Account No.");
        TCSEntry.SetRange("T.C.A.N. No.", GenJournalLine."T.C.A.N. No.");
        TCSEntry.SetFilter("Total TCS Including SHE CESS", '<>%1', 0);
        TCSEntry.SetRange("TCS Paid", false);
        TCSEntry.SetRange(Reversed, false);
        if TCSEntry.IsEmpty() then
            Error(TCSEntriesErr, GenJournalLine."Account No.");

        PagePayTCS.SetProperties(GenJournalLine."Journal Batch Name", GenJournalLine."Journal Template Name", GenJournalLine."Line No.");
        PagePayTCS.SetTableView(TCSEntry);
        PagePayTCS.Run();
    end;
}
