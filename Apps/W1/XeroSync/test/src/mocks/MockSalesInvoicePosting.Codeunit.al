codeunit 130306 "XS Mock Sales Invoice Posting"
{
    EventSubscriberInstance = Manual;

    var
        _PostedSalesInvoiceRecordId: RecordId;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnAfterPostSalesDocGetPostedSalesInvoiceRecord(SalesInvHdrNo: Code[20])
    var
        SyncSetup: Record "Sync Setup";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SyncSetup.GetSingleInstance();
        if not SyncSetup."XS In Test Mode" then exit;
        SalesInvoiceHeader.Get(SalesInvHdrNo);
        SetPostedSalesInvoiceRedordId(SalesInvoiceHeader.RecordId());
    end;

    local procedure SetPostedSalesInvoiceRedordId(SalesInvoiceHeaderRecordId: RecordId)
    begin
        _PostedSalesInvoiceRecordId := SalesInvoiceHeaderRecordId;
    end;

    procedure GetPostedSalesInvoiceRecordId(var PostedSalesInvoiceRedordId: RecordId)
    begin
        PostedSalesInvoiceRedordId := _PostedSalesInvoiceRecordId;
    end;
}