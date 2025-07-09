// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.Bank.BankAccount;
using Microsoft.DemoData.Finance;

codeunit 10805 "Create ES Bank Acc. PostingGrp"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnInsertRecord(var Rec: Record "Bank Account Posting Group")
    var
        CreateESGLAccounts: Codeunit "Create ES GL Accounts";
        CreateBankAccPostingGrp: Codeunit "Create Bank Acc. Posting Grp";
    begin
        case Rec.Code of
            CreateBankAccPostingGrp.Cash(),
            CreateBankAccPostingGrp.Operating():
                ValidateRecordFields(Rec, CreateESGLAccounts.SavingAccount(), CreateESGLAccounts.DebtOnDiscountedBills(), CreateESGLAccounts.BankingServices(), CreateESGLAccounts.InterestOnBillsDiscounted(), CreateESGLAccounts.OtherFinExpBillReject(), CreateESGLAccounts.DiscInvoiceDebtAcc());
            CreateBankAccPostingGrp.Checking(),
            CreateBankAccPostingGrp.Savings():
                ValidateRecordFields(Rec, CreateESGLAccounts.BanksEuro(), CreateESGLAccounts.DebtOnDiscountedBills(), CreateESGLAccounts.BankingServices(), CreateESGLAccounts.InterestOnBillsDiscounted(), CreateESGLAccounts.OtherFinExpBillReject(), CreateESGLAccounts.DiscInvoiceDebtAcc());
        end;
    end;

    local procedure ValidateRecordFields(var BankAccountPostingGroup: Record "Bank Account Posting Group"; GLAccountNo: Code[20]; LiabsforDiscBillsAcc: Code[20]; BankServicesAcc: Code[20]; DiscountInterestAcc: Code[20]; RejectionExpensesAcc: Code[20]; LiabsforFactoringAcc: Code[20])
    begin
        BankAccountPostingGroup.Validate("G/L Account No.", GLAccountNo);
        BankAccountPostingGroup.Validate("Liabs. for Disc. Bills Acc.", LiabsforDiscBillsAcc);
        BankAccountPostingGroup.Validate("Bank Services Acc.", BankServicesAcc);
        BankAccountPostingGroup.Validate("Discount Interest Acc.", DiscountInterestAcc);
        BankAccountPostingGroup.Validate("Rejection Expenses Acc.", RejectionExpensesAcc);
        BankAccountPostingGroup.Validate("Liabs. for Factoring Acc.", LiabsforFactoringAcc);
    end;
}
