codeunit 148161 "SE Registered Office On Report"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        RegisteredOfficeTxt: Text[20];

    [Test]
    [HandlerFunctions('StandardSalesQuoteReportRequestPageHandler')]
    procedure RegisteredOfficeOnSalesQuoteReport()
    var
        CompanyInformation: Record "Company Information";
        SalesHeader: Record "Sales Header";
        DocumentNo: Code[20];
        RequestPageXML: Text;
    begin
        // [Scenario] Test SE Core extension subscriber for the field "Registered Office"
        Initialize();

        DocumentNo := CreateSalesDocument(SalesHeader."Document Type"::Quote);

        // [THEN] The even should be triggered in OnInitReport
        RequestPageXML := Report.RunRequestPage(Report::"Standard Sales - Quote", RequestPageXML);

        SalesHeader.SetRange("No.", DocumentNo);
        LibraryReportDataset.RunReportAndLoad(Report::"Standard Sales - Quote", SalesHeader, RequestPageXML);

        // [THEN] Element should be correctly initialized
        LibraryReportDataset.AssertElementWithValueExists('CompanyLegalOffice', RegisteredOfficeTxt);
        LibraryReportDataset.AssertElementWithValueExists('CompanyLegalOffice_Lbl', CompanyInformation.GetLegalOfficeLabel());
    end;

    local procedure Initialize()
    var
        CompanyInformation: Record "Company Information";
    begin
        RegisteredOfficeTxt := '0123456789';

        CompanyInformation.Get();
        CompanyInformation."Registered Office Info" := RegisteredOfficeTxt;
        CompanyInformation.Modify();

        Commit();
    end;

    local procedure CreateSalesDocument(Type: Enum "Sales Document Type"): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        LibrarySales.CreateSalesHeader(SalesHeader, Type, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItemNo(), LibraryRandom.RandInt(1000));

        Commit();

        exit(SalesHeader."No.");
    end;

    [RequestPageHandler]
    procedure StandardSalesQuoteReportRequestPageHandler(var StandardSalesQuote: TestRequestPage "Standard Sales - Quote")
    begin
    end;
}