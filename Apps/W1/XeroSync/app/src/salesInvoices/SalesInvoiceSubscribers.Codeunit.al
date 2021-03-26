codeunit 2458 "XS Sales Invoice Subscribers"
{
    var
        ChangeType: Option Create,Update,Delete," ";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, false)]
    local procedure OnSalesInvoicePosted(SalesInvHdrNo: Code[20])
    var
        SyncChange: Record "Sync Change";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SyncSetup: Record "Sync Setup";
        RecRef: RecordRef;
    begin
        SyncSetup.GetSingleInstance();
        if not SyncSetup."XS Enabled" then
            exit;
        if SalesInvHdrNo = '' then
            exit;

        SalesInvoiceHeader.SetRange("No.", SalesInvHdrNo);
        if SalesInvoiceHeader.FindFirst() then begin
            RecRef.GetTable(SalesInvoiceHeader);
            SyncChange.QueueOutgoingChangeForEntity(RecRef, ChangeType::" ");
        end;
    end;
}