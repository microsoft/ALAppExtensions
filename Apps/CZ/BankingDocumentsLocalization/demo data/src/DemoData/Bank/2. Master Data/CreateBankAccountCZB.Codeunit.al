// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.DemoData.BankDocuments;
using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Documents;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Foundation;

codeunit 31449 "Create Bank Account CZB"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateBankAccounts();
    end;

    local procedure UpdateBankAccounts()
    var
        BankAccount: Record "Bank Account";
        CreateBankAccountCZ: Codeunit "Create Bank Account CZ";
        CreateGenJnlBatchCZ: Codeunit "Create Gen. Jnl. Batch CZ";
        CreateGenJournalTemplateCZ: Codeunit "Create Gen. Jnl. Template CZ";
        CreateGLAccountCZ: Codeunit "Create G/L Account CZ";
        CreateNoSeriesCZ: Codeunit "Create No. Series CZ";
        CreateSearchRuleCZB: Codeunit "Create Search Rule CZB";
    begin
        if BankAccount.Get(CreateBankAccountCZ.NBL()) then begin
            ValidateBankAccount(BankAccount, CreateGenJournalTemplateCZ.Banks(), CreateGenJnlBatchCZ.NBL(), CreateGenJournalTemplateCZ.Banks(), CreateGenJnlBatchCZ.NBL(), Report::"Iss. Payment Order CZB", Report::"Iss. Payment Order CZB", true, true, true, true, CreateSearchRuleCZB.Default(), CreateGLAccountCZ.Cashtransfer(), true, CreateNoSeriesCZ.PaymentOrder(), CreateNoSeriesCZ.IssuedPaymentOrder(), CreateNoSeriesCZ.BankStatement(), CreateNoSeriesCZ.IssuedBankStatement());
            BankAccount.Modify(true);
        end;
        if BankAccount.Get(CreateBankAccountCZ.WWBEUR()) then begin
            ValidateBankAccount(BankAccount, CreateGenJournalTemplateCZ.Banks(), CreateGenJnlBatchCZ.WWBEUR(), CreateGenJournalTemplateCZ.Banks(), CreateGenJnlBatchCZ.WWBEUR(), Report::"Iss. Payment Order CZB", Report::"Iss. Payment Order CZB", true, true, true, true, CreateSearchRuleCZB.Default(), CreateGLAccountCZ.Cashtransfer(), true, CreateNoSeriesCZ.PaymentOrder(), CreateNoSeriesCZ.IssuedPaymentOrder(), CreateNoSeriesCZ.BankStatement(), CreateNoSeriesCZ.IssuedBankStatement());
            BankAccount.Modify(true);
        end;
    end;

    local procedure ValidateBankAccount(var BankAccount: Record "Bank Account"; PaymentJnlTemplateName: Code[10]; PaymentJnlBatchName: Code[10]; PmtJnlTemplNameOrder: Code[10]; PmtJnlBatchNameOrder: Code[10]; DomesticPaymentOrderID: Integer; ForeignPaymentOrderID: Integer; VariableStoDescription: Boolean; VariableStoVariableS: Boolean; VariableStoExtDocNo: Boolean; DimensionfromApplyEntry: Boolean; SearchRuleCode: Code[10]; NonAssocPaymentAccount: Code[20]; CheckExtNoCurrYear: Boolean; PaymentOrderNos: Code[20]; IssuedPaymentOrderNos: Code[20]; BankStatementNos: Code[20]; IssuedBankStatementNos: Code[20])
    begin
        BankAccount.Validate("Payment Jnl. Template Name CZB", PaymentJnlTemplateName);
        BankAccount.Validate("Payment Jnl. Batch Name CZB", PaymentJnlBatchName);
        BankAccount.Validate("Pmt.Jnl. Templ. Name Order CZB", PmtJnlTemplNameOrder);
        BankAccount.Validate("Pmt. Jnl. Batch Name Order CZB", PmtJnlBatchNameOrder);
        BankAccount.Validate("Domestic Payment Order ID CZB", DomesticPaymentOrderID);
        BankAccount.Validate("Foreign Payment Order ID CZB", ForeignPaymentOrderID);
        BankAccount.Validate("Variable S. to Description CZB", VariableStoDescription);
        BankAccount.Validate("Variable S. to Variable S. CZB", VariableStoVariableS);
        BankAccount.Validate("Variable S. to Ext.Doc.No. CZB", VariableStoExtDocNo);
        BankAccount.Validate("Dimension from Apply Entry CZB", DimensionfromApplyEntry);
        BankAccount.Validate("Search Rule Code CZB", SearchRuleCode);
        BankAccount.Validate("Non Assoc. Payment Account CZB", NonAssocPaymentAccount);
        BankAccount.Validate("Check Ext. No. Curr. Year CZB", CheckExtNoCurrYear);
        BankAccount.Validate("Payment Order Nos. CZB", PaymentOrderNos);
        BankAccount.Validate("Issued Payment Order Nos. CZB", IssuedPaymentOrderNos);
        BankAccount.Validate("Bank Statement Nos. CZB", BankStatementNos);
        BankAccount.Validate("Issued Bank Statement Nos. CZB", IssuedBankStatementNos);
    end;
}
