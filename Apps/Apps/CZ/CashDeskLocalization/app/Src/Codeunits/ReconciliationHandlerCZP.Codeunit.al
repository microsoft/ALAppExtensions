// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.GeneralLedger.Journal;

codeunit 11705 "Reconciliation Handler CZP"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"G/L Account Net Change", 'OnPopulateFromAccountOnElse', '', false, false)]
    local procedure HandleCashDeskTypeOnPopulateFromAccountOnElse(var GLAccountNetChange: Record "G/L Account Net Change")
    var
        CashDesk: Record "Cash Desk CZP";
    begin
        if GLAccountNetChange."Acc. Type CZL" <> GLAccountNetChange."Acc. Type CZL"::"Cash Desk CZP" then
            exit;

        CashDesk.Get(GLAccountNetChange."Account No. CZL");
        CashDesk.CalcFields(Balance, "Balance (LCY)");
        GLAccountNetChange.Name := CashDesk.Name;
        GLAccountNetChange."Balance after Posting" := CashDesk."Balance (LCY)";
        if CashDesk."Currency Code" <> '' then begin
            GLAccountNetChange."Currency Code CZL" := CashDesk."Currency Code";
            GLAccountNetChange."Balance after Posting Curr.CZL" := CashDesk.Balance;
        end;
    end;
}