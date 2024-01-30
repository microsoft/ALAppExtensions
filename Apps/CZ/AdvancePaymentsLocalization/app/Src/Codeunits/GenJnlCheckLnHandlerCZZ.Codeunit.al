// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;

codeunit 31109 "Gen.Jnl.-Check Ln. Handler CZZ"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeCheckSalesDocNoIsNotUsed', '', false, false)]
    local procedure GenJnlCheckLineOnBeforeCheckSalesDocNoIsNotUsed(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeCheckPurchDocNoIsNotUsed', '', false, false)]
    local procedure GenJnlCheckLineOnBeforeCheckPurchDocNoIsNotUsed(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCheckPurchExtDocNo', '', false, false)]
    local procedure GenJnlPostLineOnBeforeCheckPurchExtDocNo(var Handled: Boolean)
    begin
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCreateGLEntryGainLossInsertGLEntry', '', false, false)]
    local procedure SuppressCorrectionOnBeforeCreateGLEntryGainLossInsertGLEntry(var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine.Correction := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnNextTransactionNoNeeded', '', false, false)]
    local procedure SuppressNextTransactionOnNextTransactionNoNeeded(var NewTransaction: Boolean)
    begin
        NewTransaction := false;
    end;
}
