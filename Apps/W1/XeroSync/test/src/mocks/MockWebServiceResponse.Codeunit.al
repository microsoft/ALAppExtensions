codeunit 130307 "XS Mock Web Service Response"
{
    var
        LibraryJson: Codeunit "XS Library - JSON";
        XSLibraryRandom: Codeunit "XS Library - Random";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"XS Communicate With Xero", 'OnBeforeCommunicateWithXero', '', false, false)]
    local procedure MockWebServiceCall(EntityDataJsonTxt: Text; var JsonEntities: JsonArray; var Handled: Boolean)
    var
        SyncSetup: Record "Sync Setup";
        WebServiceMockClass: Codeunit "XS Web Service Mock Class";
    begin
        SyncSetup.GetSingleInstance();
        if not SyncSetup."XS In Test Mode" then exit;
        Handled := true;
        case WebServiceMockClass.GetMockWebServiceChangeType() of
            WebServiceMockClass.MockCreationsCode():
                JsonEntities := MockCreations();
            WebServiceMockClass.MockUpdatesCode():
                JsonEntities := MockUpdates();
            WebServiceMockClass.MockDeletionsCode():
                JsonEntities := MockDeletions();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"XS Communicate With Xero", 'OnAfterCommunicateWithXero', '', false, false)]
    local procedure SetResponseStatusCode(var IsSuccessStatusCode: Boolean)
    var
        SyncSetup: Record "Sync Setup";
    begin
        SyncSetup.GetSingleInstance();
        if not SyncSetup."XS In Test Mode" then exit;
        IsSuccessStatusCode := true;
    end;

    local procedure MockCreations() ResultJsonArray: JsonArray;
    var
        WebServiceMockClass: Codeunit "XS Web Service Mock Class";
    begin
        case WebServiceMockClass.GetWebServiceResponseContentType() of
            WebServiceMockClass.MockItemsResponse():
                LibraryJson.CreateFullJsonResponseItemXero(XSLibraryRandom.CreateGUID(), ResultJsonArray);
            WebServiceMockClass.MockCustomersResponse():
                LibraryJson.CreateFullJsonResponseCustomerXero(XSLibraryRandom.CreateGUID(), ResultJsonArray);
            WebServiceMockClass.MockSalesInvoiceResponse():
                LibraryJson.CreateJsonResponseSalesInvoiceXero(XSLibraryRandom.CreateGUID(), ResultJsonArray);
        end;
        exit(ResultJsonArray);
    end;

    local procedure MockUpdates() ResultJsonArray: JsonArray;
    var
        SyncMapping: Record "Sync Mapping";
        WebServiceMockClass: Codeunit "XS Web Service Mock Class";
    begin
        SyncMapping.FindLast();
        case WebServiceMockClass.GetWebServiceResponseContentType() of
            WebServiceMockClass.MockItemsResponse():
                LibraryJson.CreateFullJsonResponseItemXero(SyncMapping."External Id", ResultJsonArray);
            WebServiceMockClass.MockCustomersResponse():
                LibraryJson.CreateFullJsonResponseCustomerXero(SyncMapping."External Id", ResultJsonArray);
        end;
        exit(ResultJsonArray);
    end;

    local procedure MockDeletions() ResultJsonArray: JsonArray;
    var
        EmptyResponseArray: JsonArray;
    begin
        ResultJsonArray := EmptyResponseArray; //Meaning that (all) data is deleted from Xero
        exit(ResultJsonArray);
    end;
}