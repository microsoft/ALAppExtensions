// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Xml;

/// <summary>
/// Provides helper functions for xml validation against a schema.
/// </summary>
codeunit 6240 "Xml Validation"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        XmlValidationImpl: Codeunit "Xml Validation Impl.";

    /// <summary>
    /// Performs validation of an XML from a string against a schema from a string.
    /// </summary>
    /// <param name="Xml">Xml string to validate.</param>
    /// <param name="XmlSchema">Xml schema string to validate against.</param>
    /// <param name="Namespace">Namespace of the xml schema.</param>
    /// <error>If xml definition is not well-formed</error>
    /// <error>If xml schema definition is not well-formed</error>
    [TryFunction]
    procedure TryValidateAgainstSchema(Xml: Text; XmlSchema: Text; Namespace: Text)
    begin
        XmlValidationImpl.ValidateAgainstSchema(Xml, XmlSchema, Namespace);
    end;

    /// <summary>
    /// Performs validation of a XmlDocument against a schema in a XmlDocument.
    /// </summary>
    /// <param name="XmlDoc">Xml document to validate.</param>
    /// <param name="XmlSchemaDoc">Xml document with the schema to validate against.</param>
    /// <param name="Namespace">Namespace of the xml schema.</param>
    [TryFunction]
    procedure TryValidateAgainstSchema(XmlDoc: XmlDocument; XmlSchemaDoc: XmlDocument; Namespace: Text)
    begin
        XmlValidationImpl.ValidateAgainstSchema(XmlDoc, XmlSchemaDoc, Namespace);
    end;

    /// <summary>
    /// Performs validation of a XmlDocument against a schema in a stream.
    /// </summary>
    /// <param name="XmlDocInStream">InStream holding the xml document to validate.</param>
    /// <param name="XmlSchemaInStream">InStream holding the schema to validate against.</param>
    /// <param name="Namespace">Namespace of the xml schema.</param>
    [TryFunction]
    procedure TryValidateAgainstSchema(XmlDocInStream: InStream; XmlSchemaInStream: InStream; Namespace: Text)
    begin
        XmlValidationImpl.ValidateAgainstSchema(XmlDocInStream, XmlSchemaInStream, Namespace);
    end;

    /// <summary>
    /// Sets validated document from a string.
    /// </summary>
    /// <param name="Xml">Xml string to validate.</param>
    [TryFunction]
    procedure TrySetValidatedDocument(Xml: Text)
    begin
        XmlValidationImpl.SetValidatedDocument(Xml);
    end;

    /// <summary>
    /// Sets validated document in a XmlDocument.
    /// </summary>
    /// <param name="XmlDoc">Xml document to validate.</param>
    [TryFunction]
    procedure TrySetValidatedDocument(XmlDoc: XmlDocument)
    begin
        XmlValidationImpl.SetValidatedDocument(XmlDoc);
    end;

    /// <summary>
    /// Sets validated document from a stream.
    /// </summary>
    /// <param name="XmlDocInStream">InStream holding the XML document to validate.</param>
    [TryFunction]
    procedure TrySetValidatedDocument(XmlDocInStream: InStream)
    begin
        XmlValidationImpl.SetValidatedDocument(XmlDocInStream);
    end;

    /// <summary>
    /// Adds validation schema to validated document from a string.
    /// </summary>
    /// <param name="XmlSchema">Xml schema string to validate against.</param>
    /// <param name="Namespace">Namespace of the XML schema.</param>
    [TryFunction]
    procedure TryAddValidationSchema(Xml: Text; Namespace: Text)
    begin
        XmlValidationImpl.AddValidationSchema(Xml, NameSpace);
    end;

    /// <summary>
    /// Adds validation schema to validated document in a XmlDocument.
    /// </summary>
    /// <param name="XmlSchemaDoc">Xml document with the schema to validate against.</param>
    /// <param name="Namespace">Namespace of the XML schema.</param>
    [TryFunction]
    procedure TryAddValidationSchema(XmlSchemaDoc: XmlDocument; Namespace: Text)
    begin
        XmlValidationImpl.AddValidationSchema(XmlSchemaDoc, NameSpace);
    end;

    /// <summary>
    /// Adds validation schema to validated document from a stream.
    /// </summary>
    /// <param name="XmlSchemaInStream">InStream holding the XSD schema to validate against.</param>
    /// <param name="Namespace">Namespace of the XML schema.</param>
    [TryFunction]
    procedure TryAddValidationSchema(XmlSchemaInStream: InStream; Namespace: Text)
    begin
        XmlValidationImpl.AddValidationSchema(XmlSchemaInStream, NameSpace);
    end;

    /// <summary>
    /// Performs validation of a XML document against one or multiple XSD schemas.
    /// </summary>
    [TryFunction]
    procedure TryValidateAgainstSchema()
    begin
        XmlValidationImpl.ValidateAgainstSchema();
    end;
}
