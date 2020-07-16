// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 11111567 "Xml Writer Test"
{
    Subtype = Test;

    var
        XmlWriterImpl: Codeunit "XmlWriter Impl.";

    [Test]
    procedure TestXmlWriter()
    var
        VarXmlTextWriter: DotNet XmlTextWriter;
        VarStringBuilder: DotNet StringBuilder;
        VarStringWriter: DotNet StringWriter;
        XmlBigText: BigText;
        ExpectedText: Text;
        LibraryAssert: Codeunit "Library Assert";
    begin
        // [GIVEN] The expected XmlText
        ExpectedText := GetXmlText();

        // [WHEN] Create an Xml Document with XmlWriter
        XmlWriterImpl.XmlWriterCreateDocument();
        XmlWriterImpl.WriteStartElement('', 'export', '');
        XmlWriterImpl.WriteStartElement('', 'meta', '');
        XmlWriterImpl.WriteAttributeString('mt', 'type', '', 'test');
        XmlWriterImpl.WriteElementString('tableno', '5200');
        XmlWriterImpl.WriteEndElement();
        XmlWriterImpl.WriteStartElement('', 'employees', '');
        XmlWriterImpl.WriteStartElement('', 'employee', '');
        XmlWriterImpl.WriteAttributeString('no', '123');
        XmlWriterImpl.WriteAttributeString('name', 'Angela');
        XmlWriterImpl.WriteStartElement('', 'details', '');
        XmlWriterImpl.WriteElementString('company', 'Mercash');
        XmlWriterImpl.WriteElementString('city', 'Hoorn');
        XmlWriterImpl.WriteEndElement();
        XmlWriterImpl.WriteEndElement();
        XmlWriterImpl.WriteEndElement();
        XmlWriterImpl.WriteComment('This is an awesome module');
        XmlWriterImpl.WriteEndElement();
        XmlWriterImpl.WriteEndDocument();
        XmlWriterImpl.XmlWriterToBigText(XmlBigText);

        // [THEN] Verify Result 
        LibraryAssert.AreEqual(ExpectedText, FORMAT(XmlBigText), 'Unexpected text when creating a Xml Document with Xml Writer');
    end;

    procedure GetXmlText(): Text;
    begin
        Exit('<?xml version="1.0" encoding="utf-16"?><export><meta type="test"><tableno>5200</tableno></meta>' +
        '<employees><employee no="123" name="Angela"><details><company>Mercash</company><city>Hoorn</city></details></employee></employees>' +
        '<!--This is an awesome module--></export>')
    end;
}