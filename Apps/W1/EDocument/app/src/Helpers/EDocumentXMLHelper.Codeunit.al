// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Helpers;

using Microsoft.Finance.GeneralLedger.Setup;

codeunit 6127 "EDocument XML Helper"
{
    Access = Internal;

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

    internal procedure SetNumberValueInField(XMLDocument: XmlDocument; XMLNamespaces: XmlNamespaceManager; Path: Text; var DecimalValue: Decimal)
    var
        XMLNode: XmlNode;
    begin
        if not XMLDocument.SelectSingleNode(Path, XMLNamespaces, XMLNode) then
            exit;

        if XMLNode.AsXmlElement().InnerText() <> '' then
            Evaluate(DecimalValue, XMLNode.AsXmlElement().InnerText(), 9);
    end;

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