namespace Microsoft.Finance.Latepayment;

using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Document;
codeunit 139576 "LP ML Input Data Test"
{
    Subtype = Test;
    TestType = Uncategorized;
    EventSubscriberInstance = Manual;
    SingleInstance = true;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";

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

}
