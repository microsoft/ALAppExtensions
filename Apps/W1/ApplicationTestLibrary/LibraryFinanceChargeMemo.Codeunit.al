/// <summary>
/// Provides utility functions for creating and managing finance charge memos in test scenarios.
/// </summary>
codeunit 131350 "Library - Finance Charge Memo"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        BegininingText: Label 'Posting Date must be %9.';
        EndingText: Label 'Please pay the total of %7.';
        LineDescription: Label '%4% finance Charge with Currency (%8) of %6.';
        LineDescriptionNew: Label '%1% finance Charge with Currency (%2) of %3.';
        PrecisionText: Label '<Precision,%1><Standard format,0>', Locked = true;

    procedure ComputeDescription(FinanceChargeTerms: Record "Finance Charge Terms"; var Description: Text[100]; var DocumentDate: Date; PostedDocumentNo: Code[20])
    var
        Currency: Record Currency;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Amount: Decimal;
    begin
        // To fetch the Decimal Places from the computed Amount, used Format with Currency Decimal Precision.
        LibraryERM.FindCustomerLedgerEntry(CustLedgerEntry, CustLedgerEntry."Document Type"::Invoice, PostedDocumentNo);
        CustLedgerEntry.CalcFields(Amount);
        Currency.Get(CustLedgerEntry."Currency Code");
        DocumentDate := CalcDate('<1D>', CalcDate(FinanceChargeTerms."Due Date Calculation", CustLedgerEntry."Due Date"));
        Amount :=
          Round(CustLedgerEntry.Amount * (DocumentDate - CustLedgerEntry."Due Date") / FinanceChargeTerms."Interest Period (Days)");
        Description :=
          StrSubstNo(
            LineDescriptionNew, FinanceChargeTerms."Interest Rate", Currency.Code,
            Format(Amount, 0, StrSubstNo(PrecisionText, Currency."Amount Decimal Places")));
    end;

    procedure CreateFinanceChargeTermAndText(var FinanceChargeTerms: Record "Finance Charge Terms")
    var
        FinanceChargeText: Record "Finance Charge Text";
    begin
        // Create Finance Charge Term with Random Interest Rate, Minimum Amount, Additional Amount, Grace Period, Interest Period and
        // Due Date Calculation. Add Beginning, Ending Text for it. Take Minimum Amount less so that Finance Charge Memo can generate.
        LibraryERM.CreateFinanceChargeTerms(FinanceChargeTerms);
        FinanceChargeTerms.Validate("Interest Rate", LibraryRandom.RandInt(5));
        FinanceChargeTerms.Validate("Minimum Amount (LCY)", 1 + LibraryRandom.RandDec(1, 2));
        FinanceChargeTerms.Validate("Additional Fee (LCY)", LibraryRandom.RandInt(5));
        Evaluate(FinanceChargeTerms."Grace Period", '<' + Format(LibraryRandom.RandInt(5)) + 'D>');
        FinanceChargeTerms.Validate("Interest Period (Days)", LibraryRandom.RandInt(30));
        Evaluate(FinanceChargeTerms."Due Date Calculation", '<' + Format(10 + LibraryRandom.RandInt(20)) + 'D>');
        FinanceChargeTerms.Validate("Line Description", LineDescription);
        FinanceChargeTerms.Validate("Post Additional Fee", true);
        FinanceChargeTerms.Validate("Post Interest", true);
        FinanceChargeTerms.Modify(true);
        LibraryERM.CreateFinanceChargeText(
          FinanceChargeText, FinanceChargeTerms.Code, FinanceChargeText.Position::Beginning, BegininingText);
        LibraryERM.CreateFinanceChargeText(FinanceChargeText, FinanceChargeTerms.Code, FinanceChargeText.Position::Ending, EndingText);
    end;
}

