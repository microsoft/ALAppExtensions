// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 6241 "Xml Validation Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        ValidatedXmlDocument: DotNet XmlDocument;
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
    begin
        SetValidatedDocument(XmlDocStream);
        AddValidationSchema(XmlSchemaStream, Namespace);
        ValidateAgainstSchema();
    end;

    procedure SetValidatedDocument(Xml: Text)
    var
        XmlDoc: XmlDocument;
    begin
        if not XmlDocument.ReadFrom(Xml, XmlDoc) then
            Error(InvalidXmlErr);

        SetValidatedDocument(XmlDoc);
    end;

    procedure SetValidatedDocument(XmlDoc: XmlDocument)
    var
        XmlDocTempBlob: Codeunit "Temp Blob";
        XmlDocOutStream: OutStream;
        XmlDocInStream: InStream;
    begin
        XmlDocTempBlob.CreateOutStream(XmlDocOutStream);
        XmlDoc.WriteTo(XmlDocOutStream);
        XmlDocTempBlob.CreateInStream(XmlDocInStream);

        SetValidatedDocument(XmlDocInStream);
    end;

    procedure SetValidatedDocument(XmlDocInStream: InStream)
    begin
        ValidatedXmlDocument := ValidatedXmlDocument.XmlDocument();
        ValidatedXmlDocument.Load(XmlDocInStream);
    end;

    procedure AddValidationSchema(XmlSchema: Text; Namespace: Text)
    var
        XmlSchemaDoc: XmlDocument;
    begin
        if not XmlDocument.ReadFrom(XmlSchema, XmlSchemaDoc) then
            Error(InvalidSchemaErr);

        AddValidationSchema(XmlSchemaDoc, Namespace);
    end;

    procedure AddValidationSchema(XmlSchemaDoc: XmlDocument; Namespace: Text)
    var
        XmlSchemaTempBlob: Codeunit "Temp Blob";
        XmlSchemaOutStream: OutStream;
        XmlSchemaInStream: InStream;
    begin
        XmlSchemaTempBlob.CreateOutStream(XmlSchemaOutStream);
        XmlSchemaDoc.WriteTo(XmlSchemaOutStream);
        XmlSchemaTempBlob.CreateInStream(XmlSchemaInStream);

        AddValidationSchema(XmlSchemaInStream, Namespace);
    end;

    procedure AddValidationSchema(XmlSchemaInStream: InStream; Namespace: Text)
    var
        XmlReader: DotNet XmlReader;
    begin
        XmlReader := XmlReader.Create(XmlSchemaInStream);
        ValidatedXmlDocument.Schemas.Add(Namespace, XmlReader);
    end;

    procedure ValidateAgainstSchema()
    begin
        if not TryValidate(ValidatedXmlDocument) then
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