/// <summary>
/// Provides utility functions for setting up and managing payment discount scenarios in test cases.
/// </summary>
codeunit 131303 "Library - Pmt Disc Setup"
{

    trigger OnRun()
    begin
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";

    procedure ClearAdjustPmtDiscInVATSetup()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetRange("Adjust for Payment Discount", true);
        VATPostingSetup.ModifyAll("Adjust for Payment Discount", false, true);
    end;

    procedure GetPmtDiscGracePeriod(): Text
    begin
        GeneralLedgerSetup.Get();
        exit(Format(GeneralLedgerSetup."Payment Discount Grace Period"));
    end;

    procedure GetPmtTolerancePct(): Decimal
    begin
        GeneralLedgerSetup.Get();
        exit(GeneralLedgerSetup."Payment Tolerance %");
    end;

    procedure GetPaymentTermsDiscountPct(PaymentTermsCode: Code[10]): Decimal
    var
        PaymentTerms: Record "Payment Terms";
    begin
        PaymentTerms.Get(PaymentTermsCode);
        exit(PaymentTerms."Discount %");
    end;

    procedure GetPaymentTermsDiscountDate(PaymentTermsCode: Code[10]): Date
    var
        PaymentTerms: Record "Payment Terms";
    begin
        PaymentTerms.Get(PaymentTermsCode);
        exit(CalcDate(PaymentTerms."Discount Date Calculation", WorkDate()));
    end;

    procedure SetAdjustForPaymentDisc(AdjustForPaymentDisc: Boolean)
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Adjust for Payment Disc.", AdjustForPaymentDisc);
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetPmtDiscExclVAT(PmtDiscExclVAT: Boolean)
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Pmt. Disc. Excl. VAT", PmtDiscExclVAT);
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetPmtDiscGracePeriod(GracePeriod: DateFormula)
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Payment Discount Grace Period", GracePeriod);
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetPmtDiscGracePeriodByText(DateFormulaText: Text)
    var
        GracePeriod: DateFormula;
    begin
        Evaluate(GracePeriod, DateFormulaText);
        SetPmtDiscGracePeriod(GracePeriod);
    end;

    procedure SetPmtTolerance(PaymentTolerancePct: Decimal)
    begin
        SetPmtDiscGracePeriodByText('<5D>');
        GeneralLedgerSetup.Validate("Payment Tolerance %", PaymentTolerancePct);
        GeneralLedgerSetup.Validate("Max. Payment Tolerance Amount", 5);
        SetPmtTolerancePostings();
        SetPmtToleranceWarnings();
        GeneralLedgerSetup.Modify(true);
    end;

    local procedure SetPmtTolerancePostings()
    begin
        GeneralLedgerSetup.Validate(
          "Pmt. Disc. Tolerance Posting", GeneralLedgerSetup."Pmt. Disc. Tolerance Posting"::"Payment Discount Accounts");
        GeneralLedgerSetup.Validate(
          "Payment Tolerance Posting", GeneralLedgerSetup."Payment Tolerance Posting"::"Payment Discount Accounts");
    end;

    local procedure SetPmtToleranceWarnings()
    begin
        GeneralLedgerSetup.Validate("Pmt. Disc. Tolerance Warning", true);
        GeneralLedgerSetup.Validate("Payment Tolerance Warning", true);
    end;

    procedure SetPmtToleranceWarning(PmtToleranceWarning: Boolean)
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Payment Tolerance Warning", PmtToleranceWarning);
        GeneralLedgerSetup.Modify(true);
    end;

    procedure SetPmtDiscToleranceWarning(PmtDiscToleranceWarning: Boolean)
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.Validate("Pmt. Disc. Tolerance Warning", PmtDiscToleranceWarning);
        GeneralLedgerSetup.Modify(true);
    end;
}

