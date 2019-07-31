codeunit 1954 "LP Feature Table Helper"
{
    trigger OnRun();
    begin
    end;

    procedure ResetAndFillFeaturesTable(var LPMLInputData: Record "LP ML Input Data"; CustomerNo: Code[20]; BasedOnIncrement: Boolean; LastInvoicePostingDate: Date);
    var
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        LPMLInputData.DeleteAll();

        LPMachineLearningSetup.GetSingleInstance();
        if BasedOnIncrement or (CustomerNo <> '') then
            LPMachineLearningSetup."Last Feature Table Reset" := 0DT // table will need to be rebuilt
        else
            LPMachineLearningSetup."Last Feature Table Reset" := CurrentDateTime();
        SetBasicFilterOnSalesInvoiceHeader(SalesInvoiceHeader);
        LPMachineLearningSetup."OverestimatedInvNo OnLastReset" := SalesInvoiceHeader.Count();
        LPMachineLearningSetup.Modify();

        CreateLPMLInputData(LPMLInputData, CustomerNo);
        // in case of basing data only on the increment, keep only the increment
        if BasedOnIncrement then begin
            LPMLInputData.SetCurrentKey("Posting Date");
            LPMLInputData.SetAscending("Posting Date", true);
            LPMLInputData.SetFilter("Posting Date", '<=%1', LastInvoicePostingDate);
            LPMLInputData.DeleteAll();
            LPMLInputData.SetFilter("Posting Date", '');
        end;
    end;

    procedure SetBasicFilterOnSalesInvoiceHeader(var SalesInvoiceHeader: Record "Sales Invoice Header");
    begin
        SalesInvoiceHeader.SetRange(Cancelled, false);
        SalesInvoiceHeader.SetFilter(Amount, '>%1', 0);
        SalesInvoiceHeader.SetFilter("Due Date", '<>%1', 0D);
    end;

    procedure SetFiltersOnSalesInvoiceHeaderToAddToInput(var LppSalesInvoiceHeaderInput: Query "LPP Sales Invoice Header Input"; CustomerNo: Code[20])
    begin

        if CustomerNo <> '' then
            LppSalesInvoiceHeaderInput.SetRange(BillToCustomerNo, CustomerNo);
    end;

    local procedure CreateLPMLInputData(var LPMLInputData: Record "LP ML Input Data"; CustomerNo: Code[20])
    var
        LppSalesInvoiceHeaderInput: Query "LPP Sales Invoice Header Input";
    begin
        SetFiltersOnSalesInvoiceHeaderToAddToInput(LppSalesInvoiceHeaderInput, CustomerNo);
        LppSalesInvoiceHeaderInput.Open();
        while (LppSalesInvoiceHeaderInput.Read()) do
            LPMLInputData.InsertFromSalesInvoice(LppSalesInvoiceHeaderInput);
        LppSalesInvoiceHeaderInput.Close();
        Commit(); // we don't want to lose everything that was done if an error is thrown later (not enough data available for example)
    end;

    procedure CountLPMLInputData(CustomerNo: Code[20]; LastPostingDate: Date; var InvoiceCountOnOrBeforePostingDate: Integer; var InvoiceCountAfterPostingDate: Integer)
    var
        LppSalesInvoiceHeaderInput: Query "LPP Sales Invoice Header Input";
    begin
        InvoiceCountOnOrBeforePostingDate := 0;
        InvoiceCountAfterPostingDate := 0;
        SetFiltersOnSalesInvoiceHeaderToAddToInput(LppSalesInvoiceHeaderInput, CustomerNo);
        LppSalesInvoiceHeaderInput.Open();
        while (LppSalesInvoiceHeaderInput.Read()) do
            if LppSalesInvoiceHeaderInput.PostingDate <= LastPostingDate then
                InvoiceCountOnOrBeforePostingDate += 1
            else
                InvoiceCountAfterPostingDate += 1;
        LppSalesInvoiceHeaderInput.Close();
    end;

    procedure CalculateNumberPaidInvoices(InvoiceCreationDate: Date; InvoiceCustomerNo: Code[20]; LPMLInputData: Record "LP ML Input Data"): Integer;
    begin
        // Count the number of Paid invoices for a given customer at a given date

        // count invoices for the given customer
        LPMLInputData.SetRange("Bill-to Customer No.", InvoiceCustomerNo);

        // invoice should be paid (closed) now
        LPMLInputData.SetRange(Closed, true);

        // it should have been closed at the time of creation of the invoice
        LPMLInputData.SetFilter("Closed Date", '<%1', InvoiceCreationDate);

        exit(LPMLInputData.Count());
    end;

    procedure WasInvoiceHeaderPaidLate(LppSalesInvoiceHeaderInput: Query "LPP Sales Invoice Header Input"): Boolean
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ClosedDate: Date;
    begin
        if not LppSalesInvoiceHeaderInput.Closed then
            exit(false);

        CustLedgerEntry.SetRange("Entry No.", LppSalesInvoiceHeaderInput.CustLedgerEntryNo);
        if CustLedgerEntry.FindFirst() then
            ClosedDate := CustLedgerEntry."Closed at Date";
        exit(LppSalesInvoiceHeaderInput.DueDate < ClosedDate);
    end;

    procedure CalculateNumberPaidLateInvoices(InvoiceCreationDate: Date; InvoiceCustomerNo: Code[20]; LPMLInputData: Record "LP ML Input Data"): Integer;
    begin
        // count invoices for the given customer
        LPMLInputData.SetRange("Bill-to Customer No.", InvoiceCustomerNo);

        // invoice should be paid (closed) now
        LPMLInputData.SetRange(Closed, true);

        // it should have been closed at the time of creation of the invoice
        LPMLInputData.SetFilter("Closed Date", '<%1', InvoiceCreationDate);

        // it should have been paid late (closed date > due date)
        LPMLInputData.SetRange("Is Late", true);

        exit(LPMLInputData.Count());
    end;

    procedure CalculateTotalPaidInvoicesAmount(InvoiceCreationDate: Date; InvoiceCustomerNo: Code[20]; LPMLInputData: Record "LP ML Input Data"): Decimal;
    begin
        // count invoices for the given customer
        LPMLInputData.SetRange("Bill-to Customer No.", InvoiceCustomerNo);

        // invoice should be paid (closed) now
        LPMLInputData.SetRange(Closed, true);

        // it should have been closed at the time of creation of the invoice
        LPMLInputData.SetFilter("Closed Date", '<%1', InvoiceCreationDate);

        LPMLInputData.CalcSums("Base Amount");
        exit(LPMLInputData."Base Amount");

    end;

    procedure CalculateTotalPaidLateInvoicesAmount(InvoiceCreationDate: Date; InvoiceCustomerNo: Code[20]; LPMLInputData: Record "LP ML Input Data"): Decimal;
    begin
        // count invoices for the given customer
        LPMLInputData.SetRange("Bill-to Customer No.", InvoiceCustomerNo);

        // invoice should be paid (closed) now
        LPMLInputData.SetRange(Closed, true);

        // it should have been closed at the time of creation of the invoice
        LPMLInputData.SetFilter("Closed Date", '<%1', InvoiceCreationDate);

        // it should have been paid late (closed date > due date)
        LPMLInputData.SetRange("Is Late", true);

        LPMLInputData.CalcSums("Base Amount");
        exit(LPMLInputData."Base Amount");
    end;

    procedure CalculateAveragePaidLateInvoicesDays(InvoiceCreationDate: Date; InvoiceCustomerNo: Code[20]; LPMLInputData: Record "LP ML Input Data"): Decimal;
    begin
        // count invoices for the given customer
        LPMLInputData.SetRange("Bill-to Customer No.", InvoiceCustomerNo);

        // invoice should be paid (closed) now
        LPMLInputData.SetRange(Closed, true);

        // it should have been closed at the time of creation of the invoice
        LPMLInputData.SetFilter("Closed Date", '<%1', InvoiceCreationDate);

        // it should have been paid late (closed date > due date)
        LPMLInputData.SetRange("Is Late", true);

        // calculate the sum of the late days
        LPMLInputData.CalcSums("Paid Late Days");

        // return the average
        if LPMLInputData.Count() > 0 then
            exit(LPMLInputData."Paid Late Days" / LPMLInputData.Count());
    end;

    procedure CalculateNumberOutstandingInvoices(InvoiceCreationDate: Date; InvoiceCustomerNo: Code[20]; LPMLInputData: Record "LP ML Input Data"): Integer;
    begin
        // count invoices for the given customer
        LPMLInputData.SetRange("Bill-to Customer No.", InvoiceCustomerNo);

        // it should still be open at the time of creation of the invoice
        LPMLInputData.SetFilter("Posting Date", '<%1', InvoiceCreationDate); // created before the date
        LPMLInputData.SetFilter("Closed Date", '>=%1|%2', InvoiceCreationDate, 0D); // closed after the date (= still open at this date), or not closed yet even now
        exit(LPMLInputData.Count());
    end;

    procedure CalculateNumberOutstandingLateInvoices(InvoiceCreationDate: Date; InvoiceCustomerNo: Code[20]; LPMLInputData: Record "LP ML Input Data"): Integer;
    begin
        // count invoices for the given customer
        LPMLInputData.SetRange("Bill-to Customer No.", InvoiceCustomerNo);

        // it should still be open at the time of creation of the invoice
        LPMLInputData.SetFilter("Posting Date", '<%1', InvoiceCreationDate); // created before the date
        LPMLInputData.SetFilter("Closed Date", '>=%1|%2', InvoiceCreationDate, 0D); // closed after the date (= still open at this date), or not closed yet even now

        // it should be late (we are past the due date)
        LPMLInputData.SetFilter("Due Date", '<%1', InvoiceCreationDate);

        exit(LPMLInputData.Count());
    end;

    procedure CalculateTotalOutstandingInvoicesAmount(InvoiceCreationDate: Date; InvoiceCustomerNo: Code[20]; LPMLInputData: Record "LP ML Input Data"): Decimal;
    begin
        // count invoices for the given customer
        LPMLInputData.SetRange("Bill-to Customer No.", InvoiceCustomerNo);

        // it should still be open at the time of creation of the invoice
        LPMLInputData.SetFilter("Posting Date", '<%1', InvoiceCreationDate); // created before the date
        LPMLInputData.SetFilter("Closed Date", '>=%1|%2', InvoiceCreationDate, 0D); // closed after the date (= still open at this date), or not closed yet even now

        LPMLInputData.CalcSums("Base Amount");
        exit(LPMLInputData."Base Amount");
    end;

    procedure CalculateTotalOutstandingLateInvoicesAmount(InvoiceCreationDate: Date; InvoiceCustomerNo: Code[20]; LPMLInputData: Record "LP ML Input Data"): Decimal;
    begin
        // count invoices for the given customer
        LPMLInputData.SetRange("Bill-to Customer No.", InvoiceCustomerNo);

        // it should still be open at the time of creation of the invoice
        LPMLInputData.SetFilter("Posting Date", '<%1', InvoiceCreationDate); // created before the date
        LPMLInputData.SetFilter("Closed Date", '>=%1|%2', InvoiceCreationDate, 0D); // closed after the date (= still open at this date), or not closed yet even now

        // it should be late (we are past the due date)
        LPMLInputData.SetFilter("Due Date", '<%1', InvoiceCreationDate);

        LPMLInputData.CalcSums("Base Amount");
        exit(LPMLInputData."Base Amount");
    end;

    procedure CalculateAverageOutstandingDaysLate(InvoiceCreationDate: Date; InvoiceCustomerNo: Code[20]; LPMLInputData: Record "LP ML Input Data"): Decimal;
    var
        SumNbDaysLate: Integer;
    begin
        // count invoices for the given customer
        LPMLInputData.SetRange("Bill-to Customer No.", InvoiceCustomerNo);

        // it should still be open at the time of creation of the invoice, and late
        LPMLInputData.SetFilter("Posting Date", '<%1', InvoiceCreationDate);
        LPMLInputData.SetFilter("Closed Date", '>=%1|%2', InvoiceCreationDate, 0D);

        // it should be late (we are past the due date)
        LPMLInputData.SetFilter("Due Date", '<%1', InvoiceCreationDate);

        SumNbDaysLate := 0;
        if LPMLInputData.FindSet() then
            repeat
                SumNbDaysLate += InvoiceCreationDate - LPMLInputData."Due Date";
            until LPMLInputData.Next() = 0
        else
            exit(0);

        exit(SumNbDaysLate / LPMLInputData.Count());
    end;

}