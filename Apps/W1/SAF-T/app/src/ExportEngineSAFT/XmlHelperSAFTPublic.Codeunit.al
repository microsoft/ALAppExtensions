// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Xml;

codeunit 5292 "Xml Helper SAF-T Public"
{
    Access = Public;

    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        CurrXmlElement: array[100] of XmlElement;
        NamespaceUri: Text;
        UTF8BOMSymbols: Text;
        Depth: Integer;
        IsInitialized: Boolean;
        NotPossibleToInsertErr: label 'Not possible to insert element %1', Comment = '%1 - node text';

    /// <summary>
    /// Initializes the dummy root node to which all other nodes are added.
    /// The list of child nodes of the dummy root node is returned by the GetXmlNodes function.
    /// </summary>
    procedure Initialize()
    begin
        Clear(CurrXmlElement);
        Depth := 1;
        UTF8BOMSymbols := XMLDOMManagement.GetUTF8BOMSymbols();
        CreateRootElement('DummyRootNode', '');
        IsInitialized := true;
    end;

    /// <summary>
    /// Sets the NamespaceUri that is later used in the functions which create XML nodes.
    /// </summary>
    procedure InitNamespace(NewNamespaceUri: Text)
    begin
        NamespaceUri := NewNamespaceUri;
    end;

    /// <summary>
    /// Adds the child node to the current node and sets that child node as a parent for the next nodes.
    /// </summary>
    procedure AddNewXmlNode(NodeName: Text; NodeText: Text)
    var
        NewXmlElement: XmlElement;
    begin
        if not IsInitialized then
            Initialize();

        ClearUTF8BOMSymbols(NodeText);
        AddXmlElement(NewXmlElement, NodeName, NodeText);
        Depth += 1;
        CurrXmlElement[Depth] := NewXmlElement;
    end;

    /// <summary>
    /// Adds the child node to the current node. Node is not added if the content is empty.
    /// </summary>
    procedure AppendXmlNode(NodeName: Text; NodeText: Text)
    var
        NewXmlElement: XmlElement;
    begin
        if not IsInitialized then
            Initialize();
        ClearUTF8BOMSymbols(NodeText);
        if NodeText <> '' then
            AddXmlElement(NewXmlElement, NodeName, NodeText);
    end;

    /// <summary>
    /// Adds the child node to the current node. Node content can be empty.
    /// </summary>
    procedure AppendXmlNodeEmptyContentAllowed(NodeName: Text; NodeText: Text)
    var
        NewXMLElement: XmlElement;
    begin
        if not IsInitialized then
            Initialize();
        ClearUTF8BOMSymbols(NodeText);
        AddXmlElement(NewXMLElement, NodeName, NodeText);
    end;

    /// <summary>
    /// Selects the parent node of the current node, i.e. "closes" the current XML node.
    /// </summary>
    procedure FinalizeXmlNode()
    begin
        Depth -= 1;
        if Depth < 0 then
            Error('Incorrect XML structure');
    end;

    /// <summary>
    /// Returns the list of child nodes of the dummy root node.
    /// </summary>
    procedure GetXmlNodes() RootXmlNodes: XmlNodeList
    begin
        // get children of dummy root node
        RootXmlNodes := CurrXmlElement[1].GetChildElements();
    end;

    local procedure AddXmlElement(var NewXmlElement: XmlElement; Name: Text; NodeText: Text)
    begin
        NewXmlElement := XmlElement.Create(Name, NamespaceUri, NodeText);
        if not CurrXmlElement[Depth].Add(NewXmlElement) then
            Error(NotPossibleToInsertErr, NodeText);
    end;

    local procedure CreateRootElement(Name: Text; NodeText: Text)
    begin
        CurrXmlElement[1] := XmlElement.Create(Name, NamespaceUri, NodeText);
    end;

    local procedure ClearUTF8BOMSymbols(var RawXmlText: Text)
    begin
        if StrPos(RawXmlText, UTF8BOMSymbols) = 1 then
            RawXmlText := DelStr(RawXmlText, 1, StrLen(UTF8BOMSymbols));
    end;
}
