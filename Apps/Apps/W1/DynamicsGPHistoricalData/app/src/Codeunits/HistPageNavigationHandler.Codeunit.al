namespace Microsoft.DataMigration.GP.HistoricalData;

codeunit 40901 "Hist. Page Navigation Handler"
{
    procedure NavigateToTransactionDetail(HistGenJournalLine: Record "Hist. Gen. Journal Line")
    var
        Handled: Boolean;
    begin
        OnHistoricalNavigateToTransactionDetail(HistGenJournalLine, Handled);
        if Handled then
            exit;

        case HistGenJournalLine."Source Type" of
            "Hist. Source Type"::Receivables:
                OpenSalesTrxPage(HistGenJournalLine);
            "Hist. Source Type"::Payables:
                OpenPayablesTrxPage(HistGenJournalLine);
            "Hist. Source Type"::Inventory:
                OpenInventoryTrxPage(HistGenJournalLine);
            "Hist. Source Type"::"Purchase Receivables":
                OpenPurchaseRecvPage(HistGenJournalLine);
            "Hist. Source Type"::Other:
                Message(NotMigratedMsg);
        end;
    end;

    procedure NavigateToCustomerSalesTransactions(CustomerNo: Code[20])
    var
        HistSalesTrxHeaders: Page "Hist. Sales Trx. Headers";
        Handled: Boolean;
    begin
        OnHistoricalNavigateToCustomerSalesTransactions(CustomerNo, Handled);
        if Handled then
            exit;

        HistSalesTrxHeaders.SetFilterCustomerNo(CustomerNo);
        HistSalesTrxHeaders.Run();
    end;

    procedure NavigateToCustomerReceivablesDocuments(CustomerNo: Code[20])
    var
        HistReceivablesDocuments: Page "Hist. Receivables Documents";
        Handled: Boolean;
    begin
        OnHistoricalNavigateToCustomerReceivablesDocuments(CustomerNo, Handled);
        if Handled then
            exit;

        HistReceivablesDocuments.SetFilterCustomerNo(CustomerNo);
        HistReceivablesDocuments.Run();
    end;

    procedure NavigateToVendorPayablesDocuments(VendorNo: Code[20])
    var
        HistPayablesDocuments: Page "Hist. Payables Documents";
        Handled: Boolean;
    begin
        OnHistoricalNavigateToVendorPayablesDocuments(VendorNo, Handled);
        if Handled then
            exit;

        HistPayablesDocuments.SetFilterVendorNo(VendorNo);
        HistPayablesDocuments.Run();
    end;

    procedure NavigateToVendorPurchaseRecvTransactions(VendorNo: Code[20])
    var
        HistPurchaseRecvHeaders: Page "Hist. Purchase Recv. Headers";
        Handled: Boolean;
    begin
        OnHistoricalNavigateToVendorPurchaseRecvTransactions(VendorNo, Handled);
        if Handled then
            exit;

        HistPurchaseRecvHeaders.SetFilterVendorNo(VendorNo);
        HistPurchaseRecvHeaders.Run();
    end;

    local procedure OpenSalesTrxPage(HistGenJournalLine: Record "Hist. Gen. Journal Line")
    var
        HistSalesTrxHeader: Record "Hist. Sales Trx. Header";
        HistReceivablesDocument: Record "Hist. Receivables Document";
        HistSalesTrx: Page "Hist. Sales Trx.";
        HistReceivablesDocumentPage: Page "Hist. Receivables Document";
    begin
        HistSalesTrxHeader.SetRange("Customer No.", HistGenJournalLine."Source No.");
        HistSalesTrxHeader.SetRange("No.", HistGenJournalLine."Orig. Document No.");

        if HistSalesTrxHeader.FindFirst() then begin
            HistSalesTrx.SetRecord(HistSalesTrxHeader);
            HistSalesTrx.Run();
        end else begin
            HistReceivablesDocument.SetRange("Customer No.", HistGenJournalLine."Source No.");
            HistReceivablesDocument.SetRange("Document No.", HistGenJournalLine."Orig. Document No.");

            if HistReceivablesDocument.FindFirst() then begin
                HistReceivablesDocumentPage.SetRecord(HistReceivablesDocument);
                HistReceivablesDocumentPage.Run()
            end else
                Message(CouldNotFindDetailMsg);
        end;
    end;

    local procedure OpenPayablesTrxPage(HistGenJournalLine: Record "Hist. Gen. Journal Line")
    var
        HistPayablesDocument: Record "Hist. Payables Document";
        HistPayablesDocumentPage: Page "Hist. Payables Document";
        HistPayablesDocumentsPage: Page "Hist. Payables Documents";
    begin
        HistPayablesDocument.SetRange("Vendor No.", HistGenJournalLine."Source No.");
        HistPayablesDocument.SetRange("Document No.", HistGenJournalLine."Orig. Document No.");

        if HistPayablesDocument.FindFirst() then begin
            HistPayablesDocumentPage.SetRecord(HistPayablesDocument);
            HistPayablesDocumentPage.Run()
        end else begin
            Clear(HistPayablesDocument);
            HistPayablesDocument.SetRange("Audit Code", HistGenJournalLine."Orig. Trx. Source No.");
            if not HistPayablesDocument.IsEmpty() then begin
                HistPayablesDocumentsPage.SetFilterAuditCode(HistGenJournalLine."Orig. Trx. Source No.");
                HistPayablesDocumentsPage.Run();
            end else
                Message(CouldNotFindDetailMsg);
        end
    end;

    local procedure OpenInventoryTrxPage(HistGenJournalLine: Record "Hist. Gen. Journal Line")
    var
        HistInventoryTrxHeader: Record "Hist. Inventory Trx. Header";
        HistInventoryTrxPage: Page "Hist. Inventory Trx.";
    begin
        HistInventoryTrxHeader.SetRange("Audit Code", HistGenJournalLine."Audit Code");
        HistInventoryTrxHeader.SetRange("Document No.", HistGenJournalLine."Orig. Document No.");

        if HistInventoryTrxHeader.FindFirst() then begin
            HistInventoryTrxPage.SetRecord(HistInventoryTrxHeader);
            HistInventoryTrxPage.Run();
        end else
            Message(CouldNotFindDetailMsg);
    end;

    local procedure OpenPurchaseRecvPage(HistGenJournalLine: Record "Hist. Gen. Journal Line")
    var
        HistPurchaseRecvHeader: Record "Hist. Purchase Recv. Header";
        HistPurchaseRecvHeaderPage: Page "Hist. Purchase Recv.";
    begin
        HistPurchaseRecvHeader.SetRange("Audit Code", HistGenJournalLine."Orig. Trx. Source No.");
        HistPurchaseRecvHeader.SetRange("Receipt No.", HistGenJournalLine."Orig. Document No.");

        if HistPurchaseRecvHeader.FindFirst() then begin
            HistPurchaseRecvHeaderPage.SetRecord(HistPurchaseRecvHeader);
            HistPurchaseRecvHeaderPage.Run();
        end else
            Message(CouldNotFindDetailMsg);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHistoricalNavigateToTransactionDetail(HistGenJournalLine: Record "Hist. Gen. Journal Line"; var Handled: Boolean)
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnHistoricalNavigateToCustomerSalesTransactions(CustomerNo: Code[20]; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHistoricalNavigateToCustomerReceivablesDocuments(CustomerNo: Code[20]; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHistoricalNavigateToVendorPayablesDocuments(VendorNo: Code[20]; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnHistoricalNavigateToVendorPurchaseRecvTransactions(VendorNo: Code[20]; var Handled: Boolean)
    begin
    end;

    var
        NotMigratedMsg: Label 'Details for this transaction were not migrated.';
        CouldNotFindDetailMsg: Label 'Could not find details for this transaction.';
}