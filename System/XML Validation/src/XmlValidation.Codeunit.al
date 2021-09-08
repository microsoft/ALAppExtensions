// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides helper functions for xml validation against a schema.
/// </summary>
codeunit 6240 "Xml Validation"
{
    Access = Public;

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
    /// <param name="XmlDocStream">InStream holding the xml document to validate.</param>
    /// <param name="XmlSchemaStream">InStream holding the schema to validate against.</param>
    /// <param name="Namespace">Namespace of the xml schema.</param>
    [TryFunction]
    procedure TryValidateAgainstSchema(XmlDocStream: InStream; XmlSchemaStream: InStream; Namespace: Text)
    begin
        XmlValidationImpl.ValidateAgainstSchema(XmlDocStream, XmlSchemaStream, Namespace);
    end;
}