namespace Microsoft.Integration.ExternalEvents;

using System.Integration;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Posting;

codeunit 38502 "AR External Events"
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
        APIId: Guid;
        Url: Text[250];
        WebClientUrl: Text[250];
        SalesInvoiceApiUrlTok: Label 'v2.0/companies(%1)/salesInvoices(%2)', Locked = true;
        SalesCreditMemoApiUrlTok: Label 'v2.0/companies(%1)/salesCreditMemos(%2)', Locked = true;
        SalesShipmentApiUrlTok: Label 'v2.0/companies(%1)/salesShipments(%2)', Locked = true;
    begin
        if PreviewMode then
            exit;
        if SalesInvoiceHeader."No." <> '' then begin
            if not IsNullGuid(SalesInvoiceHeader."Draft Invoice SystemId") then
                APIId := SalesInvoiceHeader."Draft Invoice SystemId"
            else
                APIId := SalesInvoiceHeader.SystemId;
            Url := ExternalEventsHelper.CreateLink(CopyStr(SalesInvoiceApiUrlTok, 1, 250), APIId);
            WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Posted Sales Invoice", SalesInvoiceHeader), 1, MaxStrLen(WebClientUrl));
            SalesInvoicePosted(APIId, SalesInvoiceHeader.SystemId, Url, WebClientUrl);
        end;
        if SalesCrMemoHeader."No." <> '' then begin
            if not IsNullGuid(SalesCrMemoHeader."Draft Cr. Memo SystemId") then
                APIId := SalesCrMemoHeader."Draft Cr. Memo SystemId"
            else
                APIId := SalesCrMemoHeader.SystemId;
            Url := ExternalEventsHelper.CreateLink(CopyStr(SalesCreditMemoApiUrlTok, 1, 250), APIId);
            WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Posted Sales Credit Memo", SalesCrMemoHeader), 1, MaxStrLen(WebClientUrl));
            SalesCreditMemoPosted(APIId, SalesCrMemoHeader.SystemId, Url, WebClientUrl);
        end;
        if SalesShipmentHeader."No." <> '' then begin
            Url := ExternalEventsHelper.CreateLink(CopyStr(SalesShipmentApiUrlTok, 1, 250), SalesShipmentHeader.SystemId);
            WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Posted Sales Shipment", SalesShipmentHeader), 1, MaxStrLen(WebClientUrl));
            SalesShipmentPosted(SalesShipmentHeader.SystemId, Url, WebClientUrl);
        end;
    end;

    [ExternalBusinessEvent('SalesInvoicePosted', 'Sales invoice posted ', 'This business event is triggered when a sales invoice is posted as part of the Quote to Cash process.', EventCategory::"Accounts Receivable", '1.0')]
    procedure SalesInvoicePosted(SalesInvoiceAPIId: Guid; SalesInvoiceSystemId: Guid; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;

    [ExternalBusinessEvent('SalesCreditMemoPosted', 'Sales credit memo posted', 'This business event is triggered when a sales credit memo is posted.', EventCategory::"Accounts Receivable", '1.0')]
    procedure SalesCreditMemoPosted(SalesCreditMemoAPIId: Guid; SalesCreditMemoSystemId: Guid; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;

    [ExternalBusinessEvent('SalesShipmentPosted', 'Sales shipment posted', 'This business event is triggered when goods from a sales order are shipped by the internal warehouse/external logistics company. This can trigger Finance Department to post a sales invoice.', EventCategory::"Accounts Receivable", '1.0')]
    procedure SalesShipmentPosted(SalesShipmentId: Guid; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer", 'OnAfterValidateEvent', 'Blocked', false, false)]
    local procedure OnAfterValidateCustomerBlocked(var Rec: Record Customer)
    var
        Blocked: enum "Customer Blocked";
        Url: Text[250];
        WebClientUrl: Text[250];
        CustomerApiUrlTok: Label 'v2.0/companies(%1)/customers(%2)', Locked = true;
    begin
        Url := ExternalEventsHelper.CreateLink(CopyStr(CustomerApiUrlTok, 1, 250), Rec.SystemId);
        WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Customer Card", Rec), 1, MaxStrLen(WebClientUrl));

        if Rec.Blocked <> Blocked::" " then
            CustomerBlocked(Rec.SystemId, Rec.Blocked, Url, WebClientUrl)
        else
            CustomerUnBlocked(Rec.SystemId, Rec.Blocked, Url, WebClientUrl);
    end;

    [ExternalBusinessEvent('CustomerBlocked', 'Customer blocked', 'This business event is triggered when a customer is blocked for shipping/invoicing.', EventCategory::"Accounts Receivable", '1.0')]
    local procedure CustomerBlocked(CustomerId: Guid; Blocked: enum "Customer Blocked"; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;

    [ExternalBusinessEvent('CustomerUnBlocked', 'Customer unblocked', 'This business event is triggered when a customer is unblocked for shipping/invoicing.', EventCategory::"Accounts Receivable", '1.0')]
    local procedure CustomerUnBlocked(CustomerId: Guid; Blocked: enum "Customer Blocked"; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterCustLedgEntryInsert', '', true, true)]
    local procedure OnAfterCustLedgEntryInsert(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; DtldLedgEntryInserted: Boolean; PreviewMode: Boolean)
    var
        Customer: Record Customer;
        Url: Text[250];
        WebClientUrl: Text[250];
        CustomerApiUrlTok: Label 'v2.0/companies(%1)/customers(%2)', Locked = true;
    begin
        if not Customer.Get(CustLedgerEntry."Customer No.") then
            exit;
        if PreviewMode then
            exit;
        Url := ExternalEventsHelper.CreateLink(CopyStr(CustomerApiUrlTok, 1, 250), Customer.SystemId);
        WebClientUrl := CopyStr(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Customer Card", Customer), 1, MaxStrLen(WebClientUrl));
        if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Payment then
            EventSalesPaymentPosted(Customer.SystemId, Url, WebClientUrl);
        if Customer."Credit Limit (LCY)" <= 0 then
            exit;
        Customer.CalcFields("Balance (LCY)");
        if Customer."Balance (LCY)" > Customer."Credit Limit (LCY)" then
            EventSalesCreditLimitExceeded(Customer.SystemId, Url, WebClientUrl)
    end;

    [ExternalBusinessEvent('SalesPaymentPosted', 'Sales payment posted', 'This business event is triggered when a customer payment is posted as part of the Quote to Cash process.', EventCategory::"Accounts Receivable", '1.0')]
    local procedure EventSalesPaymentPosted(CustomerId: Guid; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;

    [ExternalBusinessEvent('SalesCreditLimitExceeded', 'Sales credit limit exceeded', 'This business event is triggered when the credit limit for a customer is exceeded due to a posted sales invoice/changed credit limit for that customer.', EventCategory::"Accounts Receivable", '1.0')]
    local procedure EventSalesCreditLimitExceeded(CustomerId: Guid; Url: Text[250]; WebClientUrl: Text[250])
    begin
    end;
}