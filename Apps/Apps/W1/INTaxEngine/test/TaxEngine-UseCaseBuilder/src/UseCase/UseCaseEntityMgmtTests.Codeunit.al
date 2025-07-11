codeunit 136862 "Use Case Entity Mgmt. Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;
    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Use Case Entity Mgmt.] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestGetSourceTable()
    var
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        LibraryUseCase: Codeunit "Library - Use Case Tests";
        LibraryTaxType: Codeunit "Library - Tax Type Tests";
        CaseID, EmptyGuid : Guid;
        TableID: Integer;
    begin
        // [SCENARIO] To check if function is returning source table ID of the use case.

        // [GIVEN] There should be a use case created.
        LibraryTaxType.CreateTaxType('VAT', 'VAT');
        CaseID := CreateGuid();
        LibraryUseCase.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);

        // [WHEN] function GetSourceTable is called
        TableID := UseCaseEntityMgmt.GetSourceTable(CaseID);

        // [THEN] It should return the table id of ne
        Assert.AreEqual(Database::"Sales Line", TableID, 'Table ID should be 37');
    end;

    [Test]
    procedure TestCreateRateColumnRelation()
    var
        UseCaseColumnRelation: Record "Use Case Rate Column Relation";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        LibraryUseCase: Codeunit "Library - Use Case Tests";
        LibraryTaxType: Codeunit "Library - Tax Type Tests";
        CaseID, EmptyGuid, ID : Guid;
    begin
        // [SCENARIO] To check if function is deleting record rate column relation

        // [GIVEN] There should a use case and use case event created in the system
        LibraryTaxType.CreateTaxType('VAT', 'VAT');
        CaseID := CreateGuid();
        LibraryUseCase.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);

        // [WHEN] function CreateRateColumnRelation is called
        ID := UseCaseEntityMgmt.CreateRateColumnRelation(CaseID);

        // [THEN] it should create a record in Use Case Column Relation Table Link
        UseCaseColumnRelation.SetRange("Case ID", CaseID);
        UseCaseColumnRelation.SetRange(ID, ID);
        Assert.RecordIsNotEmpty(UseCaseColumnRelation);
    end;

    [Test]
    procedure TestDeleteRateColumnRelation()
    var
        UseCaseColumnRelation: Record "Use Case Rate Column Relation";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        LibraryUseCase: Codeunit "Library - Use Case Tests";
        LibraryTaxType: Codeunit "Library - Tax Type Tests";
        CaseID, EmptyGuid, ID : Guid;
    begin
        // [SCENARIO] To check if function is deleting record rate column relation

        // [GIVEN] There should a use case and use case event created in the system
        LibraryTaxType.CreateTaxType('VAT', 'VAT');
        CaseID := CreateGuid();
        LibraryUseCase.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);
        ID := UseCaseEntityMgmt.CreateRateColumnRelation(CaseID);

        // [WHEN] function DeleteRateColumnRelation is called
        UseCaseEntityMgmt.DeleteRateColumnRelation(CaseID, ID);

        // [THEN] it should create a record in rate column relation
        UseCaseColumnRelation.SetRange("Case ID", CaseID);
        UseCaseColumnRelation.SetRange(ID, ID);
        Assert.RecordIsEmpty(UseCaseColumnRelation);
    end;

    [Test]
    procedure TestCreateUseCaseAttributeMapping()
    var
        UseCaseAttributeMapping: Record "Use Case Attribute Mapping";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        LibraryUseCase: Codeunit "Library - Use Case Tests";
        LibraryTaxType: Codeunit "Library - Tax Type Tests";
        CaseID, EmptyGuid, ID : Guid;
    begin
        // [SCENARIO] To check if function is creating record Attribute mapping

        // [GIVEN] There should a use case and use case event created in the system
        LibraryTaxType.CreateTaxType('VAT', 'VAT');
        CaseID := CreateGuid();
        LibraryUseCase.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);

        // [WHEN] function CreateUseCaseAttributeMapping is called
        ID := UseCaseEntityMgmt.CreateUseCaseAttributeMapping(CaseID);

        // [THEN] it should create a record in Use Case Attribute Mapping Table
        UseCaseAttributeMapping.SetRange("Case ID", CaseID);
        UseCaseAttributeMapping.SetRange(ID, ID);
        Assert.RecordIsNotEmpty(UseCaseAttributeMapping);
    end;

    [Test]
    procedure TestDeleteUseCaseAttributeMapping()
    var
        UseCaseAttributeMapping: Record "Use Case Attribute Mapping";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        LibraryUseCase: Codeunit "Library - Use Case Tests";
        LibraryTaxType: Codeunit "Library - Tax Type Tests";
        CaseID, EmptyGuid, ID : Guid;
    begin
        // [SCENARIO] To check if function is deleting record Attribtue mapping

        // [GIVEN] There should a use case and use case event created in the system
        LibraryTaxType.CreateTaxType('VAT', 'VAT');
        CaseID := CreateGuid();
        LibraryUseCase.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);
        ID := UseCaseEntityMgmt.CreateUseCaseAttributeMapping(CaseID);

        // [WHEN] function DeleteUseCaseAttributeMapping is called
        UseCaseEntityMgmt.DeleteUseCaseAttributeMapping(CaseID, ID);

        // [THEN] it should create a record in Use Case Attribute Mapping Table Link
        UseCaseAttributeMapping.SetRange("Case ID", CaseID);
        UseCaseAttributeMapping.SetRange(ID, ID);
        Assert.RecordIsEmpty(UseCaseAttributeMapping);
    end;

    [Test]
    procedure TestCreateComponentCalculation()
    var
        UseCaseComponentCalculation: Record "Use Case Component Calculation";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        LibraryUseCase: Codeunit "Library - Use Case Tests";
        LibraryTaxType: Codeunit "Library - Tax Type Tests";
        CaseID, EmptyGuid, ID : Guid;
    begin
        // [SCENARIO] To check if function is creating record in Component Calculation

        // [GIVEN] There should a use case and use case event created in the system
        LibraryTaxType.CreateTaxType('VAT', 'VAT');
        CaseID := CreateGuid();
        LibraryUseCase.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);

        // [WHEN] function CreateComponentCalculation is called
        ID := UseCaseEntityMgmt.CreateComponentCalculation(CaseID);

        // [THEN] it should create a record in Component Calculation Table
        UseCaseComponentCalculation.SetRange("Case ID", CaseID);
        UseCaseComponentCalculation.SetRange(ID, ID);
        Assert.RecordIsNotEmpty(UseCaseComponentCalculation);
    end;

    [Test]
    procedure TestDeleteComponentCalculation()
    var
        UseCaseComponentCalculation: Record "Use Case Component Calculation";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        LibraryUseCase: Codeunit "Library - Use Case Tests";
        LibraryTaxType: Codeunit "Library - Tax Type Tests";
        CaseID, EmptyGuid, ID : Guid;
    begin
        // [SCENARIO] To check if function is deleting record from Component Calculation

        // [GIVEN] There should a use case and use case event created in the system
        LibraryTaxType.CreateTaxType('VAT', 'VAT');
        CaseID := CreateGuid();
        LibraryUseCase.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);
        ID := UseCaseEntityMgmt.CreateComponentCalculation(CaseID);

        // [WHEN] function DeleteComponentCalculation is called
        UseCaseEntityMgmt.DeleteComponentCalculation(CaseID, ID);

        // [THEN] it should delete record in Component Calculation Table
        UseCaseComponentCalculation.SetRange("Case ID", CaseID);
        UseCaseComponentCalculation.SetRange(ID, ID);
        Assert.RecordIsEmpty(UseCaseComponentCalculation);
    end;

    [Test]
    procedure TestCreateComponentExpression()
    var
        TaxComponentExpression: Record "Tax Component Expression";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        LibraryUseCase: Codeunit "Library - Use Case Tests";
        LibraryTaxType: Codeunit "Library - Tax Type Tests";
        CaseID, EmptyGuid, ID : Guid;
        ComponentID: Integer;
    begin
        // [SCENARIO] To check if function is creating record in Component Expression

        // [GIVEN] There should a use case and use case event created in the system
        LibraryTaxType.CreateTaxType('VAT', 'VAT');
        ComponentID := LibraryTaxType.CreateComponent('VAT', 'VAT', "Rounding Direction"::Nearest, 0.1, false);

        CaseID := CreateGuid();
        LibraryUseCase.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);

        // [WHEN] function CreateComponentExpression is called
        ID := UseCaseEntityMgmt.CreateComponentExpression(CaseID, ComponentID);

        // [THEN] it should create record in Component expression Table
        TaxComponentExpression.SetRange("Case ID", CaseID);
        TaxComponentExpression.SetRange(ID, ID);
        Assert.RecordIsNotEmpty(TaxComponentExpression);
    end;

    [Test]
    procedure TestDeleteTaxComponentExpression()
    var
        TaxComponentExpression: Record "Tax Component Expression";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        LibraryUseCase: Codeunit "Library - Use Case Tests";
        LibraryTaxType: Codeunit "Library - Tax Type Tests";
        CaseID, EmptyGuid, ID : Guid;
        ComponentID: Integer;
    begin
        // [SCENARIO] To check if function is creating record in Component Expression

        // [GIVEN] There should a use case and use case event created in the system
        LibraryTaxType.CreateTaxType('VAT', 'VAT');
        ComponentID := LibraryTaxType.CreateComponent('VAT', 'VAT', "Rounding Direction"::Nearest, 0.1, false);

        CaseID := CreateGuid();
        LibraryUseCase.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);
        ID := UseCaseEntityMgmt.CreateComponentExpression(CaseID, ComponentID);

        // [WHEN] function DeleteTaxComponentExpression is called
        UseCaseEntityMgmt.DeleteTaxComponentExpression(CaseID, ID);

        // [THEN] it should delete record in Component Calculation Table
        TaxComponentExpression.SetRange("Case ID", CaseID);
        TaxComponentExpression.SetRange(ID, ID);
        Assert.RecordIsEmpty(TaxComponentExpression);
    end;

    [Test]
    procedure TestCreateTableRelation()
    var
        TaxTableRelation: Record "Tax Table Relation";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        LibraryTaxType: Codeunit "Library - Tax Type Tests";
        CaseID, ID : Guid;
        ComponentID: Integer;
    begin
        // [SCENARIO] To check if function is creating record in Tax Table Relation

        // [GIVEN] There should a use case and use case event created in the system
        LibraryTaxType.CreateTaxType('VAT', 'VAT');
        ComponentID := LibraryTaxType.CreateComponent('VAT', 'VAT', "Rounding Direction"::Nearest, 0.1, false);

        CaseID := CreateGuid();

        // [WHEN] function CreateTableRelation is called
        ID := UseCaseEntityMgmt.CreateTableRelation(CaseID);

        // [THEN] it should delete record in Tax Table Relation Table
        TaxTableRelation.SetRange("Case ID", CaseID);
        TaxTableRelation.SetRange(ID, ID);
        Assert.RecordIsNotEmpty(TaxTableRelation);
    end;

    [Test]
    procedure TestDeleteTableRelation()
    var
        TaxTableRelation: Record "Tax Table Relation";
        UseCaseEntityMgmt: Codeunit "Use Case Entity Mgmt.";
        LibraryTaxType: Codeunit "Library - Tax Type Tests";
        CaseID, ID : Guid;
        ComponentID: Integer;
    begin
        // [SCENARIO] To check if function is deleting record from Tax Table Relation

        // [GIVEN] There should a use case and use case event created in the system
        LibraryTaxType.CreateTaxType('VAT', 'VAT');
        ComponentID := LibraryTaxType.CreateComponent('VAT', 'VAT', "Rounding Direction"::Nearest, 0.1, false);

        CaseID := CreateGuid();
        ID := UseCaseEntityMgmt.CreateTableRelation(CaseID);

        // [WHEN] function DeleteTableRelation is called
        UseCaseEntityMgmt.DeleteTableRelation(CaseID, ID);

        // [THEN] it should delete record in Tax Table Relation Table
        TaxTableRelation.SetRange("Case ID", CaseID);
        TaxTableRelation.SetRange(ID, ID);
        Assert.RecordIsEmpty(TaxTableRelation);
    end;
}