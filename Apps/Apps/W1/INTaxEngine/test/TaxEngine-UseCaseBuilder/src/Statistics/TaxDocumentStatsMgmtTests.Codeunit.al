codeunit 136857 "Tax Document Stats Mgmt Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Tax Document Stats Mgmt.] [UT]
    end;

    [Test]
    procedure TestUpdateTaxComponent()
    var
        SalesLine: Record "Sales Line";
        TaxComponentSummary: Record "Tax Component Summary" temporary;
        LibraryUseCase: Codeunit "Library - Use Case Tests";
        LibraryTaxType: Codeunit "Library - Tax Type Tests";
        TaxDocumentStatsMgmt: Codeunit "Tax Document Stats Mgmt.";
        RecIDList: List of [RecordID];
        CaseID, EmptyGuid : Guid;
        AttributeID, ComponentID : Integer;
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
    begin
        // [SCENARIO] To check Tax Component Summary is getting updated with the records of transaction Value

        // [GIVEN] There should be a sales line for which there should be a tax transaction value.
        CaseID := CreateGuid();
        LibraryTaxType.CreateTaxType('VAT', 'VAT');
        AttributeID := LibraryTaxType.CreateTaxAttribute('VAT', 'VATBusPostingGrp', Type::Text, Database::"Sales Line", SalesLine.FieldNo("VAT Bus. Posting Group"), 0, false);
        ComponentID := LibraryTaxType.CreateComponent('VAT', 'VAT', "Rounding Direction"::Nearest, 0.1, false);
        LibraryUseCase.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetFilter("No.", '<>%1', '');
        SalesLine.FindFirst();
        RecIDList.Add(SalesLine.RecordId);

        LibraryUseCase.CreateTransactionValue(CaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, SalesLine."VAT Bus. Posting Group", 0, 0, SalesLine.RecordId, 'VAT');
        LibraryUseCase.CreateTransactionValue(CaseID, ComponentID, "Transaction Value Type"::COMPONENT, SalesLine."VAT Bus. Posting Group", 1000, 10, SalesLine.RecordId, 'VAT');

        // [WHEN] The function UpdateTaxComponent is called
        TaxDocumentStatsMgmt.UpdateTaxComponent(RecIDList, TaxComponentSummary);

        // [THEN] it should update temporary variable of Tax Component Summary
        TaxComponentSummary.Reset();
        Assert.RecordIsNotEmpty(TaxComponentSummary);
    end;

    [Test]
    procedure TestClearBuffer()
    var
        SalesLine: Record "Sales Line";
        TaxComponentSummary: Record "Tax Component Summary" temporary;
        LibraryUseCase: Codeunit "Library - Use Case Tests";
        LibraryTaxType: Codeunit "Library - Tax Type Tests";
        TaxDocumentStatsMgmt: Codeunit "Tax Document Stats Mgmt.";
        RecIDList: List of [RecordID];
        CaseID, EmptyGuid : Guid;
        AttributeID, ComponentID : Integer;
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
    begin
        // [SCENARIO] To check Tax Component Summary is getting cleared

        // [GIVEN] There should be a sales line for which there should be a tax transaction value.
        CaseID := CreateGuid();
        LibraryTaxType.CreateTaxType('VAT', 'VAT');
        AttributeID := LibraryTaxType.CreateTaxAttribute('VAT', 'VATBusPostingGrp', Type::Text, Database::"Sales Line", SalesLine.FieldNo("VAT Bus. Posting Group"), 0, false);
        ComponentID := LibraryTaxType.CreateComponent('VAT', 'VAT', "Rounding Direction"::Nearest, 0.1, false);
        LibraryUseCase.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetFilter("No.", '<>%1', '');
        SalesLine.FindFirst();
        RecIDList.Add(SalesLine.RecordId);

        LibraryUseCase.CreateTransactionValue(CaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, SalesLine."VAT Bus. Posting Group", 0, 0, SalesLine.RecordId, 'VAT');
        LibraryUseCase.CreateTransactionValue(CaseID, ComponentID, "Transaction Value Type"::COMPONENT, SalesLine."VAT Bus. Posting Group", 1000, 10, SalesLine.RecordId, 'VAT');
        TaxDocumentStatsMgmt.UpdateTaxComponent(RecIDList, TaxComponentSummary);

        // [WHEN] The function ClearBuffer is called
        TaxDocumentStatsMgmt.ClearBuffer();

        // [THEN] it should clear temporary variable of Tax Component Summary
        TaxComponentSummary.Reset();
        Assert.RecordIsEmpty(TaxComponentSummary);
    end;

    var
        Assert: Codeunit Assert;
}