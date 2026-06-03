// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using System.Xml;

codeunit 11042 "DE XML Document Validator"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure ValidateZUGFeRDXML(var XmlStream: InStream)
    var
        XmlValidation: Codeunit "Xml Validation";
        Files: List of [Text];
        FilePath: Text;
        Namespace: Text;
        XSDDocument: XmlDocument;
    begin
        XmlValidation.TrySetValidatedDocument(XmlStream);

        Files := NavApp.ListResources('ZUGFeRD/CII/*.xsd');
        foreach FilePath in Files do begin
            ReadXSDFromResourcePath(FilePath, XSDDocument, Namespace);
            XmlValidation.TryAddValidationSchema(XSDDocument, Namespace);
        end;
        XmlValidation.TryValidateAgainstSchema();
    end;

    procedure ValidateXRechnungInvoiceXML(var XmlStream: InStream)
    var
        XmlValidation: Codeunit "Xml Validation";
        Files: List of [Text];
        FilePath: Text;
        Namespace: Text;
        XSDDocument: XmlDocument;
    begin
        XmlValidation.TrySetValidatedDocument(XmlStream);

        ReadXSDFromResourcePath('XRechnung/UBL/UBL-Invoice-2.1.xsd', XSDDocument, Namespace);
        XmlValidation.TryAddValidationSchema(XSDDocument, Namespace);

        Files := NavApp.ListResources('XRechnung/UBL/Common/*.xsd');
        foreach FilePath in Files do begin
            ReadXSDFromResourcePath(FilePath, XSDDocument, Namespace);
            XmlValidation.TryAddValidationSchema(XSDDocument, Namespace);
        end;
        XmlValidation.TryValidateAgainstSchema();
    end;

    procedure ValidateXRechnungCreditNoteXML(var XmlStream: InStream)
    var
        XmlValidation: Codeunit "Xml Validation";
        Files: List of [Text];
        FilePath: Text;
        Namespace: Text;
        XSDDocument: XmlDocument;
    begin
        XmlValidation.TrySetValidatedDocument(XmlStream);

        ReadXSDFromResourcePath('XRechnung/UBL/UBL-CreditNote-2.1.xsd', XSDDocument, Namespace);
        XmlValidation.TryAddValidationSchema(XSDDocument, Namespace);

        Files := NavApp.ListResources('XRechnung/UBL/Common/*.xsd');
        foreach FilePath in Files do begin
            ReadXSDFromResourcePath(FilePath, XSDDocument, Namespace);
            XmlValidation.TryAddValidationSchema(XSDDocument, Namespace);
        end;
        XmlValidation.TryValidateAgainstSchema();
    end;

    local procedure ReadXSDFromResourcePath(Path: Text; var XSDDocument: XmlDocument; var TargetNameSpace: Text)
    var
        XSDInstream: InStream;
        NamespaceAttr: XmlAttribute;
        RootElement: XmlElement;
    begin
        Clear(XSDDocument);
        NavApp.GetResource(Path, XSDInstream, TextEncoding::UTF8);
        XmlDocument.ReadFrom(XSDInstream, XSDDocument);
        XSDDocument.GetRoot(RootElement);
        if RootElement.Attributes().Get('targetNamespace', NamespaceAttr) then
            TargetNameSpace := NamespaceAttr.Value()
        else
            TargetNameSpace := '';
    end;
}
