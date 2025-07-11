codeunit 136816 "Tax Transaction Value Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Transaction Value Helper] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestUpdateCaseID()
    var
        SalesLine: Record "Sales Line";
        TaxTransactionValue: Record "Tax Transaction Value";
        TransactionValueHelper: Codeunit "Transaction Value Helper";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        RecRef: RecordRef;
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        CaseID, NewCaseID : Guid;
        AttributeID: Integer;
    begin
        // [SCENARIO] To check function is updating CaseID Transaction Value table

        // [GIVEN] There should be a record in tax Transaction Value
        CaseID := CreateGuid();
        NewCaseID := CreateGuid();
        SalesLine.FindFirst();
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::Customer, 'Customer', false);
        LibraryTaxTypeTests.CreateTaxEntntiy('VAT', Database::"Sales Line", 'Sales Line', true);
        AttributeID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'DocumentNo', Type::Text, Database::"Sales Line", SalesLine.FieldNo("Document No."), 0, false);
        LibraryTaxTypeTests.CreateTransactionValue('VAT', CaseID, SalesLine.RecordId, 0, "Transaction Value Type"::ATTRIBUTE, SalesLine."Document No.");

        // [WHEN] The function UpdateCaseID is called by using Case Id
        RecRef.GetTable(SalesLine);
        TransactionValueHelper.UpdateCaseID(RecRef, 'VAT', NewCaseID);

        // [THEN] it should udpate all records related to that case id.
        TaxTransactionValue.SetRange("Case ID", NewCaseID);
        TaxTransactionValue.SetRange("Tax Record ID", RecRef.RecordId);
        Assert.RecordIsNotEmpty(TaxTransactionValue);
    end;
}