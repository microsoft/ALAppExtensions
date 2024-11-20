codeunit 5230 "Create General Ledger Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateJobQueueCategory: Codeunit "Create Job Queue Category";
        CreateNoSeries: Codeunit "Create No. Series";
        CreateCurrency: Codeunit "Create Currency";
        CreateDimension: Codeunit "Create Dimension";
    begin
        InsertData(CreateJobQueueCategory.GeneralLedgerPosting(), 0.01, 1, CreateNoSeries.Bank(), CreateCurrency.GBP(), CreateDimension.DepartmentDimension(), CreateDimension.CustomerGroupDimension(), true, 4);
    end;

    procedure InsertData(JobQueueCategoryCode: Code[10]; InvoiceRoundingPrecisionLCY: Decimal; LocalContAddrFormat: Integer; BankAccountNo: Code[20]; LCYCode: Code[10]; GlobalDimension1Code: Code[20]; GlobalDimension2Code: Code[20]; DataCheck: Boolean; AccReceivablesCategory: Integer)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        if not GeneralLedgerSetup.Get() then
            GeneralLedgerSetup.Insert();

        GeneralLedgerSetup.Validate("Job Queue Category Code", JobQueueCategoryCode);
        GeneralLedgerSetup.Validate("Inv. Rounding Precision (LCY)", InvoiceRoundingPrecisionLCY);
        GeneralLedgerSetup.Validate("Local Cont. Addr. Format", LocalContAddrFormat);
        GeneralLedgerSetup.Validate("Bank Account Nos.", BankAccountNo);
        GeneralLedgerSetup.Validate("LCY Code", LCYCode);
        GeneralLedgerSetup.Validate("Global Dimension 1 Code", GlobalDimension1Code);
        GeneralLedgerSetup.Validate("Global Dimension 2 Code", GlobalDimension2Code);
        GeneralLedgerSetup.Validate("Enable Data Check", DataCheck);
        GeneralLedgerSetup.Validate("Acc. Receivables Category", AccReceivablesCategory);
        GeneralLedgerSetup.Modify(true);
    end;
}