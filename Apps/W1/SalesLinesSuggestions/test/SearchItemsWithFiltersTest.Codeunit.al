namespace Microsoft.Sales.Document.Test;

using System.TestLibraries.Utilities;
using System.TestTools.AITestToolkit;
using System.TestTools.TestRunner;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;

codeunit 149828 "Search Items With Filters Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;

    [Test]
    [HandlerFunctions('CheckGenerateFromSalesOrder')]
    procedure PositiveTest()
    var
        AITestContext: Codeunit "AIT Test Context";
    begin
        Initialize();

        GenerateTestData(AITestContext.GetInput().Element('given'));
        Sleep(1000);
        GetSalesLinesSuggestionsUpTo3Times(AITestContext);
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;

        IsInitialized := true;
    end;

    local procedure GenerateTestData(GivenTestData: Codeunit "Test Input Json")
    var
        SLSTestDemoData: Codeunit "SLS Test Demo Data";
        GivenTestDataArray: JsonArray;
        DataToken: JsonToken;
    begin
        GivenTestDataArray := GivenTestData.AsJsonToken().AsArray();
        foreach DataToken in GivenTestDataArray do
            case DataToken.AsValue().AsText() of
                'Items':
                    SLSTestDemoData.Items();
                'Sales Quotes':
                    SLSTestDemoData.SalesQuotes();
                'Sales Orders':
                    SLSTestDemoData.SalesOrders();
                'Sales Blanket Orders':
                    SLSTestDemoData.SalesBlanketOrders();
                'Posted Sales Orders':
                    SLSTestDemoData.PostedSalesOrders();
            end;
    end;

    local procedure GetSalesLinesSuggestionsUpTo3Times(AITestContext: Codeunit "AIT Test Context")
    var
        SalesHeader: Record "Sales Header";
        SalesLineAISuggestions: Page "Sales Line AI Suggestions";
        AttemptNo: Integer;
        Result: Boolean;
    begin
        repeat
            AttemptNo += 1;
            CreateSalesOrderAndGetSalesLinesSuggestions(AITestContext.GetQuestion().ValueAsText(), SalesHeader, SalesLineAISuggestions);
            Result := VerifySalesLines(SalesHeader, AITestContext.GetInput().Element('Expected'));
        until Result or (AttemptNo >= 3);

        if not Result then
            Assert.Fail(GetLastErrorText());
    end;

    local procedure CreateSalesOrderAndGetSalesLinesSuggestions(UserInput: Text;
                                                                var SalesHeader: Record "Sales Header";
                                                                var SalesLineAISuggestions: Page "Sales Line AI Suggestions")
    var
        Customer: Record Customer;
        SLSTestDemoData: Codeunit "SLS Test Demo Data";
    begin
        SLSTestDemoData.GetCustomer(Customer);

        Clear(SalesHeader);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibraryVariableStorage.Enqueue(UserInput);
        SalesLineAISuggestions.SetSalesHeader(SalesHeader);
        SalesLineAISuggestions.LookupMode := true;
        SalesLineAISuggestions.RunModal();
    end;

    [TryFunction]
    local procedure VerifySalesLines(SalesHeader: Record "Sales Header"; ExpectedSalesLines: Codeunit "Test Input Json")
    var
        SalesLine: Record "Sales Line";
        SalesLinesJsonArray: JsonArray;
        SalesLineJson: JsonToken;
        JToken: JsonToken;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);

        SalesLinesJsonArray := ExpectedSalesLines.AsJsonToken().AsArray();
        Assert.RecordCount(SalesLine, SalesLinesJsonArray.Count());

        foreach SalesLineJson in SalesLinesJsonArray do begin
            if SalesLineJson.AsObject().Get('Description', JToken) then
                SalesLine.SetFilter(Description, StrSubstNo('*%1*', JToken.AsValue().AsText()))
            else
                SalesLine.SetRange(Description);
            if SalesLineJson.AsObject().Get('Quantity', JToken) then
                SalesLine.SetRange(Quantity, JToken.AsValue().AsDecimal())
            else
                SalesLine.SetRange(Quantity);
            if SalesLineJson.AsObject().Get('Unit of Measure Code', JToken) then
                SalesLine.SetRange("Unit of Measure Code", JToken.AsValue().AsText())
            else
                SalesLine.SetRange("Unit of Measure Code");
            Assert.RecordCount(SalesLine, 1);
        end;
    end;

    [ModalPageHandler]
    procedure CheckGenerateFromSalesOrder(var SalesLineAISuggestions: TestPage "Sales Line AI Suggestions")
    begin
        Commit();
        SalesLineAISuggestions.SearchQueryTxt.SetValue(LibraryVariableStorage.DequeueText());
        SalesLineAISuggestions.Generate.Invoke();
        SalesLineAISuggestions.OK.Invoke();
    end;
}