codeunit 11382 "Contoso DE Gen ledger Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "General Ledger Setup" = rim;

    var
        OverwriteData: Boolean;
        Exists: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertGeneralLedgerSetupData(JobQueueCategoryCode: Code[10]; InvRoundingPrecisionLCY: Decimal; LocalContAddrFormat: Integer; BankAccountNos: Code[20]; AmountDecimalPlaces: Text[5]; UnitAmountDecimalPlaces: Text[5]; EMUCurrency: Boolean; LCYCode: Code[10]; AmountRoundingPrecision: Decimal; UnitAmountRoundingPrecision: Decimal;
     GlobalDimension1Code: Code[20]; GlobalDimension2Code: Code[20]; FinRepforBalanceSheet: Code[10]; FinRepforIncomeStmt: Code[10]; FinRepforCashFlowStmt: Code[10]; FinRepforRetainedEarn: Code[10];
     LocalCurrencySymbol: Text[10]; LocalCurrencyDescription: Text[60]; EnableDataCheck: Boolean; AccReceivablesCategory: Integer; CurrencyCodeEUR: Code[10])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if GeneralLedgerSetup.Get() then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        GeneralLedgerSetup.Validate("Job Queue Category Code", JobQueueCategoryCode);
        GeneralLedgerSetup.Validate("Inv. Rounding Precision (LCY)", InvRoundingPrecisionLCY);
        GeneralLedgerSetup.Validate("Local Cont. Addr. Format", LocalContAddrFormat);
        GeneralLedgerSetup.Validate("Bank Account Nos.", BankAccountNos);
        GeneralLedgerSetup.Validate("Amount Decimal Places", AmountDecimalPlaces);
        GeneralLedgerSetup.Validate("Unit-Amount Decimal Places", UnitAmountDecimalPlaces);
        GeneralLedgerSetup.Validate("EMU Currency", EMUCurrency);
        GeneralLedgerSetup.Validate("LCY Code", LCYCode);
        GeneralLedgerSetup.Validate("Amount Rounding Precision", AmountRoundingPrecision);
        GeneralLedgerSetup.Validate("Unit-Amount Rounding Precision", UnitAmountRoundingPrecision);
        GeneralLedgerSetup.Validate("Fin. Rep. for Balance Sheet", FinRepforBalanceSheet);
        GeneralLedgerSetup.Validate("Fin. Rep. for Income Stmt.", FinRepforIncomeStmt);
        GeneralLedgerSetup.Validate("Fin. Rep. for Cash Flow Stmt", FinRepforCashFlowStmt);
        GeneralLedgerSetup.Validate("Fin. Rep. for Retained Earn.", FinRepforRetainedEarn);
        GeneralLedgerSetup.Validate("Local Currency Symbol", LocalCurrencySymbol);
        GeneralLedgerSetup.Validate("Local Currency Description", LocalCurrencyDescription);
        GeneralLedgerSetup.Validate("Enable Data Check", EnableDataCheck);
        GeneralLedgerSetup.Validate("Acc. Receivables Category", AccReceivablesCategory);
        GeneralLedgerSetup.Validate("Currency Code For EURO", CurrencyCodeEUR);

        if Exists then
            GeneralLedgerSetup.Modify(true)
        else
            GeneralLedgerSetup.Insert(true);

        GeneralLedgerSetup.Validate("Global Dimension 1 Code", GlobalDimension1Code);
        GeneralLedgerSetup.Validate("Global Dimension 2 Code", GlobalDimension2Code);
        GeneralLedgerSetup.Validate("Shortcut Dimension 1 Code", GlobalDimension1Code);
        GeneralLedgerSetup.Validate("Shortcut Dimension 2 Code", GlobalDimension2Code);
        GeneralLedgerSetup.Modify(true);
    end;
}