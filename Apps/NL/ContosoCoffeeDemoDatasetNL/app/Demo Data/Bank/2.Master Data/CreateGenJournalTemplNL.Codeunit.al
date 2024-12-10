codeunit 11542 "Create Gen. Journal Templ. NL"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SourceCodeSetup: Record "Source Code Setup";
        ContosoGeneralLedgerNL: Codeunit "Contoso General Ledger NL";
        CreateNoSeriesNL: Codeunit "Create No. Series NL";
        CreateSourceCodeNL: Codeunit "Create Source Code NL";
        CreateBankAccountNL: Codeunit "Create Bank Account NL";
        CreateNLGLAccounts: Codeunit "Create NL GL Accounts";
    begin
        SourceCodeSetup.Get();

        ContosoGeneralLedgerNL.InsertGeneralJournalTemplate(ABN(), ABNBankJournalLbl, Enum::"Gen. Journal Template Type"::Bank, Enum::"Gen. Journal Account Type"::"Bank Account", CreateBankAccountNL.ABN(), Page::"Bank/Giro Journal", CreateNoSeriesNL.AbnBankJnl(), CreateSourceCodeNL.ABNBankJnl());
        ContosoGeneralLedgerNL.InsertGeneralJournalTemplate(Cash(), CashJournalLbl, Enum::"Gen. Journal Template Type"::Cash, Enum::"Gen. Journal Account Type"::"G/L Account", CreateNLGLAccounts.PettyCash(), Page::"Cash Journal", CreateNoSeriesNL.Cash(), SourceCodeSetup."Cash Journal");
        ContosoGeneralLedgerNL.InsertGeneralJournalTemplate(PostBank(), GiroJournalLbl, Enum::"Gen. Journal Template Type"::Bank, Enum::"Gen. Journal Account Type"::"Bank Account", CreateBankAccountNL.PostBank(), Page::"Bank/Giro Journal", CreateNoSeriesNL.GiroJnl(), CreateSourceCodeNL.GiroJnl());
    end;

    procedure ABN(): Code[10]
    begin
        exit(ABNTok);
    end;

    procedure Cash(): Code[10]
    begin
        exit(CashTok);
    end;

    procedure PostBank(): Code[10]
    begin
        exit(PostbankTok);
    end;

    var
        ABNTok: Label 'ABN', MaxLength = 10, Locked = true;
        ABNBankJournalLbl: Label 'ABN Bank Journal', MaxLength = 80;
        CashTok: Label 'CASH', MaxLength = 10, Locked = true;
        CashJournalLbl: Label 'Cash Journal', MaxLength = 80;
        PostbankTok: Label 'POSTBANK', MaxLength = 10, Locked = true;
        GiroJournalLbl: Label 'Giro Journal', MaxLength = 80;
}