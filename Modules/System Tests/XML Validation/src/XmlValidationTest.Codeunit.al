// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 135051 "Xml Validation Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        XmlValidationTestHelper: Codeunit "Xml Validation Test Helper";
        ValidationErrorTxt: Label 'The element ''bookstore'' in namespace ''http://www.contoso.com/books'' has invalid child element ''anotherNode''.';
        InvalidXmlErrTxt: Label 'The XML definition is invalid.';
        InvalidSchemaErrTxt: Label 'The schema definition is not valid XML.';

    [Test]
    procedure TestValidXml()
    var
        XmlValidation: Codeunit "Xml Validation";
        Xml, XmlSchema, Namespace : Text;
        Result: Boolean;
    begin
        // [GIVEN] A string representing an xml document with a correctly applied schema
        Xml := XmlValidationTestHelper.GetValidXml();

        // [GIVEN] A string representing an xml schema
        XmlSchema := XmlValidationTestHelper.GetXmlSchema();

        // [GIVEN] A namespace
        Namespace := XmlValidationTestHelper.GetNamespace();

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
        // [GIVEN] A string representing an xml document with an incorrectly applied schema
        Xml := XmlValidationTestHelper.GetInvalidXml();

        // [GIVEN] A string representing an xml schema
        XmlSchema := XmlValidationTestHelper.GetXmlSchema();

        // [GIVEN] A namespace
        Namespace := XmlValidationTestHelper.GetNamespace();

        // [WHEN] Validation is performed
        Result := XmlValidation.TryValidateAgainstSchema(Xml, XmlSchema, Namespace);

        // [THEN] Validation fails and error text is returned
        Assert.IsFalse(Result, 'Xml shoud not validate successfully.');
        Assert.ExpectedError(ValidationErrorTxt);
    end;

    [Test]
    procedure TestNonWellFormedXml()
    var
        XmlValidation: Codeunit "Xml Validation";
        Xml, XmlSchema, Namespace : Text;
        Result: Boolean;
    begin
        // [GIVEN] A string representing a non well-formed xml document
        Xml := XmlValidationTestHelper.GetValidXml();
        Xml := Xml.Replace('</book>', '');

        // [GIVEN] A string representing an xml schema
        XmlSchema := XmlValidationTestHelper.GetXmlSchema();

        // [GIVEN] A namespace
        Namespace := XmlValidationTestHelper.GetNamespace();


        // [WHEN] Validation is performed
        Result := XmlValidation.TryValidateAgainstSchema(Xml, XmlSchema, Namespace);

        // [THEN] Validation fails and error text is returned
        Assert.IsFalse(Result, 'Xml shoud not validate successfully.');
        Assert.ExpectedError(InvalidXmlErrTxt);
    end;

    [Test]
    procedure TestNonWellFormedSchemaXml()
    var
        XmlValidation: Codeunit "Xml Validation";
        Xml, XmlSchema, Namespace : Text;
        Result: Boolean;
    begin
        // [GIVEN] A string representing a xml document with an correctly applied schema
        Xml := XmlValidationTestHelper.GetValidXml();

        // [GIVEN] A string representing a non well-formed xml schema
        XmlSchema := XmlValidationTestHelper.GetXmlSchema();
        XmlSchema := XmlSchema.Replace('</xs:sequence>', '');

        // [GIVEN] A namespace
        Namespace := XmlValidationTestHelper.GetNamespace();

        // [WHEN] Validation is performed
        Result := XmlValidation.TryValidateAgainstSchema(Xml, XmlSchema, Namespace);

        // [THEN] Validation fails and error text is returned
        Assert.IsFalse(Result, 'Xml shoud not validate successfully.');
        Assert.ExpectedError(InvalidSchemaErrTxt);
    end;
}