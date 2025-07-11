codeunit 148150 "FI Company Field Report Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        RegisteredHomeCityTxt: Text[50];

    local procedure Initialize()
    var
        CompanyInformation: Record "Company Information";
    begin
        RegisteredHomeCityTxt := '0123456789';

        CompanyInformation.Get();
        CompanyInformation."Registered Home City" := RegisteredHomeCityTxt;
        CompanyInformation.Modify();

        Commit();
    end;

    [Test]
    [HandlerFunctions('StandardSalesQuoteReportRequestPageHandler')]
    procedure RegisteredHomeCityInStandardSalesQuote()
    var
        CompanyInformation: Record "Company Information";
        SalesHeader: Record "Sales Header";
        DocumentNo: Code[20];
        RequestPageXML: Text;
    begin
        // [Scenario] Test FI Core extension subscriber for the field "Registered Home City"
        Initialize();

        DocumentNo := CreateSalesDocument(SalesHeader."Document Type"::Quote);

        // [THEN] The even should be triggered in OnInitReport
        RequestPageXML := Report.RunRequestPage(Report::"Standard Sales - Quote", RequestPageXML);

        SalesHeader.SetRange("No.", DocumentNo);
        LibraryReportDataset.RunReportAndLoad(Report::"Standard Sales - Quote", SalesHeader, RequestPageXML);

        // [THEN] Element should be correctly initialized
        LibraryReportDataset.AssertElementWithValueExists('CompanyLegalOffice', RegisteredHomeCityTxt);
        LibraryReportDataset.AssertElementWithValueExists('CompanyLegalOffice_Lbl', CompanyInformation.FieldCaption(CompanyInformation."Registered Home City"));
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