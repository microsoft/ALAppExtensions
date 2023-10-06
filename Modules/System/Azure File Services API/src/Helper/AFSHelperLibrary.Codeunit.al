// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8960 "AFS Helper Library"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata Field = r;

    [NonDebuggable]
    procedure CreateHandleNodeListFromResponse(ResponseAsText: Text): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(ResponseAsText, '/*/Entries/Handle'));
    end;

    [NonDebuggable]
    procedure CreateDirectoryContentNodeListFromResponse(ResponseAsText: Text): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(ResponseAsText, '/*/Entries/File|/*/Entries/Directory'));
    end;

    [NonDebuggable]
    procedure GetDirectoryPathFromResponse(ResponseAsText: Text): Text
    var
        Document: XmlDocument;
        Root: XmlElement;
    begin
        GetXmlDocumentFromResponse(Document, ResponseAsText);
        Document.GetRoot(Root);
        exit(GetAttributeValueFromElement(Root, 'DirectoryPath'))
    end;

    [NonDebuggable]
    procedure GetNextMarkerFromResponse(ResponseAsText: Text): Text
    var
        Document: XmlDocument;
        Root: XmlElement;
    begin
        GetXmlDocumentFromResponse(Document, ResponseAsText);
        Document.GetRoot(Root);
        exit(GetValueFromNode(Root.AsXmlNode(), '/*/NextMarker'))
    end;

    [NonDebuggable]
    procedure DirectoryContentNodeListToTempRecord(DirectoryURI: Text; DirectoryPath: Text[2048]; NodeList: XmlNodeList; PreserveDirectoryContent: Boolean; var AFSDirectoryContent: Record "AFS Directory Content")
    begin
        NodeListToTempRecord(DirectoryURI, DirectoryPath, NodeList, './/Name', PreserveDirectoryContent, AFSDirectoryContent);
    end;

    [NonDebuggable]
    internal procedure HandleNodeListToTempRecord(NodeList: XmlNodeList; var AFSHandle: Record "AFS Handle" temporary)
    begin
        NodeListToTempRecord(NodeList, AFSHandle);
    end;

    [NonDebuggable]
    local procedure GetXmlDocumentFromResponse(var Document: XmlDocument; ResponseAsText: Text)
    var
        ReadingAsXmlErr: Label 'Error reading Response as XML.';
    begin
        if not XmlDocument.ReadFrom(ResponseAsText, Document) then
            Error(ReadingAsXmlErr);
    end;

    [NonDebuggable]
    local procedure CreateXPathNodeListFromResponse(ResponseAsText: Text; XPath: Text): XmlNodeList
    var
        Document: XmlDocument;
        RootNode: XmlElement;
        NodeList: XmlNodeList;
    begin
        GetXmlDocumentFromResponse(Document, ResponseAsText);
        Document.GetRoot(RootNode);
        RootNode.SelectNodes(XPath, NodeList);
        exit(NodeList);
    end;

    [NonDebuggable]
    procedure GetValueFromNode(Node: XmlNode; XPath: Text): Text
    var
        Node2: XmlNode;
        Value: Text;
    begin
        Node.SelectSingleNode(XPath, Node2);
        Value := Node2.AsXmlElement().InnerText();
        exit(Value);
    end;

    [NonDebuggable]
    procedure GetAttributeValueFromElement(Element: XmlElement; AttributeName: Text): Text
    var
        Attribute: XmlAttribute;
    begin
        if not Element.HasAttributes then
            exit;
        foreach Attribute in Element.Attributes() do
            if Attribute.Name = AttributeName then
                exit(Attribute.Value);
    end;

    [NonDebuggable]
    local procedure NodeListToTempRecord(DirectoryURI: Text; DirectoryPath: Text[2048]; NodeList: XmlNodeList; XPathName: Text; PreserveDirectoryContent: Boolean; var AFSDirectoryContent: Record "AFS Directory Content")
    var
        AFSDirectoryContentHelper: Codeunit "AFS Directory Content Helper";
        Node: XmlNode;
    begin
        if not PreserveDirectoryContent then
            AFSDirectoryContent.DeleteAll();

        if NodeList.Count = 0 then
            exit;

        foreach Node in NodeList do
            AFSDirectoryContentHelper.AddNewEntryFromNode(DirectoryURI, DirectoryPath, AFSDirectoryContent, Node, XPathName);
    end;

    [NonDebuggable]
    local procedure NodeListToTempRecord(NodeList: XmlNodeList; var AFSHandle: Record "AFS Handle")
    var
        AFSHandleHelper: Codeunit "AFS Handle Helper";
        Node: XmlNode;
    begin
        if NodeList.Count = 0 then
            exit;

        foreach Node in NodeList do
            AFSHandleHelper.AddNewEntryFromNode(AFSHandle, Node);
    end;

    [NonDebuggable]
    procedure GetFieldByCaption(TableNo: Integer; FieldCaption: Text; var FieldNo: Integer): Boolean
    var
        Field: Record Field;
    begin
        Clear(FieldNo);
        Field.Reset();
        Field.SetRange(TableNo, TableNo);
        Field.SetRange("Field Caption", CopyStr(FieldCaption, 1, MaxStrLen(Field.FieldName)));
        if Field.FindFirst() then
            FieldNo := Field."No.";
        exit(FieldNo <> 0);
    end;
}