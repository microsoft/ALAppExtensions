Codeunit 38502 "AR External Events"
{
    var
        ExternalEventsHelper: Codeunit "External Events Helper";
        EventCategory: Enum EventCategory;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterFinalizePosting', '', true, true)]
    local procedure OnAfterFinalizePostingSalesInvoice(
        var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header";
        var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        var ReturnReceiptHeader: Record "Return Receipt Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    var
        Url: Text[250];
        SalesInvoiceApiUrlTok: Label 'v2.0/companies(%1)/salesInvoices(%2)', Locked = true;
        SalesCreditMemoApiUrlTok: Label 'v2.0/companies(%1)/salesCreditMemos(%2)', Locked = true;
        SalesShipmentApiUrlTok: Label 'v2.0/companies(%1)/salesShipments(%2)', Locked = true;
    begin
        if SalesInvoiceHeader."No." <> '' then begin
            Url := ExternalEventsHelper.CreateLink(CopyStr(SalesInvoiceApiUrlTok, 1, 250), SalesInvoiceHeader.SystemId);
            SalesInvoicePosted(SalesInvoiceHeader.SystemId, Url);
        end;
        if SalesCrMemoHeader."No." <> '' then begin
            Url := ExternalEventsHelper.CreateLink(CopyStr(SalesCreditMemoApiUrlTok, 1, 250), SalesCrMemoHeader.SystemId);
            SalesCreditMemoPosted(SalesCrMemoHeader.SystemId, Url);
        end;
        if SalesShipmentHeader."No." <> '' then begin
            Url := ExternalEventsHelper.CreateLink(CopyStr(SalesShipmentApiUrlTok, 1, 250), SalesShipmentHeader.SystemId);
            SalesShipmentPosted(SalesShipmentHeader.SystemId, Url);
        end;
    end;

    [ExternalBusinessEvent('SalesInvoicePosted', 'Sales invoice posted ', 'This business event is triggered when a sales invoice is posted as part of the Quote to Cash process.', EventCategory::"Accounts Receivable")]
    procedure SalesInvoicePosted(SalesInvoiceId: Guid; Url: text[250])
    begin
    end;

    [ExternalBusinessEvent('SalesCreditMemoPosted', 'Sales credit memo posted', 'This business event is triggered when a sales credit memo is posted.', EventCategory::"Accounts Receivable")]
    procedure SalesCreditMemoPosted(SalesCreditMemoId: Guid; Url: text[250])
    begin
    end;

    [ExternalBusinessEvent('SalesShipmentPosted', 'Sales shipment posted', 'This business event is triggered when goods from a sales order are shipped by the internal warehouse/external logistics company. This can trigger Finance Department to post a sales invoice.', EventCategory::"Accounts Receivable")]
    procedure SalesShipmentPosted(SalesShipmentId: Guid; Url: text[250])
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer", 'OnAfterValidateEvent', 'Blocked', false, false)]
    local procedure OnAfterValidateCustomerBlocked(var Rec: Record Customer)
    var
        Blocked: enum "Customer Blocked";
        Url: Text[250];
        CustomerApiUrlTok: Label 'v2.0/companies(%1)/customers(%2)', Locked = true;
    begin
        Url := ExternalEventsHelper.CreateLink(CopyStr(CustomerApiUrlTok, 1, 250), Rec.SystemId);

        if Rec.Blocked <> Blocked::" " then
            CustomerBlocked(Rec.SystemId, Rec.Blocked, Url)
        else
            CustomerUnBlocked(Rec.SystemId, Rec.Blocked, Url);
    end;

    [ExternalBusinessEvent('CustomerBlocked', 'Customer blocked', 'This business event is triggered when a customer is blocked for shipping/invoicing.', EventCategory::"Accounts Receivable")]
    local procedure CustomerBlocked(CustomerId: Guid; Blocked: enum "Customer Blocked"; Url: text[250])
    begin
    end;

    [ExternalBusinessEvent('CustomerUnBlocked', 'Customer unblocked', 'This business event is triggered when a customer is unblocked for shipping/invoicing.', EventCategory::"Accounts Receivable")]
    local procedure CustomerUnBlocked(CustomerId: Guid; Blocked: enum "Customer Blocked"; Url: text[250])
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterCustLedgEntryInsert', '', true, true)]
    local procedure OnAfterCustLedgEntryInsert(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; DtldLedgEntryInserted: Boolean)
    var
        Customer: Record Customer;
        Url: Text[250];
        CustomerApiUrlTok: Label 'v2.0/companies(%1)/customers(%2)', Locked = true;
    begin
        if not Customer.get(CustLedgerEntry."Customer No.") then
            exit;
        Url := ExternalEventsHelper.CreateLink(CopyStr(CustomerApiUrlTok, 1, 250), Customer.SystemId);
        if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Payment then
            EventSalesPaymentPosted(Customer.SystemId, Url);
        if Customer."Credit Limit (LCY)" <= 0 then
            exit;
        Customer.CalcFields("Balance (LCY)");
        if Customer."Balance (LCY)" > Customer."Credit Limit (LCY)" then
            EventSalesCreditLimitExceeded(Customer.SystemId, Url)
    end;

    [ExternalBusinessEvent('SalesPaymentPosted', 'Sales payment posted', 'This business event is triggered when a customer payment is posted as part of the Quote to Cash process.', EventCategory::"Accounts Receivable")]
    local procedure EventSalesPaymentPosted(CustomerId: Guid; Url: text[250])
    begin
    end;

    [ExternalBusinessEvent('SalesCreditLimitExceeded', 'Sales credit limit exceeded', 'This business event is triggered when the credit limit for a customer is exceeded due to a posted sales invoice/changed credit limit for that customer.', EventCategory::"Accounts Receivable")]
    local procedure EventSalesCreditLimitExceeded(CustomerId: Guid; Url: text[250])
    begin
    end;
}