namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Finance.Currency;

codeunit 8064 "Contract Billing Printout"
{
    Access = Internal;
    procedure FillContractBillingDetailsBufferFromSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header"; var TempJobLedgerEntryBuffer: Record "Job Ledger Entry"; var ColumnHeaders: array[5] of Text)
    var
        BillingLineArchive: Record "Billing Line Archive";
        SalesInvoiceLine: Record "Sales Invoice Line";
        CustomerContract: Record "Customer Contract";
        Currency: Record Currency;
        UsageDataBilling: Record "Usage Data Billing";
        ServiceCommitment: Record "Service Commitment";
        SalesDocuments: Codeunit "Sales Documents";
        EntryNo: Integer;
    begin
        if not SalesInvoiceHeader."Recurring Billing" then
            exit;

        if SalesInvoiceHeader."Contract Detail Overview" = Enum::"Contract Detail Overview"::None then
            exit;

        SalesDocuments.MoveBillingLineToBillingLineArchiveForPostingPreview(SalesInvoiceHeader);

        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.SetFilter("Contract No.", '<>%1', '');
        SalesInvoiceLine.SetFilter("Contract Line No.", '<>%1', 0);
        if SalesInvoiceLine.FindSet() then
            repeat
                ServiceCommitment.SetRange("Contract No.", SalesInvoiceLine."Contract No.");
                ServiceCommitment.SetRange("Contract Line No.", SalesInvoiceLine."Contract Line No.");
                if ServiceCommitment.FindFirst() and ServiceCommitment."Usage Based Billing" then begin
                    UsageDataBilling.SetRange("Document Type", UsageDataBilling."Document Type"::"Posted Invoice");
                    UsageDataBilling.SetRange("Document No.", SalesInvoiceHeader."No.");
                    UsageDataBilling.SetRange("Contract No.", SalesInvoiceLine."Contract No.");
                    UsageDataBilling.SetRange("Contract Line No.", SalesInvoiceLine."Contract Line No.");
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
                            TempJobLedgerEntryBuffer.Description := UsageDataBilling."Service Object Description";
                            TempJobLedgerEntryBuffer."External Document No." := UsageDataBilling."Contract No.";
                            TempJobLedgerEntryBuffer."Resource Group No." := SalesInvoiceHeader."Sell-to Customer No.";
                            if SalesInvoiceHeader."Contract Detail Overview" = Enum::"Contract Detail Overview"::Complete then begin
                                TempJobLedgerEntryBuffer."Unit Price" := UsageDataBilling."Unit Price";
                                TempJobLedgerEntryBuffer."Currency Code" := SalesInvoiceHeader."Currency Code";
                                TempJobLedgerEntryBuffer."Line Amount" := UsageDataBilling.Amount;
                            end;
                            TempJobLedgerEntryBuffer.Insert(false);
                        until UsageDataBilling.Next() = 0;
                end else begin
                    BillingLineArchive.SetRange("Document Type", BillingLineArchive."Document Type"::Invoice);
                    BillingLineArchive.SetRange("Document No.", SalesInvoiceHeader."No.");
                    BillingLineArchive.SetRange("Contract No.", SalesInvoiceLine."Contract No.");
                    BillingLineArchive.SetRange("Contract Line No.", SalesInvoiceLine."Contract Line No.");
                    BillingLineArchive.SetAutoCalcFields("Service Object Description");
                    if BillingLineArchive.FindSet() then
                        repeat
                            EntryNo += 1;
                            TempJobLedgerEntryBuffer.Init();
                            TempJobLedgerEntryBuffer."Entry No." := EntryNo;
                            TempJobLedgerEntryBuffer."Document No." := SalesInvoiceLine."Document No.";
                            TempJobLedgerEntryBuffer."Ledger Entry No." := SalesInvoiceLine."Line No.";
                            TempJobLedgerEntryBuffer."Document Date" := BillingLineArchive."Billing from";
                            TempJobLedgerEntryBuffer."Posting Date" := BillingLineArchive."Billing to";
                            TempJobLedgerEntryBuffer.Quantity := BillingLineArchive."Service Obj. Quantity Decimal";
                            TempJobLedgerEntryBuffer.Description := BillingLineArchive."Service Object Description";
                            TempJobLedgerEntryBuffer."External Document No." := BillingLineArchive."Contract No.";
                            CustomerContract.Get(BillingLineArchive."Contract No.");
                            TempJobLedgerEntryBuffer."Resource Group No." := CustomerContract."Sell-to Customer No.";
                            if SalesInvoiceHeader."Contract Detail Overview" = Enum::"Contract Detail Overview"::Complete then begin
                                TempJobLedgerEntryBuffer."Unit Price" := BillingLineArchive."Unit Price";
                                TempJobLedgerEntryBuffer."Line Discount %" := BillingLineArchive."Discount %";
                                TempJobLedgerEntryBuffer."Currency Code" := SalesInvoiceHeader."Currency Code";
                                if TempJobLedgerEntryBuffer."Currency Code" <> '' then
                                    Currency.Get(TempJobLedgerEntryBuffer."Currency Code");
                                Currency.InitRoundingPrecision();
                                TempJobLedgerEntryBuffer."Line Discount Amount" := Round(BillingLineArchive."Service Amount" * BillingLineArchive."Discount %" / 100, Currency."Amount Rounding Precision");
                                TempJobLedgerEntryBuffer."Line Amount" := BillingLineArchive."Service Amount";
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

    procedure FormatContractBillingDetails(var TempContractBillingDetailsBuffer: Record "Job Ledger Entry"; var SalesInvoiceLine: Record "Sales Invoice Line")
    begin
        if not SalesInvoiceLine.Get(TempContractBillingDetailsBuffer."Document No.", TempContractBillingDetailsBuffer."Ledger Entry No.") then
            SalesInvoiceLine.Init();
    end;

    var
        DiscountPercentLbl: Label 'Discount %';
        DiscountAmountLbl: Label 'Discount';
        AmountLbl: Label 'Amount';
}