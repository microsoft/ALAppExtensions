// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

codeunit 31358 "Issue Bank Statement YesNo CZB"
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
        IssueQst: Label '&Issue,Issue and &Create Journal';

    procedure Code()
    var
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
        Selection: Integer;
    begin
        Selection := StrMenu(IssueQst, 1);
        if Selection = 0 then
            exit;

        Codeunit.Run(Codeunit::"Issue Bank Statement CZB", BankStatementHeaderCZB);
        Commit();

        if Selection = 2 then begin
            IssBankStatementHeaderCZB.Get(BankStatementHeaderCZB."Last Issuing No.");
            IssBankStatementHeaderCZB.SetRecFilter();
            IssBankStatementHeaderCZB.CreateJournal(false);
        end;
    end;
}
