codeunit 50102 "Xml Validation Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        XmlValidation: Codeunit "Xml Validation";
        XmlValidationTestHelper: Codeunit "Xml Validation Test Helper";
        ValidationErrorTxt: Label 'A call to System.Xml.XmlDocument.Validate failed with this message: The element ''bookstore'' in namespace ''http://www.contoso.com/books'' has invalid child element ''anotherNode''.';

    [Test]
    procedure TestValidXml()
    var
        XmlValidation: Codeunit "Xml Validation";
        Xml, XmlSchema, Namespace : Text;
        Result: Boolean;
    begin
        // [GIVEN] A string representing an xml schema
        XmlSchema := XmlValidationTestHelper.GetXmlSchema();

        // [GIVEN] A namespace
        Namespace := XmlValidationTestHelper.GetNamespace();

        // [GIVEN] A string representing an xml document with a correctly applied schema
        Xml := XmlValidationTestHelper.GetValidXml();

        // [WHEN] Validation is performed
        Result := XmlValidation.TryValidateAgainstSchema(Xml, XmlSchema, Namespace);

        // [THEN] Validation is successful and no error text is returned
        Assert.IsTrue(Result, 'Xml should validate successfully.');
    end;

    [Test]
    procedure TestInvalidXml()
    var
        XmlValidation: Codeunit "Xml Validation";
        Xml, XmlSchema, Namespace : Text;
        Result: Boolean;
    begin
        // [GIVEN] A string representing an xml schema
        XmlSchema := XmlValidationTestHelper.GetXmlSchema();

        // [GIVEN] A namespace
        Namespace := XmlValidationTestHelper.GetNamespace();

        // [GIVEN] A string representing an xml document with an incorrectly applied schema
        Xml := XmlValidationTestHelper.GetInvalidXml();

        // [WHEN] Validation is performed
        Result := XmlValidation.TryValidateAgainstSchema(Xml, XmlSchema, Namespace);

        // [THEN] Validation fails and error text is returned
        Assert.IsFalse(Result, 'Xml shoud not validate successfully.');
        Assert.ExpectedError(ValidationErrorTxt);
    end;
}