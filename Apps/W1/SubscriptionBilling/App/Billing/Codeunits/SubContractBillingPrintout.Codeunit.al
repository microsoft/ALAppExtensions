namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Finance.Currency;

codeunit 8064 "Sub. Contract Billing Printout"
{
    Access = Internal;

    internal procedure FillContractBillingDetailsBufferFromSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempJobLedgerEntryBuffer: Record "Job Ledger Entry"; var ColumnHeaders: array[5] of Text)
    var
        BillingLineArchive: Record "Billing Line Archive";
        SalesInvoiceLine: Record "Sales Invoice Line";
        CustomerContract: Record "Customer Subscription Contract";
        Currency: Record Currency;
        UsageDataBilling: Record "Usage Data Billing";
        ServiceCommitment: Record "Subscription Line";
        SalesDocuments: Codeunit "Sales Documents";
        EntryNo: Integer;
    begin
        if not SalesInvoiceHeader."Recurring Billing" then
            exit;

        if SalesInvoiceHeader."Sub. Contract Detail Overview" = Enum::"Contract Detail Overview"::None then
            exit;

        SalesDocuments.MoveBillingLineToBillingLineArchiveForPostingPreview(SalesInvoiceHeader);

        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetFilter("Subscription Contract No.", '<>%1', '');
        SalesInvoiceLine.SetFilter("Subscription Contract Line No.", '<>%1', 0);
        if SalesInvoiceLine.FindSet() then
            repeat
                ServiceCommitment.SetRange("Subscription Contract No.", SalesInvoiceLine."Subscription Contract No.");
                ServiceCommitment.SetRange("Subscription Contract Line No.", SalesInvoiceLine."Subscription Contract Line No.");
                if ServiceCommitment.FindFirst() and ServiceCommitment."Usage Based Billing" then begin
                    UsageDataBilling.SetRange("Document Type", UsageDataBilling."Document Type"::"Posted Invoice");
                    UsageDataBilling.SetRange("Document No.", SalesInvoiceHeader."No.");
                    UsageDataBilling.SetRange("Subscription Contract No.", SalesInvoiceLine."Subscription Contract No.");
                    UsageDataBilling.SetRange("Subscription Contract Line No.", SalesInvoiceLine."Subscription Contract Line No.");
                    UsageDataBilling.SetAutoCalcFields("Subscription Description");
                    if UsageDataBilling.FindSet() then
                        repeat
                            EntryNo += 1;
                            TempJobLedgerEntryBuffer.Init();
                            TempJobLedgerEntryBuffer."Entry No." := EntryNo;
                            TempJobLedgerEntryBuffer."Document No." := SalesInvoiceLine."Document No.";
                            TempJobLedgerEntryBuffer."Ledger Entry No." := SalesInvoiceLine."Line No.";
                            TempJobLedgerEntryBuffer."Document Date" := UsageDataBilling."Charge Start Date";
                            TempJobLedgerEntryBuffer."Posting Date" := UsageDataBilling."Charge End Date";
                            TempJobLedgerEntryBuffer.Quantity := UsageDataBilling.Quantity;
                            TempJobLedgerEntryBuffer.Description := UsageDataBilling."Subscription Description";
                            TempJobLedgerEntryBuffer."External Document No." := UsageDataBilling."Subscription Contract No.";
                            TempJobLedgerEntryBuffer."Resource Group No." := SalesInvoiceHeader."Sell-to Customer No.";
                            if SalesInvoiceHeader."Sub. Contract Detail Overview" = Enum::"Contract Detail Overview"::Complete then begin
                                TempJobLedgerEntryBuffer."Unit Price" := UsageDataBilling."Unit Price";
                                TempJobLedgerEntryBuffer."Currency Code" := SalesInvoiceHeader."Currency Code";
                                TempJobLedgerEntryBuffer."Line Amount" := UsageDataBilling.Amount;
                            end;
                            TempJobLedgerEntryBuffer.Insert(false);
                        until UsageDataBilling.Next() = 0;
                end else begin
                    BillingLineArchive.SetRange("Document Type", BillingLineArchive."Document Type"::Invoice);
                    BillingLineArchive.SetRange("Document No.", SalesInvoiceHeader."No.");
                    BillingLineArchive.SetRange("Subscription Contract No.", SalesInvoiceLine."Subscription Contract No.");
                    BillingLineArchive.SetRange("Subscription Contract Line No.", SalesInvoiceLine."Subscription Contract Line No.");
                    BillingLineArchive.SetAutoCalcFields("Subscription Description");
                    if BillingLineArchive.FindSet() then
                        repeat
                            EntryNo += 1;
                            TempJobLedgerEntryBuffer.Init();
                            TempJobLedgerEntryBuffer."Entry No." := EntryNo;
                            TempJobLedgerEntryBuffer."Document No." := SalesInvoiceLine."Document No.";
                            TempJobLedgerEntryBuffer."Ledger Entry No." := SalesInvoiceLine."Line No.";
                            TempJobLedgerEntryBuffer."Document Date" := BillingLineArchive."Billing from";
                            TempJobLedgerEntryBuffer."Posting Date" := BillingLineArchive."Billing to";
                            TempJobLedgerEntryBuffer.Quantity := BillingLineArchive."Service Object Quantity";
                            TempJobLedgerEntryBuffer.Description := BillingLineArchive."Subscription Description";
                            TempJobLedgerEntryBuffer."External Document No." := BillingLineArchive."Subscription Contract No.";
                            CustomerContract.Get(BillingLineArchive."Subscription Contract No.");
                            TempJobLedgerEntryBuffer."Resource Group No." := CustomerContract."Sell-to Customer No.";
                            if SalesInvoiceHeader."Sub. Contract Detail Overview" = Enum::"Contract Detail Overview"::Complete then begin
                                TempJobLedgerEntryBuffer."Unit Price" := BillingLineArchive."Unit Price";
                                TempJobLedgerEntryBuffer."Line Discount %" := BillingLineArchive."Discount %";
                                TempJobLedgerEntryBuffer."Currency Code" := SalesInvoiceHeader."Currency Code";
                                if TempJobLedgerEntryBuffer."Currency Code" <> '' then
                                    Currency.Get(TempJobLedgerEntryBuffer."Currency Code");
                                Currency.InitRoundingPrecision();
                                TempJobLedgerEntryBuffer."Line Discount Amount" := Round(BillingLineArchive.Amount * BillingLineArchive."Discount %" / 100, Currency."Amount Rounding Precision");
                                TempJobLedgerEntryBuffer."Line Amount" := BillingLineArchive.Amount;
                            end;
                            TempJobLedgerEntryBuffer.Insert(false);
                        until BillingLineArchive.Next() = 0;
                end;
            until SalesInvoiceLine.Next() = 0;

        TempJobLedgerEntryBuffer.SetRange("Document No.", SalesInvoiceLine."Document No.");
        TempJobLedgerEntryBuffer.CalcSums("Unit Price", "Line Discount %", "Line Discount Amount", "Line Amount");
        if TempJobLedgerEntryBuffer."Unit Price" <> 0 then
            ColumnHeaders[1] := TempJobLedgerEntryBuffer.FieldCaption("Unit Price");
        if TempJobLedgerEntryBuffer."Line Discount %" <> 0 then
            ColumnHeaders[2] := DiscountPercentLbl;
        if TempJobLedgerEntryBuffer."Line Discount Amount" <> 0 then
            ColumnHeaders[3] := DiscountAmountLbl;
        if TempJobLedgerEntryBuffer."Line Amount" <> 0 then
            ColumnHeaders[4] := AmountLbl;
        TempJobLedgerEntryBuffer.Reset();
    end;

    internal procedure FormatContractBillingDetails(var TempContractBillingDetailsBuffer: Record "Job Ledger Entry"; var SalesInvoiceLine: Record "Sales Invoice Line")
    begin
        if not SalesInvoiceLine.Get(TempContractBillingDetailsBuffer."Document No.", TempContractBillingDetailsBuffer."Ledger Entry No.") then
            SalesInvoiceLine.Init();
    end;

    var
        DiscountPercentLbl: Label 'Discount %';
        DiscountAmountLbl: Label 'Discount';
        AmountLbl: Label 'Amount';
}