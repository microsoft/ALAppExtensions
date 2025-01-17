// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.CashDesk;

codeunit 31091 "Cash Document Line Handler CZZ"
{
    [EventSubscriber(ObjectType::Table, Database::"Cash Document Line CZP", 'OnAfterIsEETTransaction', '', false, false)]
    local procedure CashDocumentLineOnBeforeIsEETTransaction(CashDocumentLineCZP: Record "Cash Document Line CZP"; var EETTransaction: Boolean)
    begin
        if CashDocumentLineCZP."Cash Desk Event" <> '' then
            exit;

        EETTransaction := EETTransaction or CashDocumentLineCZP.IsAdvancePaymentCZZ() or CashDocumentLineCZP.IsAdvanceRefundCZZ();
    end;
}
