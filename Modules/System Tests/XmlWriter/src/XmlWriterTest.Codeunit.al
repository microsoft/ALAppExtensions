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
        VarXmlTextWriter: DotNet MRCXmlTextWriter;
        VarStringBuilder: DotNet MRCStringBuilder;
        VarStringWriter: DotNet MRCStringWriter;
        XmlBigText: BigText;
        ExpectedText: Text;
        LibraryAssert: Codeunit "Library Assert";
    begin
        // [GIVEN] The expected XmlText
        ExpectedText := GetXmlText();

        // [WHEN] Create an Xml Document with XmlWriter
        XmlWriterImpl.XmlWriterCreateDocument();
        XmlWriterImpl.XmlWriterStartElement('', 'export', '');
        XmlWriterImpl.XmlWriterStartElement('', 'meta', '');
        XmlWriterImpl.XmlWriterElementString('tableno', '5200');
        XmlWriterImpl.XmlWriterEndElement();
        XmlWriterImpl.XmlWriterStartElement('', 'employees', '');
        XmlWriterImpl.XmlWriterStartElement('', 'employee', '');
        XmlWriterImpl.XmlWriterAddAttribute('no', '123', 'n');
        XmlWriterImpl.XmlWriterAddAttribute('name', 'Angela', '');
        XmlWriterImpl.XmlWriterStartElement('', 'details', '');
        XmlWriterImpl.XmlWriterElementString('company', 'Mercash');
        XmlWriterImpl.XmlWriterElementString('city', 'Hoorn');
        XmlWriterImpl.XmlWriterEndElement();
        XmlWriterImpl.XmlWriterEndElement();
        XmlWriterImpl.XmlWriterEndElement();
        XmlWriterImpl.XmlWriterComment('This is an awesome module');
        XmlWriterImpl.XmlWriterEndElement();
        XmlWriterImpl.XmlWriterEndDocument();
        XmlWriterImpl.XmlWriterToBigText(XmlBigText);

        // [THEN] Verify Result 
        LibraryAssert.AreEqual(ExpectedText, FORMAT(XmlBigText), 'Unexpected text when creating a Xml Document with Xml Writer');
    end;

    procedure GetXmlText(): Text;
    begin
        Exit('<?xml version="1.0" encoding="utf-16"?><export><meta><tableno>5200</tableno></meta>' +
        '<employees><employee no="123" name="Angela"><details><company>Mercash</company><city>Hoorn</city></details></employee></employees>' +
        '<!--This is an awesome module--></export>')
    end;
}