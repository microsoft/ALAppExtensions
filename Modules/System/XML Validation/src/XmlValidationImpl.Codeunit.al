codeunit 50101 "Xml Validation Impl."
{
    Access = Internal;

    var
        InvalidXmlErr: Label 'The xml definition is invalid.';
        InvalidSchemaErr: Label 'The schema definition is not valid xml.';

    procedure ValidateAgainstSchema(Xml: Text; XmlSchema: Text; Namespace: Text; var ErrorText: Text): Boolean
    var
        XmlDoc: XmlDocument;
        XmlSchemaDoc: XmlDocument;
    begin
        if not XmlDocument.ReadFrom(Xml, XmlDoc) then
            Error(InvalidXmlErr);

        if not XmlDocument.ReadFrom(XmlSchema, XmlSchemaDoc) then
            Error(InvalidSchemaErr);

        exit(ValidateAgainstSchema(XmlDoc, XmlSchemaDoc, Namespace, ErrorText));
    end;

    procedure ValidateAgainstSchema(XmlDoc: XmlDocument; XmlSchemaDoc: XmlDocument; Namespace: Text; var ErrorText: Text): Boolean
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

        exit(ValidateAgainstSchema(XmlDocInStream, XmlSchemaInStream, Namespace, ErrorText));
    end;

    procedure ValidateAgainstSchema(XmlDocStream: InStream; XmlSchemaStream: InStream; Namespace: Text; var ErrorText: Text)Result: Boolean
    begin
        Result := TryValidateAgainstSchema(XmlDocStream, XmlSchemaStream, Namespace);
        if Result then
            ErrorText := ''
        else
            ErrorText := GetLastErrorText();
    end;

    [TryFunction]
    local procedure TryValidateAgainstSchema(XmlDocStream: InStream; XmlSchemaStream: InStream; Namespace: Text)
    var
        XmlDoc: DotNet XmlDocument;
        XsdReader: DotNet XmlReader;
        XmlReader: DotNet XmlReader;
        Settings: DotNet XmlReaderSettings;
        ValidationType: DotNet ValidationType;
        ValidationEventHandler: DotNet ValidationEventHandler;
    begin
        XsdReader := XsdReader.Create(XmlSchemaStream);
        Settings := Settings.XmlReaderSettings();
        Settings.Schemas.Add(Namespace, XsdReader);
        Settings.ValidationType := ValidationType::Schema;

        XmlReader := XmlReader.Create(XmlDocStream, Settings);
        XmlDoc := XmlDoc.XmlDocument();
        XmlDoc.Load(XmlReader);
        XmlDoc.Validate(ValidationEventHandler);
    end;
}