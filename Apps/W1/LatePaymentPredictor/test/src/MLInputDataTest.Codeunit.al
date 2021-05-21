codeunit 139576 "LP ML Input Data Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;
    SingleInstance = true;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LPFeatureTableHelper: Codeunit "LP Feature Table Helper";

    trigger OnRun();
    begin
        // [FEATURE] [Late Payment ML]
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestLPPQuery()
    var
        SalesInvoiceHeader1: Record "Sales Invoice Header";
        SalesInvoiceHeader2: Record "Sales Invoice Header";
        SalesInvoiceHeader3: Record "Sales Invoice Header";
        SalesInvoiceHeader4: Record "Sales Invoice Header";
        SalesInvoiceHeader5: Record "Sales Invoice Header";
        SalesInvoiceHeader6: Record "Sales Invoice Header";
        LppSalesInvoiceHeaderInput: Query "LPP Sales Invoice Header Input";
        Counter: Integer;
    begin
        SalesInvoiceHeader1.DeleteAll();
        // first with no lines
        CreateInvoiceHeader(SalesInvoiceHeader1, 'ONE', CalcDate('<5D>', WorkDate()));

        // second with line but 0 amount
        CreateInvoiceHeader(SalesInvoiceHeader2, 'TWO', CalcDate('<5D>', WorkDate()));
        CreateInvoiceLine(SalesInvoiceHeader2, 0);

        // third with one line with amount 10
        CreateInvoiceHeader(SalesInvoiceHeader3, 'THREE', CalcDate('<5D>', WorkDate()));
        CreateInvoiceLine(SalesInvoiceHeader3, 10);

        // fourth like third with reversed cust ledger entry
        CreateInvoiceHeader(SalesInvoiceHeader4, 'FOUR', CalcDate('<5D>', WorkDate()));
        CreateInvoiceLine(SalesInvoiceHeader4, 10);
        CreateCustLedgEntry(SalesInvoiceHeader4, true);

        // fifth like third with no reversed cust ledger entry
        CreateInvoiceHeader(SalesInvoiceHeader5, 'FIVE', CalcDate('<5D>', WorkDate()));
        CreateInvoiceLine(SalesInvoiceHeader5, 10);
        CreateCustLedgEntry(SalesInvoiceHeader5, false);

        // sixth like third with due date before third
        CreateInvoiceHeader(SalesInvoiceHeader6, 'SIX', CalcDate('<2D>', WorkDate()));
        CreateInvoiceLine(SalesInvoiceHeader6, 10);

        // 3 records: third , fifth and sixth Expected
        LppSalesInvoiceHeaderInput.Open();

        while (LppSalesInvoiceHeaderInput.Read()) do begin
            Counter += 1;
            case Counter of
                1:
                    Assert.AreEqual('SIX', LppSalesInvoiceHeaderInput.No, 'Lowest due date first');
                2:
                    Assert.AreEqual('FIVE', LppSalesInvoiceHeaderInput.No, 'Higher due date and added later');
                3:
                    Assert.AreEqual('THREE', LppSalesInvoiceHeaderInput.No, 'Higher due date and added early');
                4:
                    Assert.Fail('Only 3 records are expected.');
            end;
            Assert.AreEqual(10, LppSalesInvoiceHeaderInput.Amount, 'Amounts are always 10');
        end;

        LppSalesInvoiceHeaderInput.Close();
    end;

    local procedure CreateInvoiceHeader(var SalesInvoiceHeader: Record "Sales Invoice Header"; Number: Code[20]; DueDate: Date);
    begin
        SalesInvoiceHeader.Init();
        SalesInvoiceHeader."No." := Number;
        SalesInvoiceHeader."Posting Date" := WorkDate();
        SalesInvoiceHeader."Due Date" := DueDate;
        SalesInvoiceHeader.Insert();
    end;

    local procedure CreateInvoiceLine(SalesInvoiceHeader: Record "Sales Invoice Header"; Amount: Decimal);
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine.Init();
        SalesInvoiceLine."Document No." := SalesInvoiceHeader."No.";
        SalesInvoiceLine."Line No." := 10000;
        SalesInvoiceLine.Amount := Amount;
        SalesInvoiceLine.Insert();
    end;

    local procedure CreateCustLedgEntry(var SalesInvoiceHeader: Record "Sales Invoice Header"; Reversed: Boolean)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        LastEntryNo: Integer;
    begin
        CustLedgerEntry.FindLast();
        LastEntryNo := CustLedgerEntry."Entry No.";
        CustLedgerEntry.Init();
        CustLedgerEntry."Entry No." := LastEntryNo + 1;
        CustLedgerEntry.Reversed := Reversed;
        CustLedgerEntry.Insert();

        SalesInvoiceHeader."Cust. Ledger Entry No." := CustLedgerEntry."Entry No.";
        SalesInvoiceHeader.Modify();
    end;

    [Test]
    procedure TestLPMLInputData();
    var
        GenJournalLine: Record "Gen. Journal Line";
        LPMLInputData: Record "LP ML Input Data";
        SalesInvoiceHeader1: Record "Sales Invoice Header";
        SalesInvoiceHeader2: Record "Sales Invoice Header";
        SalesInvoiceHeader3: Record "Sales Invoice Header";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        CustomerNo: Code[20];
        Invoice1CreationDate: Date;
        Invoice2CreationDate: Date;
        Invoice3CreationDate: Date;
        Invoice1DueDate: Date;
        Invoice2DueDate: Date;
        Invoice3DueDate: Date;
        Invoice1PaidDate: Date;
        Invoice2PaidDate: Date;
    begin
        LibraryERMCountryData.UpdateLocalData();

        Invoice1CreationDate := DMY2Date(01, 07, 2017);
        Invoice1DueDate := DMY2Date(07, 07, 2017);
        Invoice1PaidDate := DMY2Date(13, 07, 2017);

        Invoice2CreationDate := DMY2Date(03, 07, 2017);
        Invoice2DueDate := DMY2Date(11, 07, 2017);
        Invoice2PaidDate := DMY2Date(09, 07, 2017);

        Invoice3CreationDate := DMY2Date(05, 07, 2017);
        Invoice3DueDate := DMY2Date(15, 07, 2017);

        CustomerNo := LibrarySales.CreateCustomerNo();

        // paid in time
        PostPaidInvoice(CustomerNo, Invoice1CreationDate, Invoice1DueDate, Invoice1PaidDate, SalesInvoiceHeader1, GenJournalLine);
        SalesInvoiceHeader1.Get(SalesInvoiceHeader1."No.");

        // paid late
        PostPaidInvoice(CustomerNo, Invoice2CreationDate, Invoice2DueDate, Invoice2PaidDate, SalesInvoiceHeader2, GenJournalLine);

        SalesInvoiceHeader2.Get(SalesInvoiceHeader2."No.");
        Assert.AreEqual(Invoice2CreationDate, SalesInvoiceHeader2."Posting Date", 'posting date incorrect');
        Assert.AreEqual(Invoice2DueDate, SalesInvoiceHeader2."Due Date", 'Due date incorrect');

        PostUnpaidInvoice(CustomerNo, Invoice3CreationDate, Invoice3DueDate, SalesInvoiceHeader3);
        SalesInvoiceHeader3.Get(SalesInvoiceHeader3."No.");

        LPFeatureTableHelper.ResetAndFillFeaturesTable(LPMLInputData, '', false, 0D);

        LPMLInputData.Get(SalesInvoiceHeader1."No.");
        Assert.IsFalse(LPMLInputData.Corrected, 'Corrected should be false');

        LPMLInputData.Get(SalesInvoiceHeader2."No.");
        Assert.AreEqual(Invoice2PaidDate, LPMLInputData."Closed Date", 'Closed date incorrect');
        Assert.IsFalse(LPMLInputData.Corrected, 'Corrected should be false');
        Assert.AreEqual(Invoice2DueDate - Invoice2CreationDate, LPMLInputData."Payment Terms Days", 'Payment terms days incorrect');


        LPMLInputData.Get(SalesInvoiceHeader3."No.");
        Assert.IsFalse(LPMLInputData.Corrected, 'Corrected should be false');


        PostSalesCreditMemo(CustomerNo, SalesInvoiceHeader3."No.");

        LPFeatureTableHelper.ResetAndFillFeaturesTable(LPMLInputData, '', false, 0D);
        LPMLInputData.Get(SalesInvoiceHeader3."No.");
        Assert.IsTrue(LPMLInputData.Corrected, 'Corrected should be true');

        LPMLInputData.Reset();
        SalesInvoiceHeader1.CalcFields(Amount);
        SalesInvoiceHeader2.CalcFields(Amount);
        SalesInvoiceHeader3.CalcFields(Amount);

        // test LP sales header mirror
        // CalculateNumberPaidInvoices
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<-1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+0D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+0D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+1D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+0D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+1D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+0D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+1D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+0D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');
        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+1D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');

        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+0D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');
        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+1D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');

        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+0D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');
        Assert.AreEqual(2, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+1D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');

        Assert.AreEqual(2, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+0D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');
        Assert.AreEqual(2, LPFeatureTableHelper.CalculateNumberPaidInvoices(CALCDATE('<+1D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect nb paid invoices');

        // CalculateTotalPaidInvoicesAmount
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<-1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+0D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+0D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+1D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+0D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+1D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+0D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+1D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+0D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');
        Assert.AreEqual(SalesInvoiceHeader2.Amount, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+1D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');

        Assert.AreEqual(SalesInvoiceHeader2.Amount, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+0D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');
        Assert.AreEqual(SalesInvoiceHeader2.Amount, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+1D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');

        Assert.AreEqual(SalesInvoiceHeader2.Amount, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+0D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');
        Assert.AreEqual(SalesInvoiceHeader1.Amount + SalesInvoiceHeader2.Amount, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+1D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');

        Assert.AreEqual(SalesInvoiceHeader1.Amount + SalesInvoiceHeader2.Amount, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+0D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');
        Assert.AreEqual(SalesInvoiceHeader1.Amount + SalesInvoiceHeader2.Amount, LPFeatureTableHelper.CalculateTotalPaidInvoicesAmount(CALCDATE('<+1D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect amount paid invoices');


        // CalculateNumberPaidLateInvoices
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<-1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<+0D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<+1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<+0D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<+1D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<+0D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<+1D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<+0D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<+1D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<+0D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<+1D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<+0D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<+1D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<<+0D>>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');
        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<+1D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');

        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<+0D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');
        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberPaidLateInvoices(CALCDATE('<+1D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');

        // CalculateTotalPaidLateInvoicesAmount
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<-1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+0D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+0D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+1D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+0D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+1D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+0D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+1D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+0D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+1D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect nb paid late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+0D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+1D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+0D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');
        Assert.AreEqual(SalesInvoiceHeader1.Amount, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+1D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');

        Assert.AreEqual(SalesInvoiceHeader1.Amount, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+0D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');
        Assert.AreEqual(SalesInvoiceHeader1.Amount, LPFeatureTableHelper.CalculateTotalPaidLateInvoicesAmount(CALCDATE('<+1D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect amount paid late invoices');

        // CalculateAveragePaidLateInvoicesDays
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<-1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+0D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+0D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+1D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+0D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+1D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+0D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+1D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+0D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+1D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+0D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+1D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+0D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');
        Assert.AreEqual(6, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+1D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');

        Assert.AreEqual(6, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+0D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');
        Assert.AreEqual(6, LPFeatureTableHelper.CalculateAveragePaidLateInvoicesDays(CALCDATE('<+1D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect average paid late days');


        // CalculateNumberOutstandingInvoices
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<-1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+0D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');
        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');

        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+0D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');
        Assert.AreEqual(2, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+1D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');

        Assert.AreEqual(2, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+0D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');
        Assert.AreEqual(3, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+1D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');

        Assert.AreEqual(3, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+0D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');
        Assert.AreEqual(3, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+1D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');

        Assert.AreEqual(3, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+0D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');
        Assert.AreEqual(2, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+1D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');

        Assert.AreEqual(2, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+0D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');
        Assert.AreEqual(2, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+1D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');

        Assert.AreEqual(2, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+0D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');
        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+1D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');

        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+0D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');
        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberOutstandingInvoices(CALCDATE('<+1D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding invoices');


        // CalculateNumberOutstandingLateInvoices
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<-1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+0D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+0D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+1D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+0D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+1D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+0D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');
        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+1D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');

        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+0D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');
        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+1D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');

        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+0D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');
        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+1D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');

        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+0D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+1D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+0D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');
        Assert.AreEqual(1, LPFeatureTableHelper.CalculateNumberOutstandingLateInvoices(CALCDATE('<+1D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect number outstanding late invoices');

        // CalculateTotalOutstandingInvoicesAmount
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<-1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+0D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');
        Assert.AreEqual(SalesInvoiceHeader1.Amount, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');

        Assert.AreEqual(SalesInvoiceHeader1.Amount, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+0D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');
        Assert.AreEqual(SalesInvoiceHeader1.Amount + SalesInvoiceHeader2.Amount, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+1D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');

        Assert.AreEqual(SalesInvoiceHeader1.Amount + SalesInvoiceHeader2.Amount, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+0D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');
        Assert.AreEqual(SalesInvoiceHeader1.Amount + SalesInvoiceHeader2.Amount + SalesInvoiceHeader3.Amount, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+1D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');

        Assert.AreEqual(SalesInvoiceHeader1.Amount + SalesInvoiceHeader2.Amount + SalesInvoiceHeader3.Amount, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+0D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');
        Assert.AreEqual(SalesInvoiceHeader1.Amount + SalesInvoiceHeader2.Amount + SalesInvoiceHeader3.Amount, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+1D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');

        Assert.AreEqual(SalesInvoiceHeader1.Amount + SalesInvoiceHeader2.Amount + SalesInvoiceHeader3.Amount, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+0D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');
        Assert.AreEqual(SalesInvoiceHeader1.Amount + SalesInvoiceHeader3.Amount, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+1D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');

        Assert.AreEqual(SalesInvoiceHeader1.Amount + SalesInvoiceHeader3.Amount, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+0D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');
        Assert.AreEqual(SalesInvoiceHeader1.Amount + SalesInvoiceHeader3.Amount, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+1D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');

        Assert.AreEqual(SalesInvoiceHeader1.Amount + SalesInvoiceHeader3.Amount, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+0D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');
        Assert.AreEqual(SalesInvoiceHeader3.Amount, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+1D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');

        Assert.AreEqual(SalesInvoiceHeader3.Amount, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+0D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');
        Assert.AreEqual(SalesInvoiceHeader3.Amount, LPFeatureTableHelper.CalculateTotalOutstandingInvoicesAmount(CALCDATE('<+1D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect outstanding invoices total amount');

        // CalculateTotalOutstandingLateInvoicesAmount
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<-1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+0D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+0D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+1D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+0D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+1D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+0D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');
        Assert.AreEqual(SalesInvoiceHeader1.Amount, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+1D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');

        Assert.AreEqual(SalesInvoiceHeader1.Amount, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+0D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');
        Assert.AreEqual(SalesInvoiceHeader1.Amount, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+1D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');

        Assert.AreEqual(SalesInvoiceHeader1.Amount, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+0D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');
        Assert.AreEqual(SalesInvoiceHeader1.Amount, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+1D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');

        Assert.AreEqual(SalesInvoiceHeader1.Amount, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+0D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+1D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+0D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');
        Assert.AreEqual(SalesInvoiceHeader3.Amount, LPFeatureTableHelper.CalculateTotalOutstandingLateInvoicesAmount(CALCDATE('<+1D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect outstanding late invoices total amount');

        // CalculateAverageOutstandingDaysLate
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<-1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+0D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+1D>', Invoice1CreationDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+0D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+1D>', Invoice2CreationDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+0D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+1D>', Invoice3CreationDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+0D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');
        Assert.AreEqual(1, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+1D>', Invoice1DueDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');

        Assert.AreEqual(Invoice2PaidDate - Invoice1DueDate, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+0D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');
        Assert.AreEqual(Invoice2PaidDate - Invoice1DueDate + 1, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+1D>', Invoice2PaidDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');

        Assert.AreEqual(Invoice2DueDate - Invoice1DueDate, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+0D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');
        Assert.AreEqual(Invoice2DueDate - Invoice1DueDate + 1, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+1D>', Invoice2DueDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');

        Assert.AreEqual(Invoice1PaidDate - Invoice1DueDate, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+0D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');
        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+1D>', Invoice1PaidDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');

        Assert.AreEqual(0, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+0D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');
        Assert.AreEqual(1, LPFeatureTableHelper.CalculateAverageOutstandingDaysLate(CALCDATE('<+1D>', Invoice3DueDate), CustomerNo, LPMLInputData), 'Incorrect average outstanding invoices late days');
    end;


    procedure PostPaidInvoice(CustomerNo: Code[20]; PostingDate: Date; DueDate: Date; PaymentDate: Date; var SalesInvoiceHeader: Record "Sales Invoice Header"; var GenJournalLine: Record "Gen. Journal Line");
    var
        SalesHeader: Record "Sales Header";
        PostedSalesInvoiceCode: Code[20];
    begin
        WorkDate(PostingDate);
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, CustomerNo);
        SalesHeader."Posting Date" := PostingDate;
        SalesHeader."Due Date" := DueDate;
        SalesHeader.Modify();
        PostedSalesInvoiceCode := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        SalesInvoiceHeader.Get(PostedSalesInvoiceCode);
        SalesInvoiceHeader.CalcFields("Amount Including VAT");

        WorkDate(PaymentDate);
        LibrarySales.CreatePaymentAndApplytoInvoice(GenJournalLine, SalesInvoiceHeader."Bill-to Customer No.", PostedSalesInvoiceCode, -SalesInvoiceHeader."Amount Including VAT");
    end;

    local procedure PostUnpaidInvoice(CustomerNo: Code[20]; PostingDate: Date; DueDate: Date; var SalesInvoiceHeader: Record "Sales Invoice Header");
    var
        SalesHeader: Record "Sales Header";
        PostedSalesInvoiceCode: Code[20];
    begin
        WorkDate(PostingDate);
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, CustomerNo);
        SalesHeader."Posting Date" := PostingDate;
        SalesHeader."Due Date" := DueDate;
        PostedSalesInvoiceCode := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        SalesInvoiceHeader.Get(PostedSalesInvoiceCode);
    end;

    local procedure PostSalesCreditMemo(CustomerNo: Code[20]; AppliesToInvoiceNo: Code[20]);
    var
        SalesHeaderMemo: Record "Sales Header";
        Item: Record Item;
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        LibraryRandom: Codeunit "Library - Random";
    begin
        LibrarySales.CreateSalesHeader(SalesHeaderMemo, SalesHeaderMemo."Document Type"::"Credit Memo", CustomerNo);
        SalesInvoiceHeader.Get(AppliesToInvoiceNo);
        SalesInvoiceHeader.CalcFields(Amount);
        LibraryInventory.CreateItemWithUnitPriceAndUnitCost(
           Item, LibraryRandom.RandDecInRange(1, Round(SalesInvoiceHeader.Amount, 1), 2),
           LibraryRandom.RandDecInRange(1, Round(SalesInvoiceHeader.Amount, 1), 2));
        LibrarySales.CreateSalesLine(SalesLine, SalesHeaderMemo, SalesLine.Type::Item, Item."No.", 1);

        SalesHeaderMemo."Posting Date" := WorkDate();
        SalesHeaderMemo.Validate("Bill-to Customer No.", CustomerNo);
        SalesHeaderMemo.Validate("Applies-to Doc. Type", SalesHeaderMemo."Applies-to Doc. Type"::Invoice);
        SalesHeaderMemo.Validate("Applies-to Doc. No.", AppliesToInvoiceNo);

        SalesHeaderMemo.Modify(true);
        LibrarySales.PostSalesDocument(SalesHeaderMemo, false, false);
    end;

    [Test]
    procedure TestResetAndFillFeaturesTableBasedOnIncrement();
    var
        GenJournalLine: Record "Gen. Journal Line";
        LPMLInputData: Record "LP ML Input Data";
        SalesInvoiceHeader1: Record "Sales Invoice Header";
        SalesInvoiceHeader2: Record "Sales Invoice Header";
        SalesInvoiceHeader3: Record "Sales Invoice Header";
        SalesInvoiceHeader4: Record "Sales Invoice Header";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        Invoice1CreationDate: Date;
        Invoice2CreationDate: Date;
        Invoice3CreationDate: Date;
        Invoice4CreationDate: Date;
        Invoice1DueDate: Date;
        Invoice2DueDate: Date;
        Invoice3DueDate: Date;
        Invoice4DueDate: Date;
        Invoice1PaidDate: Date;
        Invoice2PaidDate: Date;
        Invoice3PaidDate: Date;
        Invoice4PaidDate: Date;
        CustomerNo: Code[20];
        NewStartingDate: Date;
    begin
        LPMLInputData.SetCurrentKey("Posting Date");
        LPMLInputData.SetAscending("Posting Date", true);
        if LPMLInputData.FindLast()
        then
            NewStartingDate := LPMLInputData."Posting Date"
        else
            NewStartingDate := DMY2Date(01, 07, 2021);
        LibraryERMCountryData.UpdateLocalData();
        CustomerNo := LibrarySales.CreateCustomerNo();

        // paid in time
        Invoice1CreationDate := NewStartingDate + 1;
        Invoice1DueDate := Invoice1CreationDate + 3;
        Invoice1PaidDate := Invoice1DueDate - 1;

        PostPaidInvoice(CustomerNo, Invoice1CreationDate, Invoice1DueDate, Invoice1PaidDate, SalesInvoiceHeader1, GenJournalLine);

        Assert.AreEqual(Invoice1CreationDate, SalesInvoiceHeader1."Posting Date", 'posting date incorrect');
        Assert.AreEqual(Invoice1DueDate, SalesInvoiceHeader1."Due Date", 'Due date incorrect');

        // paid late
        Invoice2CreationDate := Invoice1CreationDate + 1;
        Invoice2DueDate := Invoice2CreationDate + 3;
        Invoice2PaidDate := Invoice2DueDate + 1;

        PostPaidInvoice(CustomerNo, Invoice2CreationDate, Invoice2DueDate, Invoice2PaidDate, SalesInvoiceHeader2, GenJournalLine);

        Assert.AreEqual(Invoice2CreationDate, SalesInvoiceHeader2."Posting Date", 'posting date incorrect');
        Assert.AreEqual(Invoice2DueDate, SalesInvoiceHeader2."Due Date", 'Due date incorrect');

        LPFeatureTableHelper.ResetAndFillFeaturesTable(LPMLInputData, '', false, 0D);

        // Add 2 more invoices
        // paid in time
        Invoice3CreationDate := Invoice2CreationDate + 1;
        Invoice3DueDate := Invoice3CreationDate + 3;
        Invoice3PaidDate := Invoice3DueDate - 1;

        PostPaidInvoice(CustomerNo, Invoice3CreationDate, Invoice3DueDate, Invoice3PaidDate, SalesInvoiceHeader3, GenJournalLine);

        // paid late
        Invoice4CreationDate := Invoice3CreationDate + 1;
        Invoice4DueDate := Invoice4CreationDate + 3;
        Invoice4PaidDate := Invoice4DueDate - 1;

        PostPaidInvoice(CustomerNo, Invoice4CreationDate, Invoice4DueDate, Invoice4PaidDate, SalesInvoiceHeader4, GenJournalLine);

        LPMLInputData.FindLast();
        LPFeatureTableHelper.ResetAndFillFeaturesTable(LPMLInputData, '', true, LPMLInputData."Posting Date");

        Assert.AreEqual(2, LPMLInputData.Count(), 'Incorrect nr of input data records');

    end;
}