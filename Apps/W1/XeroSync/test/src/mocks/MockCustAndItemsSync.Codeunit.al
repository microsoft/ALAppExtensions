codeunit 130305 "XS Mock Cust. And Items Sync"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"XS Push Sales Inv. To Xero", 'OnBeforePushSalesInvoiceToXero', '', false, false)]
    local procedure MockSyncingCustomersAndItems()
    var
        SyncSetup: Record "Sync Setup";
        SyncChange: Record "Sync Change";
    begin
        SyncSetup.GetSingleInstance();
        if not SyncSetup."XS In Test Mode" then exit;
        SyncChange.FindSet();
        repeat
            if SyncChange."XS NAV Entity ID" <> Database::"Sales Invoice Header" then
                SyncChange.Delete();
        until SyncChange.Next() = 0;
        SetMockingSettings();
    end;

    local procedure SetMockingSettings()
    var
        WebServiceMockClass: Codeunit "XS Web Service Mock Class";
    begin
        WebServiceMockClass.SetMockWebServiceChangeType(WebServiceMockClass.MockCreationsCode());
        WebServiceMockClass.SetNumberOfResponsesRequired(1);
        WebServiceMockClass.SetWebServiceResponseContentType(WebServiceMockClass.MockSalesInvoiceResponse());
    end;
}