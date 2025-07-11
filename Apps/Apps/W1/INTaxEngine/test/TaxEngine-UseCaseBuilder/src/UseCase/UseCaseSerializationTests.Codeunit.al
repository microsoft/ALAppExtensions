codeunit 136867 "Use Case Serialization Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Use Case Serialization] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestTableRelationToString()
    var
        SalesHeader: Record "Sales Header";
        UseCaseSerialization: Codeunit "Use Case Serialization";
        LibraryUseCaseTests: Codeunit "Library - Use Case Tests";
        CaseID, TableRelationID, TableFilterID : Guid;
        ExpectedText, Text : Text;
    begin
        // [SCENARIO] To Serialize 'Tax Table Relation' to String

        // [GIVEN] Tax Table Relation Record with Table Filters
        LibraryUseCaseTests.CreateTableFilters(CaseID, TableFilterID, Database::"Sales Header");
        LibraryUseCaseTests.AddLookupFieldFilter(
            CaseID,
            TableFilterID,
            Database::"Sales Header",
            SalesHeader.FieldNo("Document Type"),
            'Order');
        LibraryUseCaseTests.AddLookupFieldFilter(
            CaseID,
            TableFilterID,
            Database::"Sales Header",
            SalesHeader.FieldNo("No."),
            'ORD001');

        LibraryUseCaseTests.CreateTableRelation(CaseID, TableRelationID, TableFilterID, Database::"Sales Header");

        ExpectedText := '"Sales Header" where Document Type Equals ''Order'',No. Equals ''ORD001''';
        // [WHEN] function TableRelationToString is called
        Text := UseCaseSerialization.TableRelationToString(CaseID, TableRelationID);

        // [THEN] it should serialiaze to string
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - Expected'));
    end;

    [Test]
    procedure TestComponentExpressionToString()
    var
        SalesLine: Record "Sales Line";
        TaxComponentExpression: Record "Tax Component Expression";
        UseCaseSerialization: Codeunit "Use Case Serialization";
        LibraryUseCaseTests: Codeunit "Library - Use Case Tests";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        CaseID, ScriptID, ComponentExpressionID : Guid;
        QuantityLookupID, PriceLookupID, DiscountLookupID : Guid;
        ComponentID: Integer;
        ExpectedText, Text : Text;
    begin
        // [SCENARIO] To Serialize 'Tax Component Expression' to String

        // [GIVEN] Tax Component Expression Record with an expression
        BindSubscription(LibraryUseCaseTests);
        ComponentID := 1;
        LibraryUseCaseTests.CreateComponentExpression(CaseID, ComponentExpressionID, ComponentID);
        TaxComponentExpression.Get(CaseID, ComponentExpressionID);
        TaxComponentExpression.Expression := ' a + b - c';
        TaxComponentExpression.Modify();

        QuantityLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.FieldNo(Quantity), "Symbol Type"::"Current Record");
        PriceLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.FieldNo("Unit Price"), "Symbol Type"::"Current Record");
        DiscountLookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, Database::"Sales Line", SalesLine.FieldNo("Line Discount Amount"), "Symbol Type"::"Current Record");
        LibraryUseCaseTests.AddComponentExpressionToken(CaseID, ComponentExpressionID, 'a', QuantityLookupID);
        LibraryUseCaseTests.AddComponentExpressionToken(CaseID, ComponentExpressionID, 'b', PriceLookupID);
        LibraryUseCaseTests.AddComponentExpressionToken(CaseID, ComponentExpressionID, 'c', DiscountLookupID);

        ExpectedText := 'Calculate value of " a + b - c", a equals Quantity, b equals "Unit Price", c equals "Line Discount Amount" (Output to Variable: XGST)';
        // [WHEN] function ComponentExpressionToString is called
        Text := UseCaseSerialization.ComponentExpressionToString(CaseID, ComponentExpressionID);
        UnbindSubscription(LibraryUseCaseTests);

        // [THEN] it should serialiaze to string
        Assert.AreEqual(ExpectedText, Text, StrSubstNo('%1 - Expected'));
    end;
}