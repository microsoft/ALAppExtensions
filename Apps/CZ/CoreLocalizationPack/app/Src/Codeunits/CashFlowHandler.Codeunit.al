codeunit 31045 "Cash Flow Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Flow Management", 'OnAfterSetViewOnVATEntryForTaxCalc', '', false, false)]
    local procedure VATDateCZLFilterOnAfterSetViewOnVATEntryForTaxCalc(var VATEntry: Record "VAT Entry"; TaxPaymentDueDate: Date; DummyDate: Date)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CashFlowSetup: Record "Cash Flow Setup";
        StartDate: Date;
        EndDate: Date;
    begin
        GeneralLedgerSetup.Get();
        if not GeneralLedgerSetup."Use VAT Date CZL" then
            exit;

        VATEntry.Setrange("Document Date");
        VATEntry.SetFilter("VAT Date CZL", '<>%1', DummyDate);
        if TaxPaymentDueDate <> DummyDate then begin
            CashFlowSetup.GetTaxPeriodStartEndDates(TaxPaymentDueDate, StartDate, EndDate);
            VATEntry.SetRange("VAT Date CZL", StartDate, EndDate);
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Suggest Worksheet Lines", 'OnGetTaxPayableDateFromSourceOnBeforeExit', '', false, false)]
    local procedure VATDateCZLOnGetTaxPayableDateFromSourceOnBeforeExit(SourceTableNum: Integer; VATEntry: Record "VAT Entry"; var DocumentDate: Date)
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        if not GeneralLedgerSetup."Use VAT Date CZL" then
            exit;

        case SourceTableNum of
            Database::"VAT Entry":
                DocumentDate := VATEntry."VAT Date CZL";
        end;
    end;
}