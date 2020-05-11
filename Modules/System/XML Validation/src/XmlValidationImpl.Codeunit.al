// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 6241 "Xml Validation Impl."
{
    Access = Internal;

    var
        InvalidXmlErr: Label 'The XML definition is invalid.';
        InvalidSchemaErr: Label 'The schema definition is not valid XML.';

    procedure ValidateAgainstSchema(Xml: Text; XmlSchema: Text; Namespace: Text)
    var
        XmlDoc: XmlDocument;
        XmlSchemaDoc: XmlDocument;
    begin
        if not XmlDocument.ReadFrom(Xml, XmlDoc) then
            Error(InvalidXmlErr);

        if not XmlDocument.ReadFrom(XmlSchema, XmlSchemaDoc) then
            Error(InvalidSchemaErr);

        ValidateAgainstSchema(XmlDoc, XmlSchemaDoc, Namespace);
    end;

    procedure ValidateAgainstSchema(XmlDoc: XmlDocument; XmlSchemaDoc: XmlDocument; Namespace: Text)
    var
        XmlDocBlob, XmlSchemaBlob : Codeunit "Temp Blob";
        XmlDocOutStream, XmlSchemaOutStream : OutStream;
        XmlDocInStream, XmlSchemaInStream : InStream;
    begin
        XmlDocBlob.CreateOutStream(XmlDocOutStream);
        XmlDoc.WriteTo(XmlDocOutStream);
        XmlDocBlob.CreateInStream(XmlDocInStream);

        XmlSchemaBlob.CreateOutStream(XmlSchemaOutStream);
        XmlSchemaDoc.WriteTo(XmlSchemaOutStream);
        XmlSchemaBlob.CreateInStream(XmlSchemaInStream);

        ValidateAgainstSchema(XmlDocInStream, XmlSchemaInStream, Namespace);
    end;

    procedure ValidateAgainstSchema(XmlDocStream: InStream; XmlSchemaStream: InStream; Namespace: Text)
    var
        XmlDoc: DotNet XmlDocument;
        XmlReader: DotNet XmlReader;
        ValidationEventHandler: DotNet ValidationEventHandler;
    begin
        XmlDoc := XmlDoc.XmlDocument();
        XmlDoc.Load(XmlDocStream);

        XmlReader := XmlReader.Create(XmlSchemaStream);
        XmlDoc.Schemas.Add(Namespace, XmlReader);

        XmlDoc.Validate(ValidationEventHandler);
    end;
}