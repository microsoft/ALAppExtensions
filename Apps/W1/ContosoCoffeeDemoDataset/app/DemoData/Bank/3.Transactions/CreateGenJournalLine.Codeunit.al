codeunit 5421 "Create Gen. Journal Line"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateBankJnlBatch: Codeunit "Create Bank Jnl. Batches";
        ContosoGeneralLedger: Codeunit "Contoso General Ledger";
        CreateBankAccount: Codeunit "Create Bank Account";
        ContosoUtilities: Codeunit "Contoso Utilities";
        PostingDate: Date;
    begin
        PostingDate := ContosoUtilities.AdjustDate(19030119D);

        ContosoGeneralLedger.InsertGenJournalLine(CreateGenJournalTemplate.General(), CreateBankJnlBatch.Daily(), 10000, Enum::"Gen. Journal Account Type"::"Bank Account", CreateBankAccount.Savings(), PostingDate, Enum::"Gen. Journal Document Type"::Payment, Bank1DocumentNo(), TransferJanuaryLbl + Format(Date2DMY(PostingDate, 3)), CreateBankAccount.Checking(), -1780.49, false, Enum::"Gen. Journal Account Type"::"Bank Account", Enum::"Gen. Journal Document Type"::" ", '');
        ContosoGeneralLedger.InsertGenJournalLine(CreateGenJournalTemplate.General(), CreateBankJnlBatch.Daily(), 20000, Enum::"Gen. Journal Account Type"::"Bank Account", CreateBankAccount.Savings(), PostingDate, Enum::"Gen. Journal Document Type"::Payment, Bank2DocumentNo(), TransferFundsForSpringLbl + Format(Date2DMY(PostingDate, 3)), CreateBankAccount.Checking(), -2670.73, false, Enum::"Gen. Journal Account Type"::"Bank Account", Enum::"Gen. Journal Document Type"::" ", '');
        ContosoGeneralLedger.InsertGenJournalLine(CreateGenJournalTemplate.General(), CreateBankJnlBatch.Daily(), 30000, Enum::"Gen. Journal Account Type"::"Bank Account", CreateBankAccount.Savings(), PostingDate, Enum::"Gen. Journal Document Type"::Payment, Deposit3DocumentNo(), Deposit3Lbl + Format(Date2DMY(PostingDate, 3)), CreateBankAccount.Checking(), -3560.98, false, Enum::"Gen. Journal Account Type"::"Bank Account", Enum::"Gen. Journal Document Type"::" ", '');
        ContosoGeneralLedger.InsertGenJournalLine(CreateGenJournalTemplate.General(), CreateBankJnlBatch.Daily(), 40000, Enum::"Gen. Journal Account Type"::"Bank Account", CreateBankAccount.Savings(), PostingDate, Enum::"Gen. Journal Document Type"::Payment, Deposit4DocumentNo(), Deposit4Lbl + Format(Date2DMY(PostingDate, 3)), CreateBankAccount.Checking(), -3560.98, false, Enum::"Gen. Journal Account Type"::"Bank Account", Enum::"Gen. Journal Document Type"::" ", '');
    end;

    procedure Bank1DocumentNo(): Code[20]
    begin
        exit(Bank1DocumentNoLbl);
    end;

    procedure Bank2DocumentNo(): Code[20]
    begin
        exit(Bank2DocumentNoLbl);
    end;

    procedure Deposit3DocumentNo(): Code[20]
    begin
        exit(Deposit3DocumentNoLbl);
    end;

    procedure Deposit4DocumentNo(): Code[20]
    begin
        exit(Deposit4DocumentNoLbl);
    end;

    var
        Bank1DocumentNoLbl: Label 'BANK1', MaxLength = 20;
        Bank2DocumentNoLbl: Label 'BANK2', MaxLength = 20;
        Deposit3DocumentNoLbl: Label 'DEPOSIT3', MaxLength = 20;
        Deposit4DocumentNoLbl: Label 'DEPOSIT4', MaxLength = 20;
        TransferJanuaryLbl: Label 'Transfer, January ', MaxLength = 100;
        TransferFundsForSpringLbl: Label 'Transfer of funds for Spring ', MaxLength = 100;
        Deposit3Lbl: Label 'Deposit 3, ', MaxLength = 100;
        Deposit4Lbl: Label 'Deposit 4, ', MaxLength = 100;
}