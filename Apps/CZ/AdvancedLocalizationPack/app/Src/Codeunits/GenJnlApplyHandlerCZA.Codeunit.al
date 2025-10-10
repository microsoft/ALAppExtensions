// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ReceivablesPayables;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;

codeunit 31379 "Gen. Jnl.-Apply Handler CZA"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Apply", 'OnBeforeRun', '', false, false)]
    local procedure ApplyGLEntryOnBeforeGenJnlApply(var GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    var
        GLEntryPostApplication: Codeunit "G/L Entry Post Application CZA";
    begin
        if IsHandled then
            exit;
        if not GLEntryPostApplication.IsApplyGLEntryEnabled(GenJnlLine) then
            exit;
        GLEntryPostApplication.ApplyGLEntry(GenJnlLine);
        IsHandled := true;
    end;
}
