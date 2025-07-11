// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Reversal;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;

codeunit 31382 "Reversal Entry Handler CZA"
{
    [EventSubscriber(ObjectType::Table, Database::"Reversal Entry", 'OnCheckGLAccOnBeforeTestFields', '', false, false)]
    local procedure GLEntryPostApplicationOnCheckGLAccOnBeforeTestFields(GLAcc: Record "G/L Account"; GLEntry: Record "G/L Entry"; var IsHandled: Boolean)
    var
        ReverseErr: Label 'You cannot reverse %1 No %2 because the entry was either applied to another entry or has been changed by a batch job.', Comment = '%1 = TableCaption G/L Entry, %2 = Entry No.';
    begin
        GLEntry.CalcFields("Applied Amount CZA");
        if GLEntry."Applied Amount CZA" <> 0 then
            Error(ReverseErr, GLEntry.TableCaption, GLEntry."Entry No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Reversal Entry", 'OnBeforeCheckFA', '', false, false)]
    local procedure OnAfterMoveToGenJnlLine()
    var
        CheckFaErr: Label 'Function Reverse Register and Reverse Transaction cannot be used! Use function Cancel Entries instead.';
    begin
        Error(CheckFaErr)
    end;
}
