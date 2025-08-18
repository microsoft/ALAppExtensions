codeunit 144022 "ERM Sales Report - GB"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
    end;

    var
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryUtility: Codeunit "Library - Utility";

    [Test]
    [HandlerFunctions('OrderConfirmationGBRequestPageHandler')]

    procedure OrderConfirmationGBExternalDocumentNoIsPrinted()
    var
        SalesHeader: Record "Sales Header";
    begin
        // [FEATURE] [UI] [Order] [Confirmation]
        // [SCENARIO 225794] "External Document No." is shown with its caption when report "Order Confirmation GB" is printed for Sales Order
        Initialize();

        // [GIVEN] Sales Order with "External Document No." = "XXX"
        MockSalesOrderWithExternalDocumentNo(SalesHeader);

        // [WHEN] Export report "Order Confirmation GB" to XML file
        RunOrderConfirmationGBReport(SalesHeader."No.");
        LibraryReportDataset.LoadDataSetFile();

        // [THEN] Value "External Document No." is displayed under Tag <ReferenceText> in export XML file
        LibraryReportDataset.AssertElementTagWithValueExists('ReferenceText', SalesHeader.FieldCaption("External Document No."));

        // [THEN] Value "XXX" is displayed under Tag <YourRef_SalesHeader> in export XML file
        LibraryReportDataset.AssertElementTagWithValueExists('YourRef_SalesHeader', SalesHeader."External Document No.");
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        Clear(LibraryReportDataset);

        LibraryERMCountryData.UpdatePrepaymentAccounts();
        LibraryERMCountryData.UpdateFAPostingGroup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
    end;

    local procedure RunOrderConfirmationGBReport(SalesHeaderNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
    begin
        Commit();
        SalesHeader.SetRange("No.", SalesHeaderNo);
        REPORT.Run(REPORT::"Order Confirmation", true, false, SalesHeader);
    end;

    [RequestPageHandler]

    procedure OrderConfirmationGBRequestPageHandler(var OrderConfirmationGB: TestRequestPage "Order Confirmation")
    begin
        OrderConfirmationGB.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    local procedure MockSalesOrderWithExternalDocumentNo(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader."No." := LibraryUtility.GenerateGUID();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."External Document No." := LibraryUtility.GenerateGUID();
        SalesHeader.Insert();
    end;
}