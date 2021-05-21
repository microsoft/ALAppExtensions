// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139911 "Xml Writer Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure TestAllXmlWriter()
    var
        XmlWriter: Codeunit XmlWriter;
        XmlBigText: BigText;
    begin
        // [GIVEN] Create an Xml Document with XmlWriter
        XmlWriter.WriteStartDocument();
        XmlWriter.WriteStartElement('export');
        XmlWriter.WriteStartElement('meta');
        XmlWriter.WriteAttributeString('mt', 'type', '', 'test');
        XmlWriter.WriteElementString('tableno', '5200');
        XmlWriter.WriteEndElement();
        XmlWriter.WriteStartElement('employees');
        XmlWriter.WriteStartElement('employee');
        XmlWriter.WriteAttributeString('no', '123');
        XmlWriter.WriteAttributeString('name', 'Angela');
        XmlWriter.WriteStartElement('details');
        XmlWriter.WriteElementString('company', 'Mercash');
        XmlWriter.WriteElementString('city', 'Hoorn');
        XmlWriter.WriteStartElement('occupation');
        XmlWriter.WriteString('Software Developer');
        XmlWriter.WriteEndElement();
        XmlWriter.WriteEndElement();
        XmlWriter.WriteEndElement();
        XmlWriter.WriteEndElement();
        XmlWriter.WriteComment('This is an awesome module');
        XmlWriter.WriteEndElement();
        XmlWriter.WriteEndDocument();
        XmlWriter.ToBigText(XmlBigText);

        // [THEN] Verify Result 
        Assert.AreEqual(GetXmlText(), Format(XmlBigText), 'Unexpected text when creating a Xml Document with XmlWriter');
    end;

    [Test]
    procedure TestWriteStartDocument()
    var
        XmlWriter: Codeunit "XmlWriter";
        XmlBigText: BigText;
    begin
        // [GIVEN] Initialized XmlWriter
        XmlWriter.WriteStartDocument();

        // [THEN] Get XmlDocument to text
        XmlWriter.ToBigText(XmlBigText);
        Assert.AreEqual('<?xml version="1.0" encoding="utf-16"?>', Format(XmlBigText), 'Unexpected text when creating a Xml Document with XmlWriter');
    end;

    [Test]
    procedure TestWriteElementString()
    var
        XmlWriter: Codeunit "XmlWriter";
        XmlBigText: BigText;
    begin
        // [GIVEN] Initialized XmlWriter with root element
        XmlWriter.WriteStartDocument();

        // [WHEN] Write an element and end document
        XmlWriter.WriteElementString('TestEle', 'Test element value');
        XmlWriter.WriteEndDocument();

        // [THEN] Get XmlDocument to text
        XmlWriter.ToBigText(XmlBigText);
        Assert.AreEqual('<?xml version="1.0" encoding="utf-16"?><TestEle>Test element value</TestEle>', Format(XmlBigText), 'Unexpected text when creating a Xml Document with XmlWriter');
    end;

    [Test]
    procedure TestWriteEndDocumentNoElement()
    var
        XmlWriter: Codeunit "XmlWriter";
    begin
        // [GIVEN] Initialized XmlWriter with root element
        XmlWriter.WriteStartDocument();

        // [WHEN] Error expected when trying to write end document
        asserterror XmlWriter.WriteEndDocument();
        Assert.ExpectedError('A call to System.Xml.XmlTextWriter.WriteEndDocument failed with this message: Document does not have a root element.');
    end;

    [Test]
    procedure TestWriteStartElement()
    var
        XmlWriter: Codeunit "XmlWriter";
        XmlBigText: BigText;
    begin
        // [GIVEN] Initialized XmlWriter with root element
        XmlWriter.WriteStartDocument();

        // [WHEN] Write start element and end document
        XmlWriter.WriteStartElement('TestLocalName');
        XmlWriter.WriteEndDocument();

        // [THEN] Get XmlDocument to text
        XmlWriter.ToBigText(XmlBigText);
        Assert.AreEqual('<?xml version="1.0" encoding="utf-16"?><TestLocalName />', Format(XmlBigText), 'Unexpected text when creating a Xml Document with XmlWriter');
    end;

    [Test]
    procedure TestWriteEndElement()
    var
        XmlWriter: Codeunit "XmlWriter";
        XmlBigText: BigText;
    begin
        // [GIVEN] Initialized XmlWriter with root element
        XmlWriter.WriteStartDocument();

        // [WHEN] Write element string
        XmlWriter.WriteStartElement('TestLocalName');
        XmlWriter.WriteElementString('InnerElement', 'Value');
        XmlWriter.WriteEndElement();
        XmlWriter.WriteEndDocument();

        // [THEN] Get XmlDocument to text
        XmlWriter.ToBigText(XmlBigText);
        Assert.AreEqual('<?xml version="1.0" encoding="utf-16"?><TestLocalName><InnerElement>Value</InnerElement></TestLocalName>', Format(XmlBigText), 'Unexpected text when creating a Xml Document with XmlWriter');
    end;

    [Test]
    procedure TestWriteAttributeString()
    var
        XmlWriter: Codeunit "XmlWriter";
        XmlBigText: BigText;
    begin
        // [GIVEN] Initialized XmlWriter with root element
        XmlWriter.WriteStartDocument();

        // [WHEN] Write attribute strings with overloads
        XmlWriter.WriteStartElement('TestElement');
        XmlWriter.WriteAttributeString('LocalName', 'Element');
        XmlWriter.WriteStartElement('ello');
        XmlWriter.WriteAttributeString('Pre', 'LocalName', 'NS', 'Element');
        XmlWriter.WriteEndElement();
        XmlWriter.WriteEndElement();
        XmlWriter.WriteEndDocument();

        // [THEN] Get XmlDocument to text
        XmlWriter.ToBigText(XmlBigText);
        Assert.AreEqual('<?xml version="1.0" encoding="utf-16"?><TestElement LocalName="Element"><ello Pre:LocalName="Element" xmlns:Pre="NS" /></TestElement>', Format(XmlBigText), 'Unexpected text when creating a Xml Document with XmlWriter');
    end;

    [Test]
    procedure TestWriteComment()
    var
        XmlWriter: Codeunit "XmlWriter";
        XmlBigText: BigText;
    begin
        // [GIVEN] Initialized XmlWriter with root element
        XmlWriter.WriteStartDocument();

        // [WHEN] Write comment
        XmlWriter.WriteStartElement('TestElement');
        XmlWriter.WriteComment('This is a good module');
        XmlWriter.WriteEndDocument();

        // [THEN] Get XmlDocument to text
        XmlWriter.ToBigText(XmlBigText);
        Assert.AreEqual('<?xml version="1.0" encoding="utf-16"?><TestElement><!--This is a good module--></TestElement>', Format(XmlBigText), 'Unexpected text when creating a Xml Document with XmlWriter');
    end;

    [Test]
    procedure TestWriteProcessingInstructionAndString()
    var
        XmlWriter: Codeunit "XmlWriter";
        XmlBigText: BigText;
    begin
        // [GIVEN] Initialized XmlWriter with root element
        XmlWriter.WriteProcessingInstruction('xml', 'version="1.0" encoding="utf-8" standalone="no"');

        // [WHEN] Get XmlDocument to text
        XmlWriter.ToBigText(XmlBigText);

        // [THEN] The result is as expected
        Assert.AreEqual('<?xml version="1.0" encoding="utf-8" standalone="no"?>', Format(XmlBigText), 'Unexpected text when creating a Xml Document with XmlWriter');
    end;

    local procedure GetXmlText(): Text;
    begin
        Exit('<?xml version="1.0" encoding="utf-16"?><export><meta type="test"><tableno>5200</tableno></meta>' +
        '<employees><employee no="123" name="Angela"><details><company>Mercash</company><city>Hoorn</city><occupation>Software Developer</occupation></details></employee></employees>' +
        '<!--This is an awesome module--></export>')
    end;
}