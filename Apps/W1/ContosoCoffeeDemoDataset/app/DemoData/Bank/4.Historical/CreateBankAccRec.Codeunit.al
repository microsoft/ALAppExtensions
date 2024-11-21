codeunit 5258 "Create Bank Acc. Rec."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateBankAccountReconciliation();
        CreatePaymentReconciliationJournal();
    end;

    local procedure CreateBankAccountReconciliation()
    var
        GenJournalLine: Record "Gen. Journal Line";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        CreateGenJournalLine: Codeunit "Create Gen. Journal Line";
        ContosoBank: Codeunit "Contoso Bank";
        CreateBankAccount: Codeunit "Create Bank Account";
        ContosoUtilities: Codeunit "Contoso Utilities";
        DepositAmount: Decimal;
    begin
        BankAccReconciliation := ContosoBank.InsertBankAccountReconciliation(Enum::"Bank Acc. Rec. Stmt. Type"::"Bank Reconciliation", CreateBankAccount.Checking(), ContosoUtilities.AdjustDate(19030319D));

        GenJournalLine.SetRange("Document No.", CreateGenJournalLine.Bank1DocumentNo());
        if GenJournalLine.FindFirst() then begin
            ContosoBank.InsertBankAccRecLine(BankAccReconciliation, '', GenJournalLine."Posting Date", TransferToSavingLbl, -GenJournalLine.Amount, 0, 0, Enum::"Gen. Journal Account Type"::"G/L Account", '');
            BankAccReconciliation."Statement Ending Balance" += GenJournalLine.Amount;
        end;

        GenJournalLine.SetRange("Document No.", CreateGenJournalLine.Bank2DocumentNo());
        if GenJournalLine.FindFirst() then begin
            ContosoBank.InsertBankAccRecLine(BankAccReconciliation, '', CalcDate('<+3D>', GenJournalLine."Posting Date"), FundsForSpringEventLbl + Format(Date2DMY(GenJournalLine."Posting Date", 3) - 1), -GenJournalLine.Amount, 0, 0, Enum::"Gen. Journal Account Type"::"G/L Account", '');
            BankAccReconciliation."Statement Ending Balance" += GenJournalLine.Amount;
        end;

        GenJournalLine.SetFilter("Document No.", CreateGenJournalLine.Deposit3DocumentNo() + '|' + CreateGenJournalLine.Deposit4DocumentNo());
        if GenJournalLine.FindSet() then begin
            repeat
                DepositAmount += GenJournalLine.Amount;
                BankAccReconciliation."Statement Ending Balance" += GenJournalLine.Amount;
            until GenJournalLine.Next() = 0;

            ContosoBank.InsertBankAccRecLine(BankAccReconciliation, '', GenJournalLine."Posting Date", DepositToAccountLbl + Format(GenJournalLine."Posting Date"), -DepositAmount, 0, 0, Enum::"Gen. Journal Account Type"::"G/L Account", '');
        end;

        BankAccReconciliation."Statement Ending Balance" := -BankAccReconciliation."Statement Ending Balance";
        BankAccReconciliation."Statement Date" := CalcDate('<CM>', GenJournalLine."Posting Date");
        BankAccReconciliation.Modify(true);
    end;

    local procedure CreatePaymentReconciliationJournal()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        CreatePurchaseDocument: Codeunit "Create Purchase Document";
        ContosoBank: Codeunit "Contoso Bank";
        CreateBankAccount: Codeunit "Create Bank Account";
        CreateCustomer: Codeunit "Create Customer";
        CreateVendor: Codeunit "Create Vendor";
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        BankAccReconciliation := ContosoBank.InsertBankAccountReconciliation(Enum::"Bank Acc. Rec. Stmt. Type"::"Payment Application", CreateBankAccount.Checking(), ContosoUtilities.AdjustDate(19030319D));

        PurchaseHeader.SetRange("Your Reference", CreatePurchaseDocument.ReconciliationYourReference());
        if PurchaseHeader.FindSet() then
            repeat
                PurchaseHeader.CalcFields("Amount Including VAT");
                if PurchaseHeader."Buy-from Vendor No." = CreateVendor.DomesticWorldImporter() then // line with low match confidence
                    ContosoBank.InsertBankAccRecLine(BankAccReconciliation, '', PurchaseHeader."Posting Date", PurchaseHeader."Pay-to Name", -PurchaseHeader."Amount Including VAT" div 2, 0, 0, Enum::"Gen. Journal Account Type"::Vendor, PurchaseHeader."Pay-to Vendor No.")
                else
                    ContosoBank.InsertBankAccRecLine(BankAccReconciliation, '', PurchaseHeader."Posting Date", PurchaseHeader."No.", -PurchaseHeader."Amount Including VAT", 0, 0, Enum::"Gen. Journal Account Type"::Vendor, PurchaseHeader."Pay-to Vendor No.");
            until PurchaseHeader.Next() = 0;

        SalesHeader.SetRange("Your Reference", CreatePurchaseDocument.ReconciliationYourReference());
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.CalcFields("Amount Including VAT");
                if SalesHeader."Sell-to Customer No." = CreateCustomer.ExportSchoolofArt() then // line with low match confidence
                    ContosoBank.InsertBankAccRecLine(BankAccReconciliation, '', SalesHeader."Posting Date" + 1, SalesHeader."Sell-to Customer Name", SalesHeader."Amount Including VAT" - 0.01, 0, 0, Enum::"Gen. Journal Account Type"::Customer, SalesHeader."Sell-to Customer No.")
                else
                    ContosoBank.InsertBankAccRecLine(BankAccReconciliation, '', SalesHeader."Posting Date", SalesHeader."No.", SalesHeader."Amount Including VAT", 0, 0, Enum::"Gen. Journal Account Type"::Customer, SalesHeader."Sell-to Customer No.");
            until SalesHeader.Next() = 0;
    end;

    var
        TransferToSavingLbl: Label 'Transfer to savings account', MaxLength = 100;
        FundsForSpringEventLbl: Label 'Funds for Spring event ', MaxLength = 100;
        DepositToAccountLbl: Label 'Deposit to Account ', MaxLength = 100;
}