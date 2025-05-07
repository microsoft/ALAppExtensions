// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.DemoTool;
using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.CRM;
using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 31194 "Create Bank Account CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        ContosoBank: Codeunit "Contoso Bank";
        CreateBankExImportSetup: Codeunit "Create Bank Ex/Import Setup";
        CreateBankAccPostGrpCZ: Codeunit "Create Bank Acc. Post. Grp CZ";
        CreateBankJnlBatches: Codeunit "Create Bank Jnl. Batches";
        CreateGenJnlBatchCZ: Codeunit "Create Gen. Jnl. Batch CZ";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateGenJnlTemplateCZ: Codeunit "Create Gen. Jnl. Template CZ";
        CreateNoSeries: Codeunit "Create No. Series";
        SalespersonPurchaser: Codeunit "Create Salesperson/Purchaser";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        DeleteBankAccounts();

        ContosoBank.InsertBankAccount(WWBEUR(), BankAccountDescriptionLbl, BankaccountAddressLbl, BankAccountCityLbl, BankAccountContactLbl, CheckingBankAccountNoLbl, -934400, CreateBankAccPostGrpCZ.WWBEUR(), SalespersonPurchaser.OtisFalls(), ContosoCoffeeDemoDataSetup."Country/Region Code", '23', CreateNoSeries.PaymentReconciliationJournals(), PostCodeLbl, '199', BankBranchNoLbl, CreateBankExImportSetup.SEPACAMT());
        ContosoBank.InsertBankAccount(NBL(), BankAccountDescriptionLbl, BankaccountAddressLbl, BankAccountCityLbl, BankAccountContactLbl, SavingBankAccountNoLbl, 0, CreateBankAccPostGrpCZ.NBL(), SalespersonPurchaser.OtisFalls(), ContosoCoffeeDemoDataSetup."Country/Region Code", '', '', PostCodeLbl, '', BankBranchNoLbl, '');

        UpdateBankJnlBatches(CreateGenJournalTemplate.General(), CreateBankJnlBatches.Daily(), NBL(), '');
        UpdateBankJnlBatches(CreateGenJournalTemplate.PaymentJournal(), CreateBankJnlBatches.PaymentReconciliation(), NBL(), CreateNoSeries.PaymentJournal());
        UpdateBankJnlBatches(CreateGenJnlTemplateCZ.Banks(), CreateGenJnlBatchCZ.NBL(), NBL(), '');
        UpdateBankJnlBatches(CreateGenJnlTemplateCZ.Banks(), CreateGenJnlBatchCZ.WWBEUR(), WWBEUR(), '');
    end;

    internal procedure CreateDummyBankAccount()
    var
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        InsertDummyBankAccount(CreateBankAccount.Checking());
        InsertDummyBankAccount(CreateBankAccount.Savings());
    end;

    local procedure InsertDummyBankAccount(No: Code[20])
    var
        ContosoBank: Codeunit "Contoso Bank";
    begin
        ContosoBank.InsertBankAccount(No, '', '', '', '', '', 0, '', '', '', '', '', '', '', '', '');
    end;

    internal procedure DeleteBankAccounts()
    var
        BankAccount: Record "Bank Account";
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        BankAccount.SetFilter("No.", '%1|%2', CreateBankAccount.Checking(), CreateBankAccount.Savings());
        BankAccount.DeleteAll();
    end;

    local procedure UpdateBankJnlBatches(JournalTemplateName: Code[10]; JournalBatchName: Code[10]; BankAccounNo: Code[20]; NoSeries: Code[20])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.Get(JournalTemplateName, JournalBatchName);

        GenJournalBatch.Validate("Bal. Account No.", BankAccounNo);
        GenJournalBatch.Validate("No. Series", NoSeries);
        GenJournalBatch.Modify(true);
    end;

    procedure WWBEUR(): Code[20]
    begin
        exit(WWBEURTok);
    end;

    procedure NBL(): Code[20]
    begin
        exit(NBLTok);
    end;

    var
        WWBEURTok: Label 'WWB-EUR', MaxLength = 20, Comment = 'World Wide Bank - EUR';
        NBLTok: Label 'NBL', MaxLength = 20, Comment = 'National Bank of London';
        BankAccountDescriptionLbl: Label 'World Wide Bank', MaxLength = 100;
        BankaccountAddressLbl: Label '1 High Holborn', MaxLength = 100;
        BankAccountCityLbl: Label 'London', MaxLength = 30;
        BankAccountContactLbl: Label 'Grant Culbertson', MaxLength = 100;
        CheckingBankAccountNoLbl: Label '99-99-888', Locked = true;
        SavingBankAccountNoLbl: Label '99-44-567', Locked = true;
        PostCodeLbl: Label 'WC1 3DG', Locked = true;
        BankBranchNoLbl: Label 'BG99999', Locked = true;
}
