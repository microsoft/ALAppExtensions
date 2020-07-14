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
        XmlSchemaSet: dotnet XmlSchemaSet;

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
    begin
        XmlDoc := XmlDoc.XmlDocument();
        XmlDoc.Load(XmlDocStream);

        XmlReader := XmlReader.Create(XmlSchemaStream);

        XmlSchemaSet := XmlSchemaSet.XmlSchemaSet();
        XmlSchemaSet.Add(Namespace, XmlReader);
        xmldoc.Schemas := XmlSchemaSet;

        if not TryValidate(XmlDoc) then
            HandleException(GetLastErrorObject());
    end;

    [TryFunction]
    procedure TryValidate(XmlDoc: DotNet XmlDocument)
    var
        Validation: dotnet ValidationEventHandler;
    begin
        XmlDoc.Validate(Validation);
    end;

    procedure HandleException(XmlSchemaValidationException: dotnet XmlSchemaValidationException)
    var
        ErrorMessage: Text;
        Index: integer;
    begin
        Index := XmlSchemaValidationException.Message.IndexOf(':');
        ErrorMessage := XmlSchemaValidationException.Message;
        if Index > 0 then
            ErrorMessage := XmlSchemaValidationException.Message.Substring(Index + 1);

        Error(ErrorMessage);
    end;

    trigger XmlSchemaSet::ValidationEventHandler(sender: Variant; e: DotNet ValidationEventArgs)
    begin
        Error(e.Message);
    end;
}