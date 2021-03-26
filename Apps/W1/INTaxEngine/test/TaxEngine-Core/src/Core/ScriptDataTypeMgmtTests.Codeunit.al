codeunit 136702 "Script Data Type Mgmt. Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [RecRefHelper] [UT]
    end;

    var
        Assert: Codeunit Assert;
        OptionStringErr: Label 'option string should be %1', Comment = '%1 = Option string';

    [Test]
    procedure TestGetFieldDatatype()
    var
        AllObj: Record AllObj;
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        DataType: Enum "Symbol Data Type";
    begin
        // [SCENARIO] Get Symbol Data Type from Table Field.
        // [GIVEN] AllObj Table ID, and Field ID 3 i.e. Object ID

        // [WHEN] The function GetFieldDatatype is called.
        DataType := ScriptDataTypeMgmt.GetFieldDatatype(Database::AllObj, AllObj.FieldNo("Object ID"));

        // [THEN] It should return NUMBER Data Type.
        Assert.AreEqual(DataType, "Symbol Data Type"::NUMBER, 'DataType should be Number');
    end;

    [Test]
    procedure TestIsNumber()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        IntegerText: Boolean;
        DecimalText: Boolean;
        TextText: Boolean;
    begin
        // [SCENARIO] Check given text is a number.
        // [GIVEN] Integer, Decimal, Text as parameter

        // [WHEN] The function IsNumber is called.
        IntegerText := ScriptDataTypeMgmt.IsNumber('100');
        DecimalText := ScriptDataTypeMgmt.IsNumber('10.10');
        TextText := ScriptDataTypeMgmt.IsNumber('Hello');

        // [THEN] It should return true for Integer, Decimal, and false for Text
        Assert.IsTrue(IntegerText, 'IsNumber should return true for 100');
        Assert.IsTrue(DecimalText, 'IsNumber should return true for 10.10');
        Assert.IsFalse(TextText, 'IsNumber should return false for Hello');
    end;

    [Test]
    procedure TestIsBoolean()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TrueResult: Boolean;
        FalseResult: Boolean;
        YesResult: Boolean;
        TextResult: Boolean;
    begin
        // [SCENARIO] Check given text is a boolean.

        // [GIVEN] Integer, Decimal, Text as parameter
        TrueResult := ScriptDataTypeMgmt.IsBoolean('true');
        FalseResult := ScriptDataTypeMgmt.IsBoolean('false');
        YesResult := ScriptDataTypeMgmt.IsBoolean('Yes');
        YesResult := ScriptDataTypeMgmt.IsBoolean('No');
        TextResult := ScriptDataTypeMgmt.IsBoolean('Hello');

        // [WHEN] The function IsBoolean is called.
        Assert.IsTrue(TrueResult, 'IsBoolean should return true for True');
        Assert.IsTrue(FalseResult, 'IsBoolean should return true for False');
        Assert.IsTrue(YesResult, 'IsBoolean should return true for Yes');
        Assert.IsTrue(YesResult, 'IsBoolean should return true for No');
        Assert.IsFalse(TextResult, 'IsBoolean should return false for Text');
    end;

    [Test]
    procedure TestIsRecID()
    var
        AllObj: Record AllObj;
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        RecIDText: Text;
        ValidRecIDResult: Boolean;
        TextResult: Boolean;
    begin
        // [SCENARIO] Check given text is RecordID.

        // [GIVEN] A Valid RecordID, and a junk a value
        AllObj.FindFirst();
        RecIDText := Format(AllObj.RecordId());

        // [WHEN] The function IsRecID is called.
        ValidRecIDResult := ScriptDataTypeMgmt.IsRecID(RecIDText);
        TextResult := ScriptDataTypeMgmt.IsRecID('Hello');

        // [THEN] It should return true if the text is a valid RecordID
        Assert.IsTrue(ValidRecIDResult, 'IsRecID should return true for valid RecordID text');
        Assert.IsFalse(TextResult, 'IsRecID should return false for Text');
    end;

    [Test]
    procedure TestIsTime()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TimeText: Text;
        ValidTimeResult: Boolean;
        TextResult: Boolean;
    begin
        // [SCENARIO] Check given text is Time or not.

        // [GIVEN] A Valid Time value
        TimeText := Format(Time());

        // [WHEN] The function IsTime is called.
        ValidTimeResult := ScriptDataTypeMgmt.IsTime(TimeText);
        TextResult := ScriptDataTypeMgmt.IsTime('Hello');

        // [WHEN] The function IsTime is called.
        Assert.IsTrue(ValidTimeResult, 'IsTime should return true for valid Time');
        Assert.IsFalse(TextResult, 'IsTime should return false for Text');
    end;

    [Test]
    procedure TestIsDateTime()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        DateTimeText: Text;
        ValidDateTimeResult: Boolean;
        TextResult: Boolean;
    begin
        // [SCENARIO] Check given text is DateTime or not.

        // [GIVEN] A Valid DateTime value
        DateTimeText := Format(CurrentDateTime(), 0, 2);

        // [WHEN] The function IsDateTime is called.
        ValidDateTimeResult := ScriptDataTypeMgmt.IsDateTime(DateTimeText);
        TextResult := ScriptDataTypeMgmt.IsDateTime('Hello');

        // [THEN] It should return true if the text is a valid DateTime
        Assert.IsTrue(ValidDateTimeResult, 'IsDateTime should return true for valid DateTime');
        Assert.IsFalse(TextResult, 'IsDateTime should return false for Text');
    end;

    [Test]
    procedure TestIsGUID()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        GuidText: Text;
        ValidGuidResult: Boolean;
        TextResult: Boolean;
    begin
        // [SCENARIO] Check given text is Guid or not.

        // [GIVEN] A Valid Guid value
        GuidText := Format(CreateGuid());

        // [WHEN] The function IsGUID is called.
        ValidGuidResult := ScriptDataTypeMgmt.IsGUID(GuidText);
        TextResult := ScriptDataTypeMgmt.IsGUID('Hello');

        // [THEN] It should return true if the text is a valid GUID
        Assert.IsTrue(ValidGuidResult, 'IsGUID should return true for valid GUID');
        Assert.IsFalse(TextResult, 'IsGUID should return false for Text');
    end;

    [Test]
    procedure TestIsOption()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        OptionString: Text;
        OptionValue: Text;
        ValidOptionResult: Boolean;
        TextResult: Boolean;
    begin
        // [SCENARIO] Check given text is a valid option in an option string

        // [GIVEN] A Valid Option value
        OptionString := ' ,Order,Invoice';
        OptionValue := 'Order';

        // [WHEN] The function IsOption is called.
        ValidOptionResult := ScriptDataTypeMgmt.IsOption(OptionValue, OptionString);
        TextResult := ScriptDataTypeMgmt.IsOption('Hello', OptionString);

        // [THEN] It should return true if the text is a valid Option
        Assert.IsTrue(ValidOptionResult, 'IsOption should return true for valid Option Value');
        Assert.IsFalse(TextResult, 'IsOption should return false for Text');
    end;

    [Test]
    procedure TestIsBlob()
    var
        GLAccount: Record "G/L Account";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        RecRef: RecordRef;
        PictureField: Variant;
        NoField: Variant;

        ValidBlobResult: Boolean;
        TextResult: Boolean;
    begin
        // [SCENARIO] Check given text is a valid Blob

        // [GIVEN] A Valid Blob value
        RecRef.Open(Database::"G/L Account");
        NoField := RecRef.Field(GLAccount.FieldNo("No."));
        PictureField := RecRef.Field(GLAccount.FieldNo(Picture));

        // [WHEN] The function IsBlob is called.
        ValidBlobResult := ScriptDataTypeMgmt.IsBlob(PictureField);
        TextResult := ScriptDataTypeMgmt.IsBlob(NoField);

        // [THEN] It should return true if the text is a valid Blob
        Assert.IsTrue(ValidBlobResult, 'IsBlob should return true for valid Blob field');
        Assert.IsFalse(TextResult, 'IsOption should return false for other fields');
    end;

    [Test]
    procedure TestText2Number()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TextValue: Text;
        Result: Decimal;
    begin
        // [SCENARIO] Convert Text to Number

        // [GIVEN] A Number Value as text
        TextValue := '100';

        // [WHEN] The function Text2Number is called.
        Result := ScriptDataTypeMgmt.Text2Number(TextValue);

        // [THEN] It should return Number value
        Assert.AreEqual(Result, 100, 'Return value should be 100');
    end;

    [Test]
    procedure TestText2Boolean()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TextValue: Text;
        Result: Boolean;
    begin
        // [SCENARIO] Convert Text to Boolean

        // [GIVEN] A Boolean Value as text
        TextValue := 'TRUE';

        // [WHEN] The function Text2Boolean is called.
        Result := ScriptDataTypeMgmt.Text2Boolean(TextValue);

        // [THEN] It should return Boolean value
        Assert.AreEqual(Result, true, 'Return value should be true');
    end;

    [Test]
    procedure TestText2Date()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TextValue: Text;
        Result: Date;
    begin
        // [SCENARIO] Convert Text to Date

        // [GIVEN] A Date Value as text
        TextValue := Format(WorkDate(), 0, 9);

        // [WHEN] The function Text2Date is called.
        Result := ScriptDataTypeMgmt.Text2Date(TextValue);

        // [THEN] It should return Date value
        Assert.AreEqual(Result, WorkDate(), 'Return value should be equal to work date');
    end;

    [Test]
    procedure TestText2Time()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TextValue: Text;
        Result: Time;
        TempTime: Time;
    begin
        // [SCENARIO] Convert Text to Time

        // [GIVEN] A Time Value as text
        TempTime := Time();
        TextValue := Format(TempTime, 0, 9);

        // [WHEN] The function Text2Time is called.
        Result := ScriptDataTypeMgmt.Text2Time(TextValue);

        // [THEN] It should return Time value
        Assert.AreEqual(Result, TempTime, 'Return value should be equal to Time');
    end;

    [Test]
    procedure TestText2DateTime()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TextValue: Text;
        Result: DateTime;
        TempDateTime: DateTime;
    begin
        // [SCENARIO] Convert Text to DateTime

        // [GIVEN] A DateTime Value as text
        TempDateTime := CurrentDateTime();
        TextValue := Format(TempDateTime);

        // [WHEN] The function Text2DateTime is called.
        Result := ScriptDataTypeMgmt.Text2DateTime(TextValue);

        // [THEN] It should return DateTime value
        Assert.AreEqual(Result, TempDateTime, 'Return value should be equal to DateTime');
    end;

    [Test]
    procedure TestText2GUID()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TextValue: Text;
        Result: Guid;
        TempGuid: Guid;
    begin
        // [SCENARIO] Convert Text to Guid

        // [GIVEN] A Guid Value as text
        TempGuid := CreateGuid();
        TextValue := Format(TempGuid);

        // [WHEN] The function Text2Guid is called.
        Result := ScriptDataTypeMgmt.Text2GUID(TextValue);

        // [THEN] It should return Guid value
        Assert.AreEqual(Result, TempGuid, 'Return value should be equal to Guid');
    end;

    [Test]
    procedure TestText2RecordID()
    var
        AllObj: Record AllObj;
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        Result: RecordId;
        TempRecID: RecordId;
        TextValue: Text;
    begin
        // [SCENARIO] Convert Text to RecordID

        // [GIVEN] A RecordID Value as text
        AllObj.FindFirst();
        TempRecID := AllObj.RecordId();
        TextValue := Format(TempRecID);

        // [WHEN] The function Text2RecordID is called.
        ScriptDataTypeMgmt.Text2RecordID(TextValue, Result);

        // [THEN] It should assign RecordID to RecordID parameter.
        Assert.AreEqual(Result, TempRecID, 'Result be equal to RecordID');
    end;

    [Test]
    procedure TestVariant2TextWithText()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        VariantValue: Variant;
        Result: Text;
    begin
        // [SCENARIO] Convert Variant to Text

        // [GIVEN] A Text as Variant
        VariantValue := 'Text';

        // [WHEN] The function Variant2Text is called.
        Result := ScriptDataTypeMgmt.Variant2Text(VariantValue, '');

        // [THEN] It should return text value
        Assert.AreEqual(Result, 'Text', 'Return value should be ''Text''');
    end;

    [Test]
    procedure TestVariant2TextWithFieldRef()
    var
        AllObj: Record AllObj;
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        RecRef: RecordRef;
        VariantValue: Variant;
        FieldValue: Text;
        Result: Text;
    begin
        // [SCENARIO] Convert Variant to Text

        // [GIVEN] A Text as Variant
        RecRef.Open(Database::AllObj);
        RecRef.FindFirst();
        VariantValue := RecRef.Field(AllObj.FieldNo("Object Name"));
        FieldValue := RecRef.Field(AllObj.FieldNo("Object Name")).Value();

        // [WHEN] The function Variant2Text is called.
        Result := ScriptDataTypeMgmt.Variant2Text(VariantValue, '');

        // [THEN] It should return text value
        Assert.AreEqual(Result, FieldValue, 'Return value should match with FieldValue');
    end;

    [Test]
    procedure TestVariant2TextWithBlobFieldRef()
    var
        ScriptSymbolValue: Record "Script Symbol Value";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        RecRef: RecordRef;
        BlobFieldRef: FieldRef;
        VariantValue: Variant;
        TextToWrite: Text;
        Result: Text;
    begin
        // [SCENARIO] Convert Variant to Text

        // [GIVEN] A Text as Variant
        TextToWrite := 'Hello';
        RecRef.Open(Database::"Script Symbol Value");
        BlobFieldRef := RecRef.Field(ScriptSymbolValue.FieldNo("Text Value"));
        ScriptDataTypeMgmt.Text2BLOB(TextToWrite, BlobFieldRef);
        VariantValue := BlobFieldRef;

        // [WHEN] The function Variant2Text is called.
        Result := ScriptDataTypeMgmt.Variant2Text(VariantValue, '');

        // [THEN] It should return text value
        Assert.AreEqual(Result, TextToWrite, 'Return value should be Hello');
    end;

    [Test]
    procedure TestVariant2OptionWithText()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        OptionString: Text;
        VariantValue: Variant;
        Result: Option;
    begin
        // [SCENARIO] Convert Variant to Option

        // [GIVEN] A Option Value as Variant
        OptionString := ' ,Quote,Order,Invoice';
        VariantValue := 'Order';

        // [WHEN] The function Variant2Text is called.
        ScriptDataTypeMgmt.Variant2Option(VariantValue, OptionString, Result);

        // [THEN] It should Option Index to the Result
        Assert.AreEqual(Result, 2, 'Option Value should be 2 - Order');
    end;

    [Test]
    procedure TestVariant2OptionWithOptionNo()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        OptionString: Text;
        VariantValue: Variant;
        Result: Option;
    begin
        // [SCENARIO] Convert Variant to Option

        // [GIVEN] A Option Value as Variant
        OptionString := ' ,Quote,Order,Invoice';
        VariantValue := 2;

        // [WHEN] The function Variant2Option is called.
        ScriptDataTypeMgmt.Variant2Option(VariantValue, OptionString, Result);

        // [THEN] It should Option Index to the Result
        Assert.AreEqual(Result, 2, 'Option Value should be 2 - Order');
    end;

    [Test]
    procedure TestVariant2NumberWithText()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        VariantValue: Variant;
        Result: Decimal;
    begin
        // [SCENARIO] Convert Variant to Number

        // [GIVEN] A Number Value as Variant
        VariantValue := '100';

        // [WHEN] The function Variant2Number is called.
        Result := ScriptDataTypeMgmt.Variant2Number(VariantValue);

        // [THEN] It should return number
        Assert.AreEqual(Result, 100, 'Number Value should be 100');
    end;

    [Test]
    procedure TestVariant2NumberWithNumber()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        VariantValue: Variant;
        Result: Decimal;
    begin
        // [SCENARIO] Convert Variant to Number

        // [GIVEN] A Number Value as Variant
        VariantValue := 100;

        // [WHEN] The function Variant2Number is called.
        Result := ScriptDataTypeMgmt.Variant2Number(VariantValue);

        // [THEN] It should return number
        Assert.AreEqual(Result, 100, 'Number Value should be 100');
    end;

    [Test]
    procedure TestVariant2BooleanWithText()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        VariantValue: Variant;
        Result: Boolean;
    begin
        // [SCENARIO] Convert Variant to Boolean

        // [GIVEN] A Boolean Value as Variant
        VariantValue := 'Yes';

        // [WHEN] The function Variant2Boolean is called.
        Result := ScriptDataTypeMgmt.Variant2Boolean(VariantValue);

        // [THEN] It should return boolean value
        Assert.AreEqual(Result, true, 'Boolean Value should be true');
    end;

    [Test]
    procedure TestVariant2BooleanWithBoolean()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        VariantValue: Variant;
        Result: Boolean;
    begin
        // [SCENARIO] Convert Variant to Boolean

        // [GIVEN] A Boolean Value as Variant
        VariantValue := true;

        // [WHEN] The function Variant2Boolean is called.
        Result := ScriptDataTypeMgmt.Variant2Boolean(VariantValue);

        // [THEN] It should return boolean value
        Assert.AreEqual(Result, true, 'Boolean Value should be true');
    end;

    [Test]
    procedure TestVariant2DateWithText()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        VariantValue: Variant;
        Result: Date;
    begin
        // [SCENARIO] Convert Variant to Date

        // [GIVEN] A Date Value as Variant
        VariantValue := Format(WorkDate(), 0, 9);

        // [WHEN] The function Variant2Date is called.
        Result := ScriptDataTypeMgmt.Variant2Date(VariantValue);

        // [THEN] It should return date value
        Assert.AreEqual(Result, WorkDate(), 'Date Value should be equals to WorkDate');
    end;

    [Test]
    procedure TestVariant2DateWithDate()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        VariantValue: Variant;
        Result: Date;
    begin
        // [SCENARIO] Convert Variant to Date

        // [GIVEN] A Date Value as Variant
        VariantValue := WorkDate();

        // [WHEN] The function Variant2Date is called.
        Result := ScriptDataTypeMgmt.Variant2Date(VariantValue);

        // [THEN] It should return date value
        Assert.AreEqual(Result, WorkDate(), 'Date Value should be equals to WorkDate');
    end;

    [Test]
    procedure TestVariant2TimeWithText()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        VariantValue: Variant;
        Result: Time;
        CurrTime: Time;
    begin
        // [SCENARIO] Convert Variant to Time

        // [GIVEN] A Time Value as Variant
        CurrTime := Time();
        VariantValue := Format(CurrTime, 0, 9);

        // [WHEN] The function Variant2Time is called.
        Result := ScriptDataTypeMgmt.Variant2Time(VariantValue);

        // [THEN] It should return time value
        Assert.AreEqual(Result, CurrTime, 'Time Value should be equals to Current Time');
    end;

    [Test]
    procedure TestVariant2TimeWithTime()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        VariantValue: Variant;
        Result: Time;
        CurrTime: Time;
    begin
        // [SCENARIO] Convert Variant to Time

        // [GIVEN] A Time Value as Variant
        CurrTime := Time();
        VariantValue := CurrTime;

        // [WHEN] The function Variant2Time is called.
        Result := ScriptDataTypeMgmt.Variant2Time(VariantValue);

        // [THEN] It should return time value
        Assert.AreEqual(Result, CurrTime, 'Time Value should be equals to Current Time');
    end;

    [Test]
    procedure TestVariant2DateTimeWithText()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        VariantValue: Variant;
        Result: DateTime;
        CurrDateTime: DateTime;
    begin
        // [SCENARIO] Convert Variant to DateTime

        // [GIVEN] A DateTime Value as Variant
        CurrDateTime := CurrentDateTime();
        VariantValue := Format(CurrDateTime);

        // [WHEN] The function Variant2DateTime is called.
        Result := ScriptDataTypeMgmt.Variant2DateTime(VariantValue);

        // [THEN] It should return date time value
        Assert.AreEqual(Result, CurrDateTime, 'DateTime Value should be equals to Current Date Time');
    end;

    [Test]
    procedure TestVariant2DateTimeWithDateTime()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        VariantValue: Variant;
        Result: DateTime;
        CurrDateTime: DateTime;
    begin
        // [SCENARIO] Convert Variant to DateTime

        // [GIVEN] A DateTime Value as Variant
        CurrDateTime := CurrentDateTime();
        VariantValue := CurrDateTime;

        // [WHEN] The function Variant2DateTime is called.
        Result := ScriptDataTypeMgmt.Variant2DateTime(VariantValue);

        // [THEN] It should return date time value
        Assert.AreEqual(Result, CurrDateTime, 'DateTime Value should be equals to Current Date Time');
    end;

    [Test]
    procedure TestVariant2GUDWithText()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        VariantValue: Variant;
        Result: Guid;
        TempGuid: Guid;
    begin
        // [SCENARIO] Convert Variant to GUID

        // [GIVEN] A GUID Value as Variant
        TempGuid := Format(CreateGuid());
        VariantValue := TempGuid;

        // [WHEN] The function Variant2GUID is called.
        Result := ScriptDataTypeMgmt.Variant2GUID(VariantValue);

        // [THEN] It should return GUID value
        Assert.AreEqual(Result, TempGuid, 'GUID Value should be equals to newly created ID');
    end;

    [Test]
    procedure TestVariant2GUDWithGUID()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        VariantValue: Variant;
        Result: Guid;
        TempGuid: Guid;
    begin
        // [SCENARIO] Convert Variant to GUID

        // [GIVEN] A GUID Value as Variant
        TempGuid := CreateGuid();
        VariantValue := TempGuid;

        // [WHEN] The function Variant2GUID is called.
        Result := ScriptDataTypeMgmt.Variant2GUID(VariantValue);

        // [THEN] It should return GUID value
        Assert.AreEqual(Result, TempGuid, 'GUID Value should be equals to newly created ID');
    end;

    [Test]
    procedure TestVariant2RecordIDWithText()
    var
        AllObj: Record AllObj;
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        Result: RecordID;
        TempRecordID: RecordID;
        VariantValue: Variant;
    begin
        // [SCENARIO] Convert Variant to RecordID

        // [GIVEN] A RecordID Value as Variant
        AllObj.FindFirst();
        TempRecordID := AllObj.RecordId();
        VariantValue := Format(TempRecordID);

        // [WHEN] The function Variant2RecordID is called.
        ScriptDataTypeMgmt.Variant2RecordID(VariantValue, Result);

        // [THEN] It should assign RecordID to ReportID parameter
        Assert.AreEqual(Result, TempRecordID, 'RecordID Value should be equals to TempRecordID');
    end;

    [Test]
    procedure TestVariant2RecordIDWithRecordID()
    var
        AllObj: Record AllObj;
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        Result: RecordID;
        TempRecordID: RecordID;
        VariantValue: Variant;
    begin
        // [SCENARIO] Convert Variant to RecordID

        // [GIVEN] A RecordID Value as Variant
        AllObj.FindFirst();
        TempRecordID := AllObj.RecordId();
        VariantValue := TempRecordID;

        // [WHEN] The function Variant2RecordID is called.
        ScriptDataTypeMgmt.Variant2RecordID(VariantValue, Result);

        // [THEN] It should assign RecordID to ReportID parameter
        Assert.AreEqual(Result, TempRecordID, 'RecordID Value should be equals to TempRecordID');
    end;

    [Test]
    procedure TestGetOptionText()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        Result: Text;
        OptionString: Text;
    begin
        // [SCENARIO] Get Option Text from an Index

        // [GIVEN] Option Index
        OptionString := ' ,Quote,Order,Invoice';

        // [WHEN] The function GetOptionText is called.
        Result := ScriptDataTypeMgmt.GetOptionText(OptionString, 2);

        // [THEN] It should return Option Text
        Assert.AreEqual(Result, 'Order', 'OptionText should be Order');
    end;

    [Test]
    procedure TestGetFieldOptionString()
    var
        AllObj: Record AllObj;
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        Result: Text;
        OptionString: Text;
    begin
        // [SCENARIO] Get Option String from a Table Field
        // [GIVEN] Table - AllObj and Field - Objet Type

        // [WHEN] The function GetFieldOptionString is called.
        OptionString := ScriptDataTypeMgmt.GetFieldOptionString(Database::AllObj, AllObj.FieldNo("Object Type"));
        Result := ScriptDataTypeMgmt.GetOptionText(OptionString, 0);

        // [THEN] It should return Option String
        Assert.AreEqual(Result, 'TableData', 'First Option Value should be TableData');
    end;

    [Test]
    procedure TestGetFieldOptionText()
    var
        AllObj: Record AllObj;
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        Result: Text;
    begin
        // [SCENARIO] Get Option Text from a Table Field at an Index
        // [GIVEN] Table - AllObj and Field - Objet Type, Index - 0

        // [WHEN] The function GetFieldOptionText is called.
        Result := ScriptDataTypeMgmt.GetFieldOptionText(Database::AllObj, AllObj.FieldNo("Object Type"), 0);

        // [THEN] It should return Option Text - TableData
        Assert.AreEqual(Result, 'TableData', 'First Option Value should be TableData');
    end;

    [Test]
    procedure TestGetFieldOptionIndex()
    var
        AllObj: Record AllObj;
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        Result: Integer;
    begin
        // [SCENARIO] Get Option Index from a Table Field for an Option Text

        // [GIVEN] Table - AllObj and Field - Objet Type, Text - TableData
        Result := -1;

        // [WHEN] The function GetFieldOptionIndex is called.
        Result := ScriptDataTypeMgmt.GetFieldOptionIndex(Database::AllObj, AllObj.FieldNo("Object Type"), 'TableData');

        // [THEN] It should return Option Index - TableData
        Assert.AreEqual(Result, 0, 'Option Index should be 0 (TableData)');
    end;

    [Test]
    procedure TestGetOptionTextList()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        OptionString: Text;
        OptionList: List of [Text];
    begin
        // [SCENARIO] Convert OptionString to List of Text

        // [GIVEN] OptionString - ' ,Quote,Order,Invoice'
        OptionString := ' ,Quote,Order,Invoice';

        // [WHEN] The function GetOptionTextList is called.
        ScriptDataTypeMgmt.GetOptionTextList(OptionString, OptionList);

        // [THEN] It should assign list variable with all options populated
        Assert.AreEqual(OptionList.Count, 4, 'There should be 4 items in the list');
        Assert.AreEqual(OptionList.Get(1), ' ', '1st Item should be blank');
        Assert.AreEqual(OptionList.Get(2), 'Quote', '2nd should be Quote');
        Assert.AreEqual(OptionList.Get(3), 'Order', '3rd Item should be Order');
        Assert.AreEqual(OptionList.Get(4), 'Invoice', 'Last Item should be Invoice');
    end;

    [Test]
    procedure TestText2BLOB()
    var
        ScriptSymbolValue: Record "Script Symbol Value";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        RecRef: RecordRef;
        BlobFieldRef: FieldRef;
        TextToWrite: Text;
    begin
        // [SCENARIO] Write text to Blob

        // [GIVEN] Text to write
        TextToWrite := 'Hello';
        RecRef.Open(Database::"Script Symbol Value");
        BlobFieldRef := RecRef.Field(ScriptSymbolValue.FieldNo("Text Value"));

        // [WHEN] The function Text2BLOB is called.
        ScriptDataTypeMgmt.Text2BLOB(TextToWrite, BlobFieldRef);

        // [THEN] It should write Text into Blob field
        Assert.AreEqual(ReadBlob(BlobFieldRef), TextToWrite, 'Blob Text should match');
    end;

    [Test]
    procedure TestGetTokensFromStringExpression()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TextTokens: List of [Text];
        StringExpression: Text;
    begin
        // [SCENARIO] Get the list of Tokens enclosed with curly braces 

        // [GIVEN] String Expression with Tokens
        StringExpression := 'Hello, {Name}. You have {Amount} in your account.';

        // [WHEN] The function GetTokensFromStringExpression is called.
        ScriptDataTypeMgmt.GetTokensFromStringExpression(StringExpression, TextTokens);

        // [THEN] It should return List of Text Tokens
        Assert.AreEqual(TextTokens.Count, 2, 'There should be 2 items in the list');
        Assert.AreEqual(TextTokens.Get(1), 'Name', '1st Item should be Name');
        Assert.AreEqual(TextTokens.Get(2), 'Amount', '2nd should be Amount');
    end;


    [Test]
    procedure TestEvaluateStringExpression()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        Values: Dictionary of [Text, Text];
        StringExpression: Text;
        ExpectedResult: Text;
        Result: Text;
    begin
        // [SCENARIO] Evaluates String Expression by replacing Tokens with Values

        // [GIVEN] String Expression, and Token Values
        StringExpression := 'Hello, {Name}. You have {Amount} in your account.';
        Values.Add('Name', 'Dummy Name');
        Values.Add('Amount', '10000');
        ExpectedResult := 'Hello, Dummy Name. You have 10000 in your account.';

        // [WHEN] The function EvaluateStringExpression is called.
        Result := ScriptDataTypeMgmt.EvaluateStringExpression(StringExpression, Values);

        // [THEN] It should return new string
        Assert.AreEqual(Result, ExpectedResult, 'Evaluated String must match with the Expected String');
    end;

    [Test]
    procedure TestGetTokensFromNumberExpression()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TextTokens: List of [Text];
        StringExpression: Text;
    begin
        // [SCENARIO] Get the list of Tokens in a number expression

        // [GIVEN] Number Expression with Tokens
        StringExpression := '((Amount / 100) * Percent) +  Amount2 - Discount';

        // [WHEN] The function GetTokensFromNumberExpression is called.
        ScriptDataTypeMgmt.GetTokensFromNumberExpression(StringExpression, TextTokens);

        // [THEN] It should return List of Text Tokens
        Assert.AreEqual(TextTokens.Count, 4, 'There should be 2 items in the list');
        Assert.AreEqual(TextTokens.Get(1), 'Amount', '1st Item should be Amount');
        Assert.AreEqual(TextTokens.Get(2), 'Percent', '2nd should be Percent');
        Assert.AreEqual(TextTokens.Get(3), 'Amount2', '3rd should be Amount2');
        Assert.AreEqual(TextTokens.Get(4), 'Discount', '4th should be Discount');
    end;

    [Test]
    procedure TestEvaluateExpression()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        Values: Dictionary of [Text, Decimal];
        StringExpression: Text;
        Result: Decimal;
    begin
        // [SCENARIO] Evaluate Expression into a number

        // [GIVEN] Number Expression with Token Values
        StringExpression := '((Amount / 100) * Percent) +  Amount2 - Discount';
        Values.Add('Amount', 100);
        Values.Add('Percent', 50);
        Values.Add('Amount2', 500);
        Values.Add('Discount', 250);

        // [WHEN] The function GetTokensFromNumberExpression is called.
        Result := ScriptDataTypeMgmt.EvaluateExpression(StringExpression, Values);

        // [THEN] It should return List of Text Tokens
        Assert.AreEqual(Result, 300, 'Evaluated Value should be 300');
    end;

    [Test]
    procedure TestConvertText2Type()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        DateText: Text;
        NumberResult: Variant;
        OptionResult: Variant;
        BooleanResult: Variant;
        DateResult: Variant;
        StringResult: Variant;
    begin
        // [SCENARIO] Convert Text to a value of different DataType 

        // [GIVEN] Text Value
        DateText := Format(WorkDate(), 0, 9);

        // [WHEN] The function ConvertText2Type is called.
        ScriptDataTypeMgmt.ConvertText2Type('100', "Symbol Data Type"::NUMBER, '', NumberResult);
        ScriptDataTypeMgmt.ConvertText2Type('Invoice', "Symbol Data Type"::OPTION, 'Order,Invoice', OptionResult);
        ScriptDataTypeMgmt.ConvertText2Type('Yes', "Symbol Data Type"::BOOLEAN, '', BooleanResult);
        ScriptDataTypeMgmt.ConvertText2Type(DateText, "Symbol Data Type"::DATE, '', DateResult);
        ScriptDataTypeMgmt.ConvertText2Type('Hello', "Symbol Data Type"::STRING, '', StringResult);

        // [THEN] It should assign converted Value to Converted Value parameter
        Assert.IsTrue(NumberResult.IsDecimal(), 'Result should be number type');
        Assert.IsTrue(OptionResult.IsInteger(), 'Result should be integer type');
        Assert.IsTrue(BooleanResult.IsBoolean(), 'Result should be boolean type');
        Assert.IsTrue(DateResult.IsDate(), 'Result should be date type');
        Assert.IsTrue(StringResult.IsText(), 'Result should be text type');
        // [THEN] It should assign converted Value to Converted Value parameter
        Assert.AreEqual(NumberResult, 100, 'Result should be equals to number 100');
        Assert.AreEqual(OptionResult, 1, 'Result should be equals to option index 1');
        Assert.IsTrue(BooleanResult, 'Result should be boolean - true');
        Assert.AreEqual(DateResult, WorkDate(), 'Result should be equals to WorkDate');
        Assert.AreEqual(StringResult, 'Hello', 'Result should be text Hello');
    end;

    [Test]
    procedure TestSetConstantValue()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        DateText: Text;
        NumberResult: Variant;
        OptionResult: Variant;
        BooleanResult: Variant;
        DateResult: Variant;
        StringResult: Variant;
    begin
        // [SCENARIO] Sets value to Variant after converting Text to Datatype

        // [GIVEN] Datatype, Text Value
        DateText := Format(WorkDate(), 0, 9);

        // [WHEN] The function SetConstantValue is called.
        ScriptDataTypeMgmt.SetConstantValue("Symbol Data Type"::NUMBER, '100', '', NumberResult);
        ScriptDataTypeMgmt.SetConstantValue("Symbol Data Type"::OPTION, 'Invoice', 'Order,Invoice', OptionResult);
        ScriptDataTypeMgmt.SetConstantValue("Symbol Data Type"::BOOLEAN, 'Yes', '', BooleanResult);
        ScriptDataTypeMgmt.SetConstantValue("Symbol Data Type"::DATE, DateText, '', DateResult);
        ScriptDataTypeMgmt.SetConstantValue("Symbol Data Type"::STRING, 'Hello', '', StringResult);

        // [THEN] It should assign converted value to value parameter.
        Assert.IsTrue(NumberResult.IsDecimal(), 'Result should be number type');
        Assert.IsTrue(OptionResult.IsInteger(), 'Result should be integer type');
        Assert.IsTrue(BooleanResult.IsBoolean(), 'Result should be boolean type');
        Assert.IsTrue(DateResult.IsDate(), 'Result should be date type');
        Assert.IsTrue(StringResult.IsText(), 'Result should be text type');
        // [THEN] It should assign converted value to value parameter.
        Assert.AreEqual(NumberResult, 100, 'Result should be equals to number 100');
        Assert.AreEqual(OptionResult, 1, 'Result should be equals to option index 1');
        Assert.IsTrue(BooleanResult, 'Result should be boolean - true');
        Assert.AreEqual(DateResult, WorkDate(), 'Result should be equals to WorkDate');
        Assert.AreEqual(StringResult, 'Hello', 'Result should be text Hello');
    end;

    [Test]
    procedure TestIsPrimitiveDatatype()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        NumberResult: Boolean;
        OptionResult: Boolean;
        BooleanResult: Boolean;
        DateResult: Boolean;
        StringResult: Boolean;
    begin
        // [SCENARIO] Check given data type is primitive
        // [GIVEN] Datatype

        // [WHEN] The function IsPrimitiveDatatype is called.
        BooleanResult := ScriptDataTypeMgmt.IsPrimitiveDatatype("Symbol Data Type"::BOOLEAN);
        DateResult := ScriptDataTypeMgmt.IsPrimitiveDatatype("Symbol Data Type"::DATE);
        NumberResult := ScriptDataTypeMgmt.IsPrimitiveDatatype("Symbol Data Type"::NUMBER);
        OptionResult := ScriptDataTypeMgmt.IsPrimitiveDatatype("Symbol Data Type"::OPTION);
        StringResult := ScriptDataTypeMgmt.IsPrimitiveDatatype("Symbol Data Type"::STRING);

        // [THEN] It should return true, if the data type if primitive
        Assert.IsTrue(NumberResult, 'Result should be true');
        Assert.IsTrue(OptionResult, 'Result should be true');
        Assert.IsTrue(BooleanResult, 'Result should be true');
        Assert.IsTrue(DateResult, 'Result should be true');
        Assert.IsTrue(StringResult, 'Result should be true');
    end;

    [Test]
    procedure TestCheckConstantDatatype()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        DateText: Text;
    begin
        // [SCENARIO] Checks the datatype of the constant value

        // [THEN] It should not throw any error.

        // [GIVEN] Constant Value, Datatype
        DateText := Format(WorkDate(), 0, 9);

        // [WHEN] The function CheckConstantDatatype is called.
        ScriptDataTypeMgmt.CheckConstantDatatype('Yes', "Symbol Data Type"::BOOLEAN, '');
        ScriptDataTypeMgmt.CheckConstantDatatype(DateText, "Symbol Data Type"::DATE, '');
        ScriptDataTypeMgmt.CheckConstantDatatype('100', "Symbol Data Type"::NUMBER, '');
        ScriptDataTypeMgmt.CheckConstantDatatype('Invoice', "Symbol Data Type"::OPTION, 'Order,Invoice');
        ScriptDataTypeMgmt.CheckConstantDatatype('Hello', "Symbol Data Type"::STRING, '');
    end;

    [Test]
    procedure TestConvertLocalToXmlFormatForDate()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TextValue: Text;
        ExpectedResult: Text;
        Result: Text;
    begin
        // [SCENARIO] Converts local format to XML format

        // [GIVEN] Text in local format
        TextValue := Format(WorkDate());
        ExpectedResult := Format(WorkDate(), 0, 9);

        // [WHEN] The function ConvertLocalToXmlFormat is called.
        Result := ScriptDataTypeMgmt.ConvertLocalToXmlFormat(TextValue, "Symbol Data Type"::DATE);

        // [THEN] It should return text value in XML format
        Assert.AreEqual(Result, ExpectedResult, 'Text should be converted to XML Format');
    end;

    [Test]
    procedure TestConvertLocalToXmlFormatForNumber()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TextValue: Text;
        ExpectedResult: Text;
        Result: Text;
    begin
        // [SCENARIO] Converts local format to XML format

        // [GIVEN] Text in local format
        TextValue := Format(100);
        ExpectedResult := Format(100, 0, 9);

        // [WHEN] The function ConvertLocalToXmlFormat is called.
        Result := ScriptDataTypeMgmt.ConvertLocalToXmlFormat(TextValue, "Symbol Data Type"::NUMBER);

        // [THEN] It should return text value in XML format
        Assert.AreEqual(Result, ExpectedResult, 'Text should be converted to XML Format');
    end;

    [Test]
    procedure TestConvertLocalToXmlFormatForBoolean()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TextValue: Text;
        ExpectedResult: Text;
        Result: Text;
    begin
        // [SCENARIO] Converts local format to XML format

        // [GIVEN] Text in local format 
        TextValue := Format(true);
        ExpectedResult := Format(true, 0, 9);

        // [WHEN] The function ConvertLocalToXmlFormat is called.
        Result := ScriptDataTypeMgmt.ConvertLocalToXmlFormat(TextValue, "Symbol Data Type"::BOOLEAN);

        // [THEN] It should return text value in XML format
        Assert.AreEqual(Result, ExpectedResult, 'Text should be converted to XML Format');
    end;

    [Test]
    procedure TestConvertLocalToXmlFormatForDateTime()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        CurrDateTime: DateTime;
        TextValue: Text;
        ExpectedResult: Text;
        Result: Text;
    begin
        // [SCENARIO] Converts local format to XML format

        // [GIVEN] Text in local format 
        Evaluate(CurrDateTime, '2020-01-31 12:30');
        TextValue := Format(CurrDateTime);
        ExpectedResult := Format(CurrDateTime, 0, 9);

        // [WHEN] The function ConvertLocalToXmlFormat is called.
        Result := ScriptDataTypeMgmt.ConvertLocalToXmlFormat(TextValue, "Symbol Data Type"::DATETIME);

        // [THEN] It should return text value in XML format
        Assert.AreEqual(Result, ExpectedResult, 'Text should be converted to XML Format');
    end;

    [Test]
    procedure TestConvertLocalToXmlFormatForTime()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        CurrTime: Time;
        TextValue: Text;
        ExpectedResult: Text;
        Result: Text;
    begin
        // [SCENARIO] Converts local format to XML format

        // [GIVEN] Text in local format
        Evaluate(CurrTime, '12:30PM');
        TextValue := Format(CurrTime);
        ExpectedResult := Format(CurrTime, 0, 9);

        // [WHEN] The function ConvertLocalToXmlFormat is called.
        Result := ScriptDataTypeMgmt.ConvertLocalToXmlFormat(TextValue, "Symbol Data Type"::TIME);

        // [THEN] It should return text value in XML format
        Assert.AreEqual(Result, ExpectedResult, 'Text should be converted to XML Format');
    end;

    [Test]
    procedure TestConvertLocalToXmlFormatForGuid()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TempGuid: Guid;
        TextValue: Text;
        ExpectedResult: Text;
        Result: Text;
    begin
        // [SCENARIO] Converts local format to XML format

        // [GIVEN] Text in local format 
        TempGuid := CreateGuid();
        TextValue := Format(TempGuid);
        ExpectedResult := Format(TempGuid, 0, 9);

        // [WHEN] The function ConvertLocalToXmlFormat is called.
        Result := ScriptDataTypeMgmt.ConvertLocalToXmlFormat(TextValue, "Symbol Data Type"::Guid);

        // [THEN] It should return text value in XML format
        Assert.AreEqual(Result, ExpectedResult, 'Text should be converted to XML Format');
    end;

    [Test]
    procedure TestConvertLocalToXmlFormatForRecID()
    var
        AllObj: Record AllObj;
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TempRecID: RecordID;
        TextValue: Text;
        ExpectedResult: Text;
        Result: Text;
    begin
        // [SCENARIO] Converts local format to XML format

        // [GIVEN] Text in local format
        AllObj.FindFirst();
        TempRecID := AllObj.RecordId();
        TextValue := Format(TempRecID);
        ExpectedResult := Format(TempRecID, 0, 9);

        // [WHEN] The function ConvertLocalToXmlFormat is called.
        Result := ScriptDataTypeMgmt.ConvertLocalToXmlFormat(TextValue, "Symbol Data Type"::RECID);

        // [THEN] It should return text value in XML format
        Assert.AreEqual(Result, ExpectedResult, 'Text should be converted to XML Format');
    end;

    [Test]
    procedure TestConvertXmlToLocalFormatForRecID()
    var
        AllObj: Record AllObj;
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TempRecID: RecordID;
        TextValue: Text;
        ExpectedResult: Text;
        Result: Text;
    begin
        // [SCENARIO] Converts XML format to local format

        // [GIVEN] Text in XML format 
        AllObj.FindFirst();
        TempRecID := AllObj.RecordId();
        TextValue := Format(TempRecID, 0, 9);
        ExpectedResult := Format(TempRecID);

        // [WHEN] The function ConvertXmlToLocalFormat is called.
        Result := ScriptDataTypeMgmt.ConvertXmlToLocalFormat(TextValue, "Symbol Data Type"::RECID);

        // [THEN] It should return text value in local format
        Assert.AreEqual(Result, ExpectedResult, 'Text should be converted to local format');
    end;

    [Test]
    procedure TestConvertXmlToLocalFormatForDate()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        CurrDate: Date;
        TextValue: Text;
        ExpectedResult: Text;
        Result: Text;
    begin
        // [SCENARIO] Converts XML format to local format

        // [GIVEN] Text in local format  
        CurrDate := WorkDate();
        TextValue := Format(CurrDate, 0, 9);
        ExpectedResult := Format(CurrDate);

        // [WHEN] The function ConvertXmlToLocalFormat is called.
        Result := ScriptDataTypeMgmt.ConvertXmlToLocalFormat(TextValue, "Symbol Data Type"::DATE);

        // [THEN] It should return text value in local format
        Assert.AreEqual(Result, ExpectedResult, 'Text should be converted to local format');
    end;

    [Test]
    procedure TestConvertXmlToLocalFormatForNumber()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        NumberValue: Decimal;
        TextValue: Text;
        ExpectedResult: Text;
        Result: Text;
    begin
        // [SCENARIO] Converts XML format to local format

        // [GIVEN] Text in local format
        NumberValue := 100;
        TextValue := Format(NumberValue, 0, 9);
        ExpectedResult := Format(NumberValue, 0, '<Precision,2:3><Standard Format,0>');

        // [WHEN] The function ConvertXmlToLocalFormat is called.
        Result := ScriptDataTypeMgmt.ConvertXmlToLocalFormat(TextValue, "Symbol Data Type"::NUMBER);

        // [THEN] It should return text value in local format
        Assert.AreEqual(Result, ExpectedResult, 'Text should be converted to local format');
    end;

    [Test]
    procedure TestConvertXmlToLocalFormatForBoolean()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TextValue: Text;
        ExpectedResult: Text;
        Result: Text;
    begin
        // [SCENARIO] Converts XML format to local format

        // [GIVEN] Text in local format
        TextValue := Format(true, 0, 9);
        ExpectedResult := Format(true);

        // [WHEN] The function ConvertXmlToLocalFormat is called.
        Result := ScriptDataTypeMgmt.ConvertXmlToLocalFormat(TextValue, "Symbol Data Type"::BOOLEAN);

        // [THEN] It should return text value in local format
        Assert.AreEqual(Result, ExpectedResult, 'Text should be converted to local format');
    end;

    [Test]
    procedure TestConvertXmlToLocalFormatForDateTime()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TempDateTime: DateTime;
        TextValue: Text;
        ExpectedResult: Text;
        Result: Text;
    begin
        // [SCENARIO] Converts XML format to local format

        // [GIVEN] Text in local format 
        Evaluate(TempDateTime, '2020-01-31 12:30');
        TextValue := Format(TempDateTime, 0, 9);
        ExpectedResult := Format(TempDateTime);

        // [WHEN] The function ConvertXmlToLocalFormat is called.
        Result := ScriptDataTypeMgmt.ConvertXmlToLocalFormat(TextValue, "Symbol Data Type"::DATETIME);

        // [THEN] It should return text value in local format
        Assert.AreEqual(Result, ExpectedResult, 'Text should be converted to local format');
    end;


    [Test]
    procedure TestConvertXmlToLocalFormatForTime()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TempTime: Time;
        TextValue: Text;
        ExpectedResult: Text;
        Result: Text;
    begin
        // [SCENARIO] Converts XML format to local format

        // [GIVEN] Text in local format
        Evaluate(TempTime, '12:30');
        TextValue := Format(TempTime, 0, 9);
        ExpectedResult := Format(TempTime);

        // [WHEN] The function ConvertXmlToLocalFormat is called.
        Result := ScriptDataTypeMgmt.ConvertXmlToLocalFormat(TextValue, "Symbol Data Type"::TIME);

        // [THEN] It should return text value in local format
        Assert.AreEqual(Result, ExpectedResult, 'Text should be converted to local format');
    end;

    [Test]
    procedure TestConvertXmlToLocalFormatForGuid()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        TempGuid: Guid;
        TextValue: Text;
        ExpectedResult: Text;
        Result: Text;
    begin
        // [SCENARIO] Converts XML format to local format

        // [GIVEN] Text in local format
        TempGuid := CreateGuid();
        TextValue := Format(TempGuid, 0, 9);
        ExpectedResult := Format(TempGuid);

        // [WHEN] The function ConvertXmlToLocalFormat is called.
        Result := ScriptDataTypeMgmt.ConvertXmlToLocalFormat(TextValue, "Symbol Data Type"::GUID);

        // [THEN] It should return text value in local format
        Assert.AreEqual(Result, ExpectedResult, 'Text should be converted to local format');
    end;

    [Test]
    procedure TestFormatAttributeValueForDecimal()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        DataType: Option Option,Text,Integer,Decimal,Boolean,Date;
        NumberValue: Decimal;
        TextValue: Text[250];
        ExpectedResult: Text;
    begin
        // [SCENARIO] Formats Attribute Value Text

        // [GIVEN] Text in local format
        NumberValue := 100;
        TextValue := Format(NumberValue);
        ExpectedResult := Format(NumberValue, 0, '<Precision,2:3><Standard Format,0>');

        // [WHEN] The function FormatAttributeValue is called.
        ScriptDataTypeMgmt.FormatAttributeValue(DataType::Decimal, TextValue);

        // [THEN] It should return text value in attribute format
        Assert.AreEqual(TextValue, ExpectedResult, 'Text should be converted to attribute format');
    end;

    [Test]
    procedure TestFormatAttributeValueForInteger()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        DataType: Option Option,Text,Integer,Decimal,Boolean,Date;
        TextValue: Text[250];
        ExpectedResult: Text;
    begin
        // [SCENARIO] Formats Attribute Value Text

        // [GIVEN] Text in local format
        TextValue := '100';
        ExpectedResult := Format(100);

        // [WHEN] The function FormatAttributeValue is called.
        ScriptDataTypeMgmt.FormatAttributeValue(DataType::Integer, TextValue);

        // [THEN] It should return text value in attribute format
        Assert.AreEqual(TextValue, ExpectedResult, 'Text should be converted to attribute format');
    end;

    [Test]
    procedure TestFormatAttributeValueForBoolean()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        DataType: Option Option,Text,Integer,Decimal,Boolean,Date;
        TextValue: Text[250];
        ExpectedResult: Text;
    begin
        // [SCENARIO] Formats Attribute Value Text

        // [GIVEN] Text in local format
        TextValue := 'true';
        ExpectedResult := Format(true);

        // [WHEN] The function FormatAttributeValue is called.
        ScriptDataTypeMgmt.FormatAttributeValue(DataType::Boolean, TextValue);

        // [THEN] It should return text value in attribute format
        Assert.AreEqual(TextValue, ExpectedResult, 'Text should be converted to attribute format');
    end;

    [Test]
    procedure TestFormatAttributeValueForDate()
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        DataType: Option Option,Text,Integer,Decimal,Boolean,Date;
        TextValue: Text[250];
        ExpectedResult: Text;
    begin
        // [SCENARIO] Formats Attribute Value Text

        // [GIVEN] Text in local format
        TextValue := Format(WorkDate(), 0, 9);
        ExpectedResult := Format(WorkDate());

        // [WHEN] The function FormatAttributeValue is called.
        ScriptDataTypeMgmt.FormatAttributeValue(DataType::Date, TextValue);

        // [THEN] It should return text value in attribute format
        Assert.AreEqual(TextValue, ExpectedResult, 'Text should be converted to attribute format');
    end;

    [Test]
    procedure TestGetLookupOptionString()
    var
        SalesHeader: Record "Sales Header";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        CaseID, ScriptID, LookupID : Guid;
        ExpectedResult, ActualResult : Text;
    begin
        // [SCENARIO] Get OptionString from a Lookup

        // [GIVEN] LookupID reference
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Header");
        FieldRef := RecRef.Field(SalesHeader.FieldNo(Status));
        ExpectedResult := FieldRef.OptionMembers;
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::"Current Record");

        // [WHEN] The function GetLookupOptionString is called.
        ActualResult := ScriptDataTypeMgmt.GetLookupOptionString(CaseID, ScriptID, LookupID);

        // [THEN] It should return OptionString from the Lookup field
        Assert.AreEqual(ExpectedResult, ActualResult, StrSubstNo(OptionStringErr, ExpectedResult));
    end;

    [Test]
    procedure TestGetLookupOptionStringWithSymbolTable()
    var
        SalesHeader: Record "Sales Header";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        LibraryScriptSymbolLookup: Codeunit "Library - Script Symbol Lookup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        TableMethod: Option " ",First,Last,"Sum","Average","Min","Max","Count","Exist";
        CaseID, ScriptID, LookupID : Guid;
        ExpectedResult, ActualResult : Text;
    begin
        // [SCENARIO] Get OptionString from a Lookup

        // [GIVEN] LookupID reference
        CaseID := CreateGuid();
        ScriptID := CreateGuid();
        RecRef.Open(Database::"Sales Header");
        FieldRef := RecRef.Field(SalesHeader.FieldNo(Status));
        ExpectedResult := FieldRef.OptionMembers;
        LookupID := LibraryScriptSymbolLookup.CreateLookup(CaseID, ScriptID, RecRef.Number, FieldRef.Number, "Symbol Type"::Table, TableMethod::First);

        // [WHEN] The function GetLookupOptionString is called.
        ActualResult := ScriptDataTypeMgmt.GetLookupOptionString(CaseID, ScriptID, LookupID);

        // [THEN] It should return OptionString from the Lookup field
        Assert.AreEqual(ExpectedResult, ActualResult, StrSubstNo(OptionStringErr, ExpectedResult));
    end;

    local procedure ReadBlob(var FldRef: FieldRef): Text
    var
        TempBlob: Codeunit "Temp Blob";
        IStream: InStream;
        BlobText: Text;
    begin
        TempBlob.FromFieldRef(FldRef);
        TempBlob.CreateInStream(IStream, TEXTENCODING::UTF8);
        IStream.ReadText(BlobText);
        exit(BlobText);
    end;
}