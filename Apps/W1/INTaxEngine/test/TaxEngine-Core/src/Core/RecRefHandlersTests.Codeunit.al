codeunit 136701 "RecRef Handlers Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;
    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [RecRefHelper] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestSetFieldFilterCALFilter()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
    begin
        // [SCENARIO] Apply Filter on G/L Entry's 'Entry No.' field using RecordRef Variable.

        // [GIVEN] 'Entry No.' Filter Value 1..2.
        RecRef.Open(Database::"G/L Entry");

        // [WHEN] The function SetFieldFilter is called.
        RecRefHandler.SetFieldFilter(RecRef, 1, "Conditional Operator"::"CAL Filter", '1..2');

        // [THEN] It should apply filter on 'Entry No.' field with filter value 1.
        Assert.AreEqual(RecRef.Field(1).GetFilter, '1..2', 'Filter value should be 1..2');
    end;


    [Test]
    procedure TestSetFieldFilterEquals()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
    begin
        // [SCENARIO] Apply 'Equals' Filter on G/L Entry's 'Entry No.' field using RecordRef Variable.

        // [GIVEN]'Entry No.' Filter: 1.
        RecRef.Open(Database::"G/L Entry");

        // [WHEN] The function SetFieldFilter is called.
        RecRefHandler.SetFieldFilter(RecRef, 1, "Conditional Operator"::Equals, 1);

        // [THEN] It should apply filter on 'Entry No.' field with filter value 1.
        Assert.AreEqual(RecRef.Field(1).GetFilter, '1', 'Filter value should be equeals to 1');
    end;

    [Test]
    procedure TestSetFieldFilterNotEquals()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
    begin
        // [SCENARIO] Apply 'Not Equals' Filter on G/L Entry's 'Entry No.' field using RecordRef Variable.

        // [GIVEN] 'Entry No.' Filter: 1.
        RecRef.Open(Database::"G/L Entry");

        // [WHEN] The function SetFieldFilter is called.
        RecRefHandler.SetFieldFilter(RecRef, 1, "Conditional Operator"::"Not Equals", 1);

        // [THEN] It should apply filter on 'Entry No.' field with filter value <> 1.
        Assert.AreEqual(RecRef.Field(1).GetFilter, '<>1', 'Filter value should be not equal to 1');
    end;

    [Test]
    procedure TestSetFieldFilterIsLessThan()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
    begin
        // [SCENARIO] Apply 'Is Less Than' Filter on G/L Entry's 'Entry No.' field using RecordRef Variable.

        // [GIVEN] 'Entry No.' Filter : 1.
        RecRef.Open(Database::"G/L Entry");

        // [WHEN] The function SetFieldFilter is called.
        RecRefHandler.SetFieldFilter(RecRef, 1, "Conditional Operator"::"Is Less Than", 1);

        // [THEN] It should apply filter on 'Entry No.' field with filter value < 1.
        Assert.AreEqual(RecRef.Field(1).GetFilter, '<1', 'Filter value should be less than 1');
    end;


    [Test]
    procedure TestSetFieldFilterIsLessThanOrEqualsTo()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
    begin
        // [SCENARIO] Apply 'Is Less Than Or Equals To' Filter on G/L Entry's 'Entry No.' field using RecordRef Variable.

        // [GIVEN] 'Entry No.' Filter : 1.
        RecRef.Open(Database::"G/L Entry");

        // [WHEN] The function SetFieldFilter is called.
        RecRefHandler.SetFieldFilter(RecRef, 1, "Conditional Operator"::"Is Less Than Or Equals To", 1);

        // [THEN] It should apply filter on 'Entry No.' field with filter value <= 1.
        Assert.AreEqual(RecRef.Field(1).GetFilter, '<=1', 'Filter value should be less than or equals to 1');
    end;

    [Test]
    procedure TestSetFieldFilterIsGreaterThan()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
    begin
        // [SCENARIO] Apply 'Is Greater Than' Filter on G/L Entry's 'Entry No.' field using RecordRef Variable.

        // [GIVEN] 'Entry No.', Filter : 1.
        RecRef.Open(Database::"G/L Entry");

        // [WHEN] The function SetFieldFilter is called.
        RecRefHandler.SetFieldFilter(RecRef, 1, "Conditional Operator"::"Is Greater Than", 1);

        // [THEN] It should apply filter on 'Entry No.' field with filter value > 1.
        Assert.AreEqual(RecRef.Field(1).GetFilter, '>1', 'Filter value should be greater than 1');
    end;


    [Test]
    procedure TestSetFieldFilterIsGreaterThanOrEqualsTo()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
    begin
        // [SCENARIO] Apply 'Is Greater Than Or Equals To' Filter on G/L Entry's 'Entry No.' field using RecordRef Variable.

        // [GIVEN] 'Entry No.' Filter : 1.
        RecRef.Open(Database::"G/L Entry");

        // [WHEN] The function SetFieldFilter is called.
        RecRefHandler.SetFieldFilter(RecRef, 1, "Conditional Operator"::"Is Greater Than Or Equals To", 1);

        // [THEN] It should apply filter on 'Entry No.' field with filter value >= 1.
        Assert.AreEqual(RecRef.Field(1).GetFilter, '>=1', 'Filter value should be greater than or equals to 1');
    end;

    [Test]
    procedure TestSetFieldFilterBeginWith()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
    begin
        // [SCENARIO] Apply 'Begins With' Filter on G/L Account's 'No.' field using RecordRef Variable.

        // [GIVEN] 'No.' Filter Value: 'ABC'.
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function SetFieldFilter is called.
        RecRefHandler.SetFieldFilter(RecRef, 1, "Conditional Operator"::"Begins With", 'ABC');

        // [THEN] It should apply filter on 'No.' field with filter value ABC*.
        Assert.AreEqual(RecRef.Field(1).GetFilter, '%1*', 'Filter value should be %1*');
    end;

    [Test]
    procedure TestSetFieldFilterEndsWith()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
    begin
        // [SCENARIO] Apply 'Ends With' Filter on G/L Account's 'No.' field using RecordRef Variable.

        // [GIVEN] 'No.' Filter Value: 'ABC'.
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function SetFieldFilter is called.
        RecRefHandler.SetFieldFilter(RecRef, 1, "Conditional Operator"::"Ends With", 'ABC');

        // [THEN] It should apply filter on 'No.' field with filter value ABC*.
        Assert.AreEqual(RecRef.Field(1).GetFilter, '*%1', 'Filter value should be *%2');
    end;


    [Test]
    procedure TestSetFieldFilterContains()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
    begin
        // [SCENARIO] Apply 'Contains' Filter on G/L Account's 'No.' field using RecordRef Variable.

        // [GIVEN] 'No.' Filter Value: 'ABC'.
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function SetFieldFilter is called.
        RecRefHandler.SetFieldFilter(RecRef, 1, "Conditional Operator"::Contains, 'ABC');

        // [THEN] It should apply filter on 'No.' field with filter value *ABC*.
        Assert.AreEqual(RecRef.Field(1).GetFilter, '*%1*', 'Filter value should be *%1*');
    end;


    [Test]
    procedure TestSetFieldFilterDoesNotContain()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
    begin
        // [SCENARIO] Apply 'Does Not Contain' Filter on G/L Account's 'No.' field using RecordRef Variable.

        // [GIVEN] 'No.' Filter Value: 'ABC'.
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function SetFieldFilter is called.
        RecRefHandler.SetFieldFilter(RecRef, 1, "Conditional Operator"::"Does Not Contain", 'ABC');

        // [THEN] It should apply filter on 'No.' field with filter value <>*ABC*.
        Assert.AreEqual(RecRef.Field(1).GetFilter, '<>*%1*', 'Filter value should be <>*%1*');
    end;

    [Test]
    procedure TestSetFieldFilterDoesNotEndWith()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
    begin
        // [SCENARIO] Apply 'Does Not End With' Filter on G/L Account's 'No.' field using RecordRef Variable.

        // [GIVEN] 'No.' Filter Value: 'ABC'.
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function SetFieldFilter is called.
        RecRefHandler.SetFieldFilter(RecRef, 1, "Conditional Operator"::"Does Not End With", 'ABC');

        // [THEN] It should apply filter on 'No.' field with filter value <>*%1.
        Assert.AreEqual(RecRef.Field(1).GetFilter, '<>*%1', 'Filter value should be <>*%1');
    end;


    [Test]
    procedure TestSetFieldFilterContainsIgnoreCase()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
    begin
        // [SCENARIO] Apply 'Contains Ignore Case' Filter on G/L Account's 'No.' field using RecordRef Variable.

        // [GIVEN] 'No.' Filter Value: 'ABC'.
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function SetFieldFilter is called.
        RecRefHandler.SetFieldFilter(RecRef, 1, "Conditional Operator"::"Contains Ignore Case", 'ABC');

        // [THEN] It should apply filter on 'No.' field with filter value @*%1.
        Assert.AreEqual(RecRef.Field(1).GetFilter, '@*%1', 'Filter value should be @*%1');
    end;

    [Test]
    procedure TestSetFieldFilterEqualsIgnoreCase()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
    begin
        // [SCENARIO] Apply 'Equals Ignore Case' Filter on G/L Account's 'No.' field using RecordRef Variable.

        // [GIVEN] 'No.' Filter Value: 'ABC'
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function SetFieldFilter is called.
        RecRefHandler.SetFieldFilter(RecRef, 1, "Conditional Operator"::"Equals Ignore Case", 'ABC');

        // [THEN] It should apply filter on 'No.' field with filter value '@%1'.
        Assert.AreEqual(RecRef.Field(1).GetFilter, '@%1', 'Filter value should be @%1');
    end;

    [Test]
    procedure TestSetFieldLinkFilterWithConstOption()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        FilterType: Option "CONST","FILTER";
    begin
        // [SCENARIO] Apply CONST type Filter on G/L Account's 'No.' field using RecordRef Variable.

        // [GIVEN] 'No.' Filter Value: 'ABC'
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function SetFieldLinkFilter is called.
        RecRefHandler.SetFieldLinkFilter(RecRef, 1, FilterType::CONST, 'ABC');

        // [THEN] It should apply filter on 'No.' field with filter value '%1'.
        Assert.AreEqual(RecRef.Field(1).GetFilter, 'ABC', 'Filter value should be ABC');
    end;


    [Test]
    procedure TestSetFieldLinkFilterWithFilterOption()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        FilterType: Option "CONST","FILTER";
    begin
        // [SCENARIO] Apply FILTER type Filter on G/L Account's 'No.' field using RecordRef Variable.

        // [GIVEN] 'No.' Filter Value: 'A000..A999'
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function SetFieldLinkFilter is called.
        RecRefHandler.SetFieldLinkFilter(RecRef, 1, FilterType::FILTER, 'A000..A999');

        // [THEN] It should apply filter on 'No.' field with filter value 'A000..A999'
        Assert.AreEqual(RecRef.Field(1).GetFilter, 'A000..A999', 'Filter value should be A000..A999');
    end;

    [Test]
    procedure TestGetFieldValueNormal()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        FieldValue: Variant;
    begin
        // [SCENARIO] Get Field Value from G/L Account's 'No.' field.

        // [GIVEN] 'No.' field value 'A001'
        RecRef.Open(Database::"G/L Account");
        RecRef.Field(1).Value := 'A000';

        // [WHEN] The function GetFieldValue is called.
        RecRefHandler.GetFieldValue(RecRef, 1, FieldValue);

        // [THEN] It should return 'A000'.
        Assert.AreEqual(FieldValue, 'A000', 'Field value should be equals to A000');
    end;

    [Test]
    procedure TestGetFieldValueFlowField()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        FieldValue: Variant;
    begin
        // [SCENARIO] Get Field Value from a FlowField from G/L Account table'.

        // [GIVEN] Net Change field.
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function GetFieldValue is called.
        RecRefHandler.GetFieldValue(RecRef, 32, FieldValue);

        // [THEN] Should return Decimal Value.
        Assert.IsTrue(FieldValue.IsDecimal, 'Should return decimal value');
    end;

    [Test]
    procedure TestGetFieldValueBlobField()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        FieldValue: Variant;
    begin
        // [SCENARIO] Get Field Value from G/L Account's 'Picture' field.

        // [GIVEN] 'Net Change' field value 'A001'
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function GetFieldValue is called.
        RecRefHandler.GetFieldValue(RecRef, 46, FieldValue);

        // [THEN] FieldRef should be assigned to Field Value
        Assert.IsTrue(FieldValue.IsFieldRef, 'Field Value Should be FieldRef.');
    end;

    [Test]
    procedure TestSetFieldValueCodeType()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        FieldValue: Variant;
    begin
        // [SCENARIO] Set Field Value of G/L Account's 'No.' field.

        // [GIVEN] 'No.' field value 'A001'
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function SetFieldValue is called.
        RecRefHandler.SetFieldValue(RecRef, 1, 'A000');
        FieldValue := RecRef.Field(1).Value;

        // [THEN] It should assign field value 'A000'.
        Assert.AreEqual(FieldValue, 'A000', 'Field value should be equals to A000');
    end;

    [Test]
    procedure TestSetFieldValueTextType()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        FieldValue: Variant;
    begin
        // [SCENARIO] Set Field Value of G/L Account's 'Name' field.

        // [GIVEN] 'Name' field value 'A001'
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function SetFieldValue is called.
        RecRefHandler.SetFieldValue(RecRef, 2, 'A000');
        FieldValue := RecRef.Field(2).Value;

        // [THEN] It should assign field value 'A000'.
        Assert.AreEqual(FieldValue, 'A000', 'Field value should be equals to A000');
    end;

    [Test]
    procedure TestSetFieldValueNumberType()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        FieldValue: Variant;
    begin
        // [SCENARIO] Set Field Value of G/L Account's 'Indentation' field.

        // [GIVEN] 'Indentation' field value 100
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function SetFieldValue is called.
        RecRefHandler.SetFieldValue(RecRef, 19, 100);
        FieldValue := RecRef.Field(19).Value;

        // [THEN] It should assign field value 100.
        Assert.AreEqual(FieldValue, 100, 'Field value should be equals to 100');
    end;

    [Test]
    procedure TestSetFieldValueOptionType()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        FieldValue: Variant;
    begin
        // [SCENARIO] Set Field Value of G/L Account's Account Category field.

        // [GIVEN] 'Account Category' field value 6 - Expense
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function SetFieldValue is called.
        RecRefHandler.SetFieldValue(RecRef, 8, 6);
        FieldValue := RecRef.Field(8).Value;

        // [THEN] It should assign field value 6.
        Assert.AreEqual(FieldValue, 6, 'Field value should be equals to 6 - Expense');
    end;

    [Test]
    procedure TestSetFieldValueBooleanType()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        FieldValue: Variant;
    begin
        // [SCENARIO] Set Field Value of G/L Account's Direct Posting field.

        // [GIVEN] 'Direct Posting' field value true
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function SetFieldValue is called.
        RecRefHandler.SetFieldValue(RecRef, 14, true);
        FieldValue := RecRef.Field(14).Value;

        // [THEN] It should assign field value 6.
        Assert.AreEqual(FieldValue, true, 'Field value should be true');
    end;

    [Test]
    procedure TestSetFieldValueDateType()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        FieldValue: Variant;
    begin
        // [SCENARIO] Set Field Value of G/L Account's Last Date Modified field.

        // [GIVEN] 'Last Date Modified' field value with WorkDate
        RecRef.Open(Database::"G/L Account");

        // [WHEN] The function SetFieldValue is called.
        RecRefHandler.SetFieldValue(RecRef, 26, WorkDate());
        FieldValue := RecRef.Field(26).Value;

        // [THEN] It should assign field value WorkDate.
        Assert.AreEqual(FieldValue, WorkDate(), 'Field value should be equal to WorkDate');
    end;

    [Test]
    procedure TestSetFieldValueDateTimeType()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        FieldValue: Variant;
        DateTimeValue: DateTime;
    begin
        // [SCENARIO] Set Field Value of G/L Account's Last Modified Date Time field.        

        // [GIVEN] 'Last Modified Date Time' field value with CurrentDateTime
        RecRef.Open(Database::"G/L Account");
        DateTimeValue := CurrentDateTime;

        // [WHEN] The function SetFieldValue is called.
        RecRefHandler.SetFieldValue(RecRef, 25, DateTimeValue);
        FieldValue := RecRef.Field(25).Value;

        // [THEN] It should assign field value CurrentDateTime.
        Assert.AreEqual(FieldValue, DateTimeValue, 'Field value should be equal to CurrentDateTime');
    end;

    [Test]
    procedure TestSetFieldValueTimeType()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        FieldValue: Variant;
        TimeValue: Time;
    begin
        // [SCENARIO] Set Field Value of Script Symbol Value's Time Value field.

        // [GIVEN] 'Time Value' field value with Current Time
        RecRef.Open(Database::"Script Symbol Value");
        TimeValue := Time();

        // [WHEN] The function SetFieldValue is called.
        RecRefHandler.SetFieldValue(RecRef, 105, TimeValue);
        FieldValue := RecRef.Field(105).Value;

        // [THEN] Field value should contain Current Time.
        Assert.AreEqual(FieldValue, TimeValue, 'Field value should be equal to Current Time');
    end;


    [Test]
    procedure TestSetFieldValueGuidType()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        FieldValue: Variant;
        GuidValue: Guid;
    begin
        // [SCENARIO] Set Field Value of Script Symbol Value's Guid Value field.

        // [GIVEN] Assigned 'Guid Value' field value with a new Guid
        RecRef.Open(Database::"Script Symbol Value");
        GuidValue := CreateGuid();

        // [WHEN] The function SetFieldValue is called.
        RecRefHandler.SetFieldValue(RecRef, 112, GuidValue);
        FieldValue := RecRef.Field(112).Value;

        // [THEN] Field value should contain the newly generated Guid.
        Assert.AreEqual(FieldValue, GuidValue, 'Field value should match with the Guid generated.');
    end;

    [Test]
    procedure TestSetFieldValueRecordIDType()
    var
        AllObj: Record AllObj;
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        RecordIDValue: RecordId;
        FieldValue: Variant;
    begin
        // [SCENARIO] Set Field Value of Script Symbol Value's RecordID Value field.

        // [GIVEN] Assigned 'RecordID Value' field value with G/L Account's first Record ID
        AllObj.FindFirst();
        RecordIDValue := AllObj.RecordId();
        RecRef.Open(Database::"Script Symbol Value");

        // [WHEN] The function SetFieldValue is called.
        RecRefHandler.SetFieldValue(RecRef, 113, RecordIDValue);
        FieldValue := RecRef.Field(113).Value;

        // [THEN] Field value should contain G/L Account's first Record ID.
        Assert.AreEqual(FieldValue, RecordIDValue, 'Field value should match with AllObj first Record ID.');
    end;

    [Test]
    procedure TestSetFieldValueDurationType()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        DFValue: DateFormula;
        FieldValue: Variant;
    begin
        // [SCENARIO] Set Field Value of Payment Terms's Due Date Calculation field.

        // [GIVEN] Assigned 'Due Date Calculation' field value with '1Y'
        Evaluate(DFValue, '1Y');
        RecRef.Open(Database::"Payment Terms");

        // [WHEN] The function SetFieldValue is called.
        RecRefHandler.SetFieldValue(RecRef, 2, DFValue);
        FieldValue := RecRef.Field(2).Value;

        // [THEN] Field value should be 1Y
        Assert.AreEqual(FieldValue, DFValue, 'Field value should be 1Y');
    end;

    [Test]
    procedure TestSetFieldValueDurationTextType()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        DFValue: DateFormula;
        FieldValue: Variant;
    begin
        // [SCENARIO] Set Field Value of Payment Terms's Due Date Calculation field.

        // [GIVEN] Assigned 'Due Date Calculation' field value with '1Y'
        evaluate(DFValue, '1Y');
        RecRef.Open(Database::"Payment Terms");

        // [WHEN] The function SetFieldValue is called.
        RecRefHandler.SetFieldValue(RecRef, 2, '1Y');
        FieldValue := RecRef.Field(2).Value;

        // [THEN] Field value should be 1Y
        Assert.AreEqual(FieldValue, DFValue, 'Field value should be 1Y');
    end;

    [Test]
    procedure TestVariantToRecRefWithRecord()
    var
        GLAccount: Record "G/L Account";
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        SourceRecord: Variant;
    begin
        // [SCENARIO] Convert Variant to RecordRef, Variant value can be Record or RecordRef.

        // [GIVEN] SourceRecord variant with 'G/L Account' table;
        SourceRecord := GLAccount;

        // [WHEN] The function VariantToRecRef is called.
        RecRefHandler.VariantToRecRef(SourceRecord, RecRef);

        // [THEN] Table Number should be G/L Account.
        Assert.AreEqual(RecRef.Number, Database::"G/L Account", 'RecordRef''s Table Number should be G/L Account');
    end;

    [Test]
    procedure TestVariantToRecRefWithRecordRef()
    var
        RecRefHandler: Codeunit "RecRef Handler";
        GLAccountRecRef: RecordRef;
        RecRef: RecordRef;
        SourceRecord: Variant;
    begin
        // [SCENARIO] Convert Variant to RecordRef, Variant value can be Record or RecordRef.

        // [GIVEN] SourceRecord variant with 'G/L Account' table;
        GLAccountRecRef.Open(Database::"G/L Account");
        SourceRecord := GLAccountRecRef;

        // [WHEN] The function VariantToRecRef is called.
        RecRefHandler.VariantToRecRef(SourceRecord, RecRef);

        // [THEN] Table Number should be G/L Account.
        Assert.AreEqual(RecRef.Number, Database::"G/L Account", 'RecordRef''s Table Number should be G/L Account');
    end;

    [Test]
    procedure TestVariantToRecRefWithRecordID()
    var
        AllObj: Record AllObj;
        RecRefHandler: Codeunit "RecRef Handler";
        RecRef: RecordRef;
        SourceRecord: Variant;
    begin
        // [SCENARIO] Convert Variant to RecordRef, Variant value can be Record or RecordRef.

        // [GIVEN] SourceRecord variant with 'G/L Account' table;
        AllObj.FindFirst();
        SourceRecord := AllObj.RecordId;

        // [WHEN] The function VariantToRecRef is called.
        RecRefHandler.VariantToRecRef(SourceRecord, RecRef);

        // [THEN] Table Number should be G/L Account.
        Assert.AreEqual(RecRef.Number, Database::AllObj, 'RecordRef''s Table Number should be AllObj');
    end;
}