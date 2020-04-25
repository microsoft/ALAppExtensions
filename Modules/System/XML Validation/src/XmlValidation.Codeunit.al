// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides helper functions for xml validation against a schema.
/// </summary>

codeunit 50100 "Xml Validation"
{
    Access = Public;

    var
        XmlValidationImpl: Codeunit "Xml Validation Impl.";

    /// <summary>
    /// Performs validation of an xml from a string against a schema from a string.
    /// </summary>
    /// <param name="Xml">Xml string to validate.</param>
    /// <param name="XmlSchema">Xml schema string to validate against.</param>
    /// <param name="Namespace">Namespace of the xml schema.</param>
    /// <param name="ErrorText">The error text if the validation was not successful.</param>
    /// <returns>True if validation was successful, false otherwise.</returns>
    procedure ValidateAgainstSchema(Xml: Text; XmlSchema: Text; Namespace: Text; var ErrorText: Text): Boolean
    begin
        exit(XmlValidationImpl.ValidateAgainstSchema(Xml, XmlSchema, Namespace, ErrorText));
    end;

    /// <summary>
    /// Performs validation of a XmlDocument against a schema in a XmlDocument.
    /// </summary>
    /// <param name="XmlDoc">Xml document to validate.</param>
    /// <param name="XmlSchemaDoc">Xml document with the schema to validate against.</param>
    /// <param name="Namespace">Namespace of the xml schema.</param>
    /// <param name="ErrorText">The error text if the validation was not successful.</param>
    /// <returns>True if validation was successful, false otherwise.</returns>
    procedure ValidateAgainstSchema(XmlDoc: XmlDocument; XmlSchemaDoc: XmlDocument; Namespace: Text; var ErrorText: Text): Boolean
    begin
        exit(XmlValidationImpl.ValidateAgainstSchema(XmlDoc, XmlSchemaDoc, Namespace, ErrorText));
    end;

    /// <summary>
    /// Performs validation of a XmlDocument against a schema in a stream.
    /// </summary>
    /// <param name="XmlDocStream">InStream holding the xml document to validate.</param>
    /// <param name="XmlSchemaStream">InStream holding the schema to validate against.</param>
    /// <param name="Namespace">Namespace of the xml schema.</param>
    /// <param name="ErrorText">The error text if the validation was not successful.</param>
    /// <returns>True if validation was successful, false otherwise.</returns>
    procedure ValidateAgainstSchema(XmlDocStream: InStream; XmlSchemaStream: InStream; Namespace: Text; var ErrorText: Text): Boolean
    begin
        exit(XmlValidationImpl.ValidateAgainstSchema(XmlDocStream, XmlSchemaStream, Namespace, ErrorText));
    end;
}