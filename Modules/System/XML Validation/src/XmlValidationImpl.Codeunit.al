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
        XmlDocTempBlob, XmlSchemaTempBlob : Codeunit "Temp Blob";
        XmlDocOutStream, XmlSchemaOutStream : OutStream;
        XmlDocInStream, XmlSchemaInStream : InStream;
    begin
        XmlDocTempBlob.CreateOutStream(XmlDocOutStream);
        XmlDoc.WriteTo(XmlDocOutStream);
        XmlDocTempBlob.CreateInStream(XmlDocInStream);

        XmlSchemaTempBlob.CreateOutStream(XmlSchemaOutStream);
        XmlSchemaDoc.WriteTo(XmlSchemaOutStream);
        XmlSchemaTempBlob.CreateInStream(XmlSchemaInStream);

        ValidateAgainstSchema(XmlDocInStream, XmlSchemaInStream, Namespace);
    end;

    procedure ValidateAgainstSchema(XmlDocStream: InStream; XmlSchemaStream: InStream; Namespace: Text)
    var
        XmlDoc: DotNet XmlDocument;
        XmlReader: DotNet XmlReader;
    begin
        XmlDoc := XmlDoc.XmlDocument();
        XmlDoc.Load(XmlDocStream);

        XmlReader := XmlReader.Create(XmlSchemaStream);
        XmlDoc.Schemas.Add(Namespace, XmlReader);

        if not TryValidate(XmlDoc) then
            HandleValidateException();
    end;

    [TryFunction]
    local procedure TryValidate(XmlDoc: DotNet XmlDocument)
    var
        ValidationEventHandler: DotNet ValidationEventHandler;
    begin
        XmlDoc.Validate(ValidationEventHandler);
    end;

    local procedure HandleValidateException()
    var
        Exception: DotNet Exception;
    begin
        Exception := GetLastErrorObject();
        Error(Exception.InnerException.Message);
    end;
}