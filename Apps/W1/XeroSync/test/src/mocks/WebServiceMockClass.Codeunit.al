codeunit 130304 "XS Web Service Mock Class"
{
    SingleInstance = true;

    var
        MockWebServiceType: Code[12];
        MockWebServiceResponseContentType: Code[12];
        MockNumberOfResponsesRequired: Integer;

    procedure SetMockWebServiceChangeType(WebServiceType: Code[12])
    begin
        MockWebServiceType := WebServiceType;
    end;

    procedure GetMockWebServiceChangeType(): Code[12]
    begin
        exit(MockWebServiceType);
    end;

    procedure SetNumberOfResponsesRequired(NumberOfResponsesRequired: Integer)
    begin
        MockNumberOfResponsesRequired := NumberOfResponsesRequired;
    end;

    procedure GetNumberOfResponsesRequired(): Integer
    begin
        exit(MockNumberOfResponsesRequired);
    end;

    procedure SetWebServiceResponseContentType(WebServiceResponseContentType: Code[12])
    begin
        MockWebServiceResponseContentType := WebServiceResponseContentType;
    end;

    procedure GetWebServiceResponseContentType(): Code[12]
    begin
        exit(MockWebServiceResponseContentType);
    end;

    procedure MockCreationsCode(): Code[12]
    begin
        exit('CREATIONS');
    end;

    procedure MockUpdatesCode(): Code[12]
    begin
        exit('UPDATES');
    end;

    procedure MockDeletionsCode(): Code[12]
    begin
        exit('DELETIONS');
    end;

    procedure MockItemsResponse(): Code[12]
    begin
        exit('ITEMS');
    end;

    procedure MockCustomersResponse(): Code[12]
    begin
        exit('CUSTOMERS');
    end;

    procedure MockSalesInvoiceResponse(): Code[12]
    begin
        exit('SALESINVOICE');
    end;
}