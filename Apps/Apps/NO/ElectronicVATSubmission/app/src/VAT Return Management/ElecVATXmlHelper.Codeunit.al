// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Xml;

codeunit 10689 "Elec. VAT XML Helper"
{
    var
        XMLDoc: XmlDocument;
        CurrXMLElement: array[100] of XmlElement;
        SavedXMLElement: XmlElement;
        XMLNsMgr: XmlNamespaceManager;
        Depth: Integer;
        GlobalNameSpace: Text;
        NotPossibleToInsertElementErr: Label 'Cannot insert element %1 with the value %2', Comment = '%1 = name of the element. %2 = value';
        IncorrectXMLStructureErr: Label 'Incorrect XML structure';
        FullNameSpaceTxt: Label 'no:skatteetaten:fastsetting:avgift:mva:skattemeldingformerverdiavgift:v1.0', Locked = true;

    procedure Initialize(RootName: Text)
    begin
        clear(XMLDoc);
        clear(CurrXMLElement);
        Depth := 0;
        CreateRoot(RootName, FullNameSpaceTxt);
    end;

    procedure InitializeNoNamespace(RootName: Text)
    begin
        clear(XMLDoc);
        clear(CurrXMLElement);
        Depth := 0;
        CreateRoot(RootName, '');
    end;

    procedure LoadXmlFromText(RawXmlText: Text)
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
    begin
        XMLDOMManagement.ClearUTF8BOMSymbols(RawXmlText);
        XmlDocument.ReadFrom(RawXmlText, XMLDoc);
        XmlDocument.ReadFrom(RawXmlText, XMLDoc);
        XMLNsMgr.NameTable(XMLDoc.NameTable);
        XMLNsMgr.AddNamespace('ns', FullNameSpaceTxt);
    end;

    procedure CreateRoot(RootNodeName: Text; NamespaceValue: text)
    begin
        Depth += 1;
        XMLDoc := XmlDocument.Create();
        XMLDoc.SetDeclaration(XmlDeclaration.Create('1.0', 'UTF-8', 'yes'));
        GlobalNameSpace := NamespaceValue;
        CurrXMLElement[Depth] := XmlElement.Create(RootNodeName, NamespaceValue);
        XMLDoc.Add(CurrXMLElement[Depth]);
        XMLDoc.GetRoot(CurrXMLElement[Depth]);
    end;

    procedure AddNewXMLNode(Name: Text; NodeText: Text)
    var
        NewXMLElement: XmlElement;
    begin
        InsertXMLNode(NewXMLElement, Name, NodeText);
        Depth += 1;
        CurrXMLElement[Depth] := NewXMLElement;
    end;

    procedure AppendXMLNode(Name: Text; NodeText: Text)
    var
        NewXMLElement: XmlElement;
    begin
        if NodeText = '' then
            exit;
        InsertXMLNode(NewXMLElement, Name, NodeText);
    end;

    procedure AppendToSavedXMLNode(Name: Text; NodeText: Text)
    var
        NewXMLElement: XmlElement;
    begin
        if NodeText = '' then
            exit;
        NewXMLElement := XmlElement.Create(Name, NodeText);
        if (not SavedXMLElement.AddFirst(NewXMLElement)) then
            error(GetInsertErrorText(Name, NodeText));
    end;

    procedure SaveCurrXmlElement()
    begin
        SavedXMLElement := CurrXMLElement[Depth];
    end;

    procedure FinalizeXMLNode()
    begin
        Depth -= 1;
        if Depth < 0 then
            Error(IncorrectXMLStructureErr);
    end;

    procedure GetXMLRequest() Result: Text
    begin
        XMLDoc.WriteTo(Result);
        exit(Result);
    end;

    procedure GetFirstNodeValueByXPath(XPath: Text): Text
    var
        ResultedXMLNodeList: XmlNodeList;
        ResultedXMLNode: XmlNode;
    begin
        XMLDoc.SelectNodes(XPath, XMLNsMgr, ResultedXMLNodeList);
        if ResultedXMLNodeList.Get(1, ResultedXMLNode) then
            exit(GetNodeValue(ResultedXMLNode, XPath));
    end;

    local procedure GetNodeValue(ParentXmlNode: XmlNode; Xpath: Text): Text;
    var
        DataXmlNode: XmlNode;
        NodeValue: Text;
    begin
        if (ParentXmlNode.SelectSingleNode(Xpath + '/text()', DataXmlNode)) then begin
            if (DataXmlNode.IsXmlText()) then
                NodeValue := DataXmlNode.AsXmlText().Value();
            if (NodeValue <> '') then
                exit(DELCHR(NodeValue, '=', '"'))
            else
                exit('');
        end;
        exit('');
    end;

    local procedure InsertXMLNode(var NewXMLElement: XmlElement; Name: Text; NodeText: Text)
    begin
        NewXMLElement := XmlElement.Create(Name, GlobalNameSpace, NodeText);
        if (not CurrXMLElement[Depth].Add(NewXMLElement)) then
            error(GetInsertErrorText(Name, NodeText));
    end;

    local procedure GetInsertErrorText(Name: Text; NodeText: Text): Text
    begin
        exit(StrSubstNo(NotPossibleToInsertElementErr, Name, NodeText));
    end;
}
