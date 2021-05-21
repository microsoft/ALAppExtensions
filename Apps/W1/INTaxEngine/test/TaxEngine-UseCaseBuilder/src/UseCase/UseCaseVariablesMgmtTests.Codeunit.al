codeunit 136868 "Use Case Variables Mgmt. Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Use Case Variables Mgmt.] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestGetTaxAttributeValue()
    var
        EntityAttributeMapping: Record "Entity Attribute Mapping";
        AllObj: Record AllObj;
        UseCaseVariablesMgmt: Codeunit "Use Case Variables Mgmt.";
        LibraryUseCaseTests: Codeunit "Library - Use Case Tests";
        RecRef: RecordRef;
        CaseID: Guid;
        AttributeValue: Variant;
    begin
        // [SCENARIO] Get Attribute Value where Attribute is mapped to a field

        // [GIVEN] Attribute ID mapped to Object ID field, and the RecordRef of AllObject Table.
        EntityAttributeMapping.DeleteAll();

        RecRef.Open(Database::AllObj);
        RecRef.FindFirst();

        BindSubscription(LibraryUseCaseTests);
        LibraryUseCaseTests.Init(CaseID);

        EntityAttributeMapping.Init();
        EntityAttributeMapping."Attribute ID" := 1;
        EntityAttributeMapping."Attribute Name" := 'TableID';
        EntityAttributeMapping."Entity ID" := Database::AllObj;
        EntityAttributeMapping."Mapping Field ID" := AllObj.FieldNo("Object ID");
        EntityAttributeMapping.Insert();

        // [WHEN] function GetTaxAttributeValue is called
        UseCaseVariablesMgmt.GetTaxAttributeValue(CaseID, RecRef, 1, AttributeValue);

        // [THEN] Attribute Value should be equals to 3
        Assert.AreEqual(3, AttributeValue, 'Attribute Value 3 Expected');
        UnbindSubscription(LibraryUseCaseTests);
    end;

    [Test]
    procedure TestGetTaxAttributeValueGeneric()
    var
        TaxAttribute: Record "Tax Attribute";
        EntityAttributeMapping: Record "Entity Attribute Mapping";
        RecordAttributeMapping: Record "Record Attribute Mapping";
        UseCaseVariablesMgmt: Codeunit "Use Case Variables Mgmt.";
        LibraryUseCaseTests: Codeunit "Library - Use Case Tests";
        RecRef: RecordRef;
        CaseID: Guid;
        AttributeValue: Variant;
    begin
        // [SCENARIO] Get Attribute Value where Attribute is mapped to a generic attribute

        // [GIVEN] Attribute ID, and the RecordRef of AllObject Table.

        TaxAttribute.DeleteAll();
        EntityAttributeMapping.DeleteAll();
        RecordAttributeMapping.DeleteAll();

        RecRef.Open(Database::AllObj);
        RecRef.FindFirst();

        BindSubscription(LibraryUseCaseTests);
        LibraryUseCaseTests.Init(CaseID);

        TaxAttribute.Init();
        TaxAttribute."Tax Type" := 'XGST';
        TaxAttribute.ID := 1;
        TaxAttribute.Name := 'Test Attribute';
        TaxAttribute.Type := TaxAttribute.Type::Text;
        TaxAttribute.Insert();

        EntityAttributeMapping.Init();
        EntityAttributeMapping."Attribute ID" := 1;
        EntityAttributeMapping."Attribute Name" := 'Test Attribute';
        EntityAttributeMapping."Entity ID" := Database::AllObj;
        EntityAttributeMapping.INSERT();


        RecordAttributeMapping.Init();
        RecordAttributeMapping."Attribute ID" := 1;
        RecordAttributeMapping."Attribute Record ID" := RecRef.RecordId;
        RecordAttributeMapping."Attribute Value" := 'Hello';
        RecordAttributeMapping."Tax Type" := 'XGST';
        RecordAttributeMapping.Insert();

        // [WHEN] function GetTaxAttributeValue is called
        UseCaseVariablesMgmt.GetTaxAttributeValue(CaseID, RecRef, 1, AttributeValue);

        // [THEN] Attribute value Hello expected
        Assert.AreEqual('Hello', AttributeValue, 'Attribute Value Hello Expected');
        UnbindSubscription(LibraryUseCaseTests);
    end;
}