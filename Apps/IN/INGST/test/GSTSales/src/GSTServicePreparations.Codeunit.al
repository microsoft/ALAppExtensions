codeunit 18197 "GST Service Preparations"
{
    Subtype = Test;

    var
        LibraryService: Codeunit "Library - Service";
        LibraryGST: Codeunit "Library GST";
        GSTServiceOrderErr: Label 'GST Related Fields not Validated on Service Order';
        GSTServiceInvoiceErr: Label 'GST Related Fields not Validated on Service Invoice';
        GSTServiceQuoteErr: Label 'GST Related Fields not Validated on Service Quote';
        GSTServiceCreditMemoErr: Label 'GST Related Fields not Validated on Service Credit Memo';

    [Test]
    procedure ValidateGSTFieldsOnServiceOrder()
    var
        Customer: Record Customer;
        ServiceHeader: Record "Service Header";
        DocumentType: Enum "Service Document Type";
        CustomerNo: Code[20];
    begin
        // [SCENARIO] [378342]	[Check GST related all fileds on Service Order]
        // [GIVEN] Create Customer Setup
        CustomerNo := LibraryGST.CreateCustomerSetup();
        Customer.Get(CustomerNo);
        Customer.Validate("State Code", LibraryGST.CreateGSTStateCode());
        Customer.Validate("GST Customer Type", Customer."GST Customer Type"::Unregistered);
        Customer.Modify(true);

        // [WHEN] Created Service Header and Validated Customer No
        LibraryService.CreateServiceHeader(ServiceHeader, DocumentType::Order, CustomerNo);
        ServiceHeader.Validate("Customer No.", CustomerNo);
        ServiceHeader.Modify(true);

        // [THEN] GST Related Fields Verified On Service Order
        VerifyGSTFieldsOnServiceOrder(ServiceHeader);
    end;

    [Test]
    procedure ValidateGSTFieldsOnServiceInvoice()
    var
        Customer: Record Customer;
        ServiceHeader: Record "Service Header";
        DocumentType: Enum "Service Document Type";
        CustomerNo: Code[20];
    begin
        // [SCENARIO] [378343]	[Check GST related all fileds on Service Invoice]
        // [GIVEN] Create Customer Setup
        CustomerNo := LibraryGST.CreateCustomerSetup();
        Customer.Get(CustomerNo);
        Customer.Validate("State Code", LibraryGST.CreateGSTStateCode());
        Customer.Validate("GST Customer Type", Customer."GST Customer Type"::Unregistered);
        Customer.Modify(true);

        // [WHEN] Created Service Header and Validated Customer No
        LibraryService.CreateServiceHeader(ServiceHeader, DocumentType::Invoice, CustomerNo);
        ServiceHeader.Validate("Customer No.", CustomerNo);
        ServiceHeader.Modify(true);

        // [THEN] GST Related Fields Verified On Service Invoice
        VerifyGSTFieldsOnServiceOrder(ServiceHeader);
    end;

    [Test]
    procedure ValidateGSTFieldsOnServiceCreditMemo()
    var
        Customer: Record Customer;
        ServiceHeader: Record "Service Header";
        DocumentType: Enum "Service Document Type";
        CustomerNo: Code[20];
    begin
        // [SCENARIO] [378344]	[Check GST related all fileds on Service Credit Memo]
        // [GIVEN] Create Customer Setup
        CustomerNo := LibraryGST.CreateCustomerSetup();
        Customer.Get(CustomerNo);
        Customer.Validate("State Code", LibraryGST.CreateGSTStateCode());
        Customer.Validate("GST Customer Type", Customer."GST Customer Type"::Unregistered);
        Customer.Modify(true);

        // [WHEN] Created Service Header and Validated Customer No
        LibraryService.CreateServiceHeader(ServiceHeader, DocumentType::"Credit Memo", CustomerNo);
        ServiceHeader.Validate("Customer No.", CustomerNo);
        ServiceHeader.Modify(true);

        // [THEN] GST Related Fields Verified On Service Credit Memo
        VerifyGSTFieldsOnServiceOrder(ServiceHeader);
    end;

    [Test]
    procedure ValidateGSTFieldsOnServiceQuote()
    var
        Customer: Record Customer;
        ServiceHeader: Record "Service Header";
        DocumentType: Enum "Service Document Type";
        CustomerNo: Code[20];
    begin
        // [SCENARIO] [378341]	[Check GST related all fileds on Service Quote]
        // [GIVEN] Create Customer Setup
        CustomerNo := LibraryGST.CreateCustomerSetup();
        Customer.Get(CustomerNo);
        Customer.Validate("State Code", LibraryGST.CreateGSTStateCode());
        Customer.Validate("GST Customer Type", Customer."GST Customer Type"::Unregistered);
        Customer.Modify(true);

        // [WHEN] Created Service Header and Validated Customer No
        LibraryService.CreateServiceHeader(ServiceHeader, DocumentType::Quote, CustomerNo);
        ServiceHeader.Validate("Customer No.", CustomerNo);
        ServiceHeader.Modify(true);

        // [THEN] GST Related Fields Verified On Service Quote
        VerifyGSTFieldsOnServiceQuote(ServiceHeader);
    end;

    procedure VerifyGSTFieldsOnServiceOrder(var ServiceHeader: Record "Service Header")
    begin
        ServiceHeader.SetFilter("Invoice Type", '<>%1', ServiceHeader."Invoice Type"::" ");
        ServiceHeader.SetRange("POS Out Of India", false);
        ServiceHeader.SetRange("GST Without Payment of Duty", false);
        ServiceHeader.SetFilter("GST Inv. Rounding Precision", '<>%1', 0.00);
        ServiceHeader.SetFilter("GST Bill-to State Code", '<>%1', '');
        ServiceHeader.SetFilter("GST Customer Type", '<>%1', ServiceHeader."GST Customer Type"::" ");
        if ServiceHeader.IsEmpty then
            Error(GSTServiceOrderErr);
    end;

    procedure VerifyGSTFieldsOnServiceInvoice(var ServiceHeader: Record "Service Header")
    begin
        ServiceHeader.SetFilter("Invoice Type", '<>%1', ServiceHeader."Invoice Type"::" ");
        ServiceHeader.SetRange("POS Out Of India", false);
        ServiceHeader.SetRange("GST Without Payment of Duty", false);
        ServiceHeader.SetFilter("GST Inv. Rounding Precision", '<>%1', 0.00);
        ServiceHeader.SetFilter("GST Bill-to State Code", '<>%1', '');
        ServiceHeader.SetFilter("GST Customer Type", '<>%1', ServiceHeader."GST Customer Type"::" ");
        if ServiceHeader.IsEmpty then
            Error(GSTServiceInvoiceErr);
    end;

    procedure VerifyGSTFieldsOnServiceQuote(var ServiceHeader: Record "Service Header")
    begin
        ServiceHeader.SetFilter("Invoice Type", '<>%1', ServiceHeader."Invoice Type"::" ");
        ServiceHeader.SetRange("POS Out Of India", false);
        ServiceHeader.SetRange("GST Without Payment of Duty", false);
        ServiceHeader.SetFilter("GST Inv. Rounding Precision", '<>%1', 0.00);
        ServiceHeader.SetFilter("GST Bill-to State Code", '<>%1', '');
        ServiceHeader.SetFilter("GST Customer Type", '<>%1', ServiceHeader."GST Customer Type"::" ");
        if ServiceHeader.IsEmpty then
            Error(GSTServiceQuoteErr);
    end;

    procedure VerifyGSTFieldsOnServiceCreditMemo(var ServiceHeader: Record "Service Header")
    begin
        ServiceHeader.SetFilter("Invoice Type", '<>%1', ServiceHeader."Invoice Type"::" ");
        ServiceHeader.SetRange("POS Out Of India", false);
        ServiceHeader.SetRange("GST Without Payment of Duty", false);
        ServiceHeader.SetFilter("GST Inv. Rounding Precision", '<>%1', 0.00);
        ServiceHeader.SetFilter("GST Bill-to State Code", '<>%1', '');
        ServiceHeader.SetFilter("GST Customer Type", '<>%1', ServiceHeader."GST Customer Type"::" ");
        if ServiceHeader.IsEmpty then
            Error(GSTServiceCreditMemoErr);
    end;
}