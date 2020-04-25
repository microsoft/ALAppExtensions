codeunit 50102 "Xml Validation Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        XmlValidation: Codeunit "Xml Validation";
        XmlValidationTestLibrary: Codeunit "Xml Validation Test Library";

    [Test]
    procedure XmlValidationTest()
    var
        XmlValidation: Codeunit "Xml Validation";
        Xml, XmlSchema, Namespace, ErrorText : Text;
    begin
        // [GIVEN] A string representing an xml schema
        XmlSchema := XmlValidationTestLibrary.GetXmlSchema();

        // [GIVEN] A namespace
        Namespace := XmlValidationTestLibrary.GetNamespace();

        // [GIVEN] A string representing an xml document with a correctly applied schema
        Xml := XmlValidationTestLibrary.GetValidXml();

        // [WHEN] Validation is performed
        // [THEN] Validation is successful
        Assert.IsTrue(
            XmlValidation.ValidateAgainstSchema(Xml, XmlSchema, Namespace, ErrorText),
            'Xml should validate successfully.');

        // [GIVEN] A string representing an xml document with an incorrectly applied schema
        Xml := XmlValidationTestLibrary.GetInvalidXml();

        // [WHEN] Validation is performed
        // [THEN] Validation fails and error text is returned
        Assert.IsFalse(
            XmlValidation.ValidateAgainstSchema(Xml, XmlSchema, Namespace, ErrorText),
            'Xml shoud not validate successfully.');
    end;

}