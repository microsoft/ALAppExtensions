codeunit 11361 "Create General Ledger Setup BE"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateGeneralLedgerSetup();
    end;

    local procedure UpdateGeneralLedgerSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CreateCurrency: Codeunit "Create Currency";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateVATStatement: Codeunit "Create VAT Statement";
        CreateGenJournalBatch: Codeunit "Create Gen. Journal Batch";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("EMU Currency", true);
        GeneralLedgerSetup.Validate("Local Currency Symbol", '');
        GeneralLedgerSetup.Validate("Local Currency Description", '');
        GeneralLedgerSetup.Validate("LCY Code", CreateCurrency.EUR());
        GeneralLedgerSetup.Validate("Bank Acc. Recon. Template Name", CreateGenJournalTemplate.PaymentJournal());
        GeneralLedgerSetup.Validate("VAT Statement Template Name", CreateVATStatement.VATTemplateName());
        GeneralLedgerSetup.Validate("VAT Statement Name", CreateGenJournalBatch.Default());
        GeneralLedgerSetup."Unit-Amount Rounding Precision" := 0.001;
        GeneralLedgerSetup."Simplified Intrastat Decl." := true;
        GeneralLedgerSetup."Journal Templ. Name Mandatory" := true;
        GeneralLedgerSetup."Hide Payment Method Code" := true;
        GeneralLedgerSetup.Modify(true);
    end;
}