codeunit 136864 "Use Case Mgmt. Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;
    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Use Case Mgmt.] [UT]
    end;

    var
        Assert: Codeunit Assert;
        LibraryUseCase: Codeunit "Library - Use Case Tests";
        LibraryTaxType: Codeunit "Library - Tax Type Tests";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";

    [Test]
    [HandlerFunctions('TableRelationDialogHandler')]
    procedure TestOpenTableRelationDialog()
    var
        UseCaseMgmt: Codeunit "Use Case Mgmt.";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        CaseID, EmptyGuid, ID : Guid;
    begin
        // [SCENARIO] To check if Table Relation Dialog is opening

        // [GIVEN] There should be a record in Table Relation
        CaseID := CreateGuid();
        LibraryTaxType.CreateTaxType('VAT', 'VAT');
        LibraryUseCase.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);
        ID := UseCaseEntityMgmt.CreateTableRelation(CaseID);

        // [WHEN] Then function OpenTableRelationDialog is called
        UseCaseMgmt.OpenTableRelationDialog(CaseID, ID);

        // [THEN] it should open Table Relation dialog
    end;

    [Test]
    [HandlerFunctions('ComponentExpreDialogHandler')]
    procedure TestOpenComponentExprDialog()
    var
        UseCaseMgmt: Codeunit "Use Case Mgmt.";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        CaseID, ID, EmptyGuid : Guid;
        ComponentID: Integer;
    begin
        // [SCENARIO] To check if ComponentExprDialog Dialog is opening

        // [GIVEN] There should be a record in ComponentExpr Dialog
        CaseID := CreateGuid();
        LibraryTaxType.CreateTaxType('VAT', 'VAT');
        LibraryUseCase.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);
        ComponentID := LibraryTaxType.CreateComponent('VAT', 'VAT', "Rounding Direction"::Nearest, 0.1, false);
        ID := UseCaseEntityMgmt.CreateComponentExpression(CaseID, ComponentID);

        // [WHEN] Then function OpenComponentExprDialog is called
        UseCaseMgmt.OpenComponentExprDialog(CaseID, ID);

        // [THEN] it should open Component Expression Dialog
    end;

    [Test]
    [HandlerFunctions('TaxUseCaseCardHandler')]
    procedure TestCreateAndOpenChildUseCaseCard()
    var
        TaxUseCase: Record "Tax Use Case";
        SalesLine: Record "Sales Line";
        UseCaseMgmt: Codeunit "Use Case Mgmt.";
        CaseID, EmptyGuid : Guid;
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        AttributeID: Integer;
    begin
        // [SCENARIO] To check if CreateAndOpenChildUseCaseCard function is creating child use 

        // [GIVEN] There should be a record in Tax Use Case
        CaseID := CreateGuid();
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryUseCase.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);
        AttributeID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VatBusPostingGrp', Type::Text, Database::"Sales Line", SalesLine.FieldNo("VAT Bus. Posting Group"), 0, false);
        LibraryUseCase.CreateAttributeMapping('VAT', CaseID, AttributeID);
        // [WHEN] Then function ApplyTableLinkFilters is called
        TaxUseCase.Get(CaseID);
        UseCaseMgmt.CreateAndOpenChildUseCaseCard(TaxUseCase);

        // [THEN] it should open Component Expression Dialog
        TaxUseCase.SetRange("Parent Use Case ID", CaseID);
        Assert.RecordIsNotEmpty(TaxUseCase);
    end;



    [Test]
    procedure TestIndentUseCases()
    begin
    end;

    [ModalPageHandler]
    procedure TableRelationDialogHandler(var TableRelationDialog: TestPage "Tax Table Relation Dialog")
    begin
        TableRelationDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure ComponentExpreDialogHandler(var ComponentExprDialog: TestPage "Tax Component Expr. Dialog")
    begin
        ComponentExprDialog.OK().Invoke();
    end;

    [PageHandler]
    procedure TaxUseCaseCardHandler(var TaxUseCaseCard: TestPage "Use Case Card")
    begin
        TaxUseCaseCard.OK().Invoke();
    end;
}