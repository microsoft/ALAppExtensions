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
        [WithEvents]
        XmlValidatingReader: dotnet XmlValidatingReader;

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
        SchemaReader: DotNet XmlReader;
        ValidationType: dotnet ValidationType;
    begin
        XmlReader := XmlReader.Create(XmlDocStream);
        SchemaReader := SchemaReader.Create(XmlSchemaStream);

        XmlValidatingReader := XmlValidatingReader.XmlValidatingReader(XmlReader);
        XmlValidatingReader.Schemas.Add(Namespace, SchemaReader);
        XmlValidatingReader.ValidationType := ValidationType.Schema;
        while XmlValidatingReader.Read() do;
        XmlValidatingReader.Close();
    end;

    trigger XmlValidatingReader::ValidationEventHandler(sender: Variant; e: DotNet ValidationEventArgs)
    begin
        Error(e.Message);
    end;
}