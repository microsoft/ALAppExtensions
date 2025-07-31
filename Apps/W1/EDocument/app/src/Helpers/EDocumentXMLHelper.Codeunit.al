// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Helpers;

using Microsoft.Finance.GeneralLedger.Setup;

codeunit 6175 "EDocument XML Helper"
{
    Access = Internal;

    /// <summary>
    /// Extracts currency value from XML document and sets it in the currency field if it differs from LCY.
    /// </summary>
    /// <param name="XMLDocument">The XML document to search in.</param>
    /// <param name="XMLNamespaces">The XML namespace manager for XPath queries.</param>
    /// <param name="Path">The XPath expression to locate the currency value.</param>
    /// <param name="MaxLength">The maximum length of the currency code.</param>
    /// <param name="CurrencyField">The currency field to update with the extracted value.</param>
    internal procedure SetCurrencyValueInField(XMLDocument: XmlDocument; XMLNamespaces: XmlNamespaceManager; Path: Text; MaxLength: Integer; var CurrencyField: Code[10])
    var
        GLSetup: Record "General Ledger Setup";
        XMLNode: XmlNode;
        CurrencyCode: Code[10];
    begin
        if not XMLDocument.SelectSingleNode(Path, XMLNamespaces, XMLNode) then
            exit;

        GLSetup.Get();

#pragma warning disable AA0139 // false positive
        if XMLNode.IsXmlElement() then begin
            CurrencyCode := CopyStr(XMLNode.AsXmlElement().InnerText(), 1, MaxLength);
            if GLSetup."LCY Code" <> CurrencyCode then
                CurrencyField := CurrencyCode;
            exit;
        end;

        if XMLNode.IsXmlAttribute() then begin
            CurrencyCode := CopyStr(XMLNode.AsXmlAttribute().Value, 1, MaxLength);
            if GLSetup."LCY Code" <> CurrencyCode then
                CurrencyField := CurrencyCode;
            exit;
        end;
#pragma warning restore AA0139
    end;

    /// <summary>
    /// Extracts string value from XML document and sets it in the specified field.
    /// </summary>
    /// <param name="XMLDocument">The XML document to search in.</param>
    /// <param name="XMLNamespaces">The XML namespace manager for XPath queries.</param>
    /// <param name="Path">The XPath expression to locate the string value.</param>
    /// <param name="MaxLength">The maximum length of the string value.</param>
    /// <param name="Field">The text field to update with the extracted value.</param>
    internal procedure SetStringValueInField(XMLDocument: XmlDocument; XMLNamespaces: XmlNamespaceManager; Path: Text; MaxLength: Integer; var Field: Text)
    var
        XMLNode: XmlNode;
    begin
        if not XMLDocument.SelectSingleNode(Path, XMLNamespaces, XMLNode) then
            exit;

        if XMLNode.IsXmlElement() then begin
            Field := CopyStr(XMLNode.AsXmlElement().InnerText(), 1, MaxLength);
            exit;
        end;

        if XMLNode.IsXmlAttribute() then begin
            Field := CopyStr(XMLNode.AsXmlAttribute().Value(), 1, MaxLength);
            exit;
        end;
    end;

    /// <summary>
    /// Extracts numeric value from XML document and sets it in the specified decimal field.
    /// </summary>
    /// <param name="XMLDocument">The XML document to search in.</param>
    /// <param name="XMLNamespaces">The XML namespace manager for XPath queries.</param>
    /// <param name="Path">The XPath expression to locate the numeric value.</param>
    /// <param name="DecimalValue">The decimal field to update with the extracted value.</param>
    internal procedure SetNumberValueInField(XMLDocument: XmlDocument; XMLNamespaces: XmlNamespaceManager; Path: Text; var DecimalValue: Decimal)
    var
        XMLNode: XmlNode;
    begin
        if not XMLDocument.SelectSingleNode(Path, XMLNamespaces, XMLNode) then
            exit;

        if XMLNode.AsXmlElement().InnerText() <> '' then
            Evaluate(DecimalValue, XMLNode.AsXmlElement().InnerText(), 9);
    end;

    /// <summary>
    /// Extracts date value from XML document and sets it in the specified date field.
    /// </summary>
    /// <param name="XMLDocument">The XML document to search in.</param>
    /// <param name="XMLNamespaces">The XML namespace manager for XPath queries.</param>
    /// <param name="Path">The XPath expression to locate the date value.</param>
    /// <param name="DateValue">The date field to update with the extracted value.</param>
    internal procedure SetDateValueInField(XMLDocument: XmlDocument; XMLNamespaces: XmlNamespaceManager; Path: Text; var DateValue: Date)
    var
        XMLNode: XmlNode;
    begin
        if not XMLDocument.SelectSingleNode(Path, XMLNamespaces, XMLNode) then
            exit;

        if XMLNode.AsXmlElement().InnerText() <> '' then
            Evaluate(DateValue, XMLNode.AsXmlElement().InnerText(), 9);
    end;
}
