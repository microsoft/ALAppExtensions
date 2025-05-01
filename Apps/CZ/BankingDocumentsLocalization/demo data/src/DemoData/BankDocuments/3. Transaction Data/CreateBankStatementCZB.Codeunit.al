// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.BankDocuments;

using Microsoft.Bank.Documents;
using Microsoft.DemoData.Bank;
using Microsoft.DemoData.Localization;

codeunit 31480 "Create Bank Statement CZB"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateBankStatements();
    end;

    local procedure CreateBankStatements()
    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
        CreateBankAccountCZ: Codeunit "Create Bank Account CZ";
        ContosoBankDocumentsCZB: Codeunit "Contoso Bank Documents CZB";
    begin
        BankStatementHeaderCZB := ContosoBankDocumentsCZB.InsertBankStatementHeader(CreateBankAccountCZ.NBL(), WorkDate(), '1');
        ContosoBankDocumentsCZB.InsertBankStatementLine(BankStatementHeaderCZB, 'Látky a.s.', '100011/0100', '11190046', -53288.40);
        ContosoBankDocumentsCZB.InsertBankStatementLine(BankStatementHeaderCZB, 'Elektro s.r.o.', '158468239/0300', '3458911', -3025.0);
        ContosoBankDocumentsCZB.InsertBankStatementLine(BankStatementHeaderCZB, 'Výběr z ATM', '', '', -20000.0);
        ContosoBankDocumentsCZB.InsertBankStatementLine(BankStatementHeaderCZB, 'ABC nábytek s.r.o.', '', '1001', 61886.0);
        ContosoBankDocumentsCZB.InsertBankStatementLine(BankStatementHeaderCZB, 'Elektro s.r.o. - záloha', '158468239/0300', '1214448', -11011.0);

        BankStatementHeaderCZB := ContosoBankDocumentsCZB.InsertBankStatementHeader(CreateBankAccountCZ.NBL(), WorkDate(), OpenExternalDocumentNo());
        ContosoBankDocumentsCZB.InsertBankStatementLine(BankStatementHeaderCZB, 'Vklad hotovosti na účet', '', '', 50000.0);
        ContosoBankDocumentsCZB.InsertBankStatementLine(BankStatementHeaderCZB, 'ABC nábytek s.r.o.', '1000100001/0100', '1003', 14925.0);
    end;

    procedure IssueBankStatements()
    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
    begin
        BankStatementHeaderCZB.SetFilter("External Document No.", '<>%1', OpenExternalDocumentNo());
        if BankStatementHeaderCZB.FindSet() then
            repeat
                Codeunit.Run(Codeunit::"Issue Bank Statement CZB", BankStatementHeaderCZB);
            until BankStatementHeaderCZB.Next() = 0;
    end;

    procedure OpenExternalDocumentNo(): Code[35]
    begin
        exit(OpenExternalDocumentNoTok);
    end;

    var
        OpenExternalDocumentNoTok: Label 'OPEN', MaxLength = 35;
}