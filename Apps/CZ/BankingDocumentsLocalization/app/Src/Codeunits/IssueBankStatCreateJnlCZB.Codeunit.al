// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Documents;

using Microsoft.Utilities;

codeunit 31230 "IssueBank.Stat.Create Jnl. CZB"
{
    TableNo = "Bank Statement Header CZB";

    trigger OnRun()
    begin
        BankStatementHeaderCZB.Copy(Rec);
        Code();
        Rec := BankStatementHeaderCZB;
    end;

    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";

    procedure Code()
    var
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
        InstructionMgt: Codeunit "Instruction Mgt.";
        InstructionMgtCZB: Codeunit "Instruction Mgt. CZB";
        SuppressCommit: Boolean;
    begin
        Codeunit.Run(Codeunit::"Issue Bank Statement CZB", BankStatementHeaderCZB);
        OnCodeOnBeforeCommit(BankStatementHeaderCZB, SuppressCommit);
        if not SuppressCommit then
            Commit();

        IssBankStatementHeaderCZB.Get(BankStatementHeaderCZB."Last Issuing No.");
        IssBankStatementHeaderCZB.SetRecFilter();
        IssBankStatementHeaderCZB.CreateJournal(false, InstructionMgt.IsEnabled(InstructionMgtCZB.ShowCreatedJnlIssBankStmtConfirmationMessageCode()));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCodeOnBeforeCommit(BankStatementHeaderCZB: Record "Bank Statement Header CZB"; var SuppressCommit: Boolean)
    begin
    end;
}
