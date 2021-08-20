// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9043 "ABS Helper Library"
{
    Access = Internal;
    Permissions = tabledata Field = r;

    // #region Container-specific Helper
    procedure ContainerNodeListTotempRecord(NodeList: XmlNodeList; var Container: Record "ABS Container")
    begin
        NodeListToTempRecord(NodeList, './/Name', Container);
    end;

    procedure CreateContainerNodeListFromResponse(ResponseAsText: Text): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(ResponseAsText, '/*/Containers/Container'));
    end;
    // #endregion

    procedure PageRangesResultToDictionairy(Document: XmlDocument; var PageRanges: Dictionary of [Integer, Integer])
    var
        NodeList: XmlNodeList;
        Node: XmlNode;
        StartRange: Integer;
        EndRange: Integer;
    begin
        NodeList := CreatePageRangesNodeListFromResponse(Document);

        if NodeList.Count = 0 then
            exit;
        foreach Node in NodeList do begin
            Evaluate(StartRange, GetValueFromNode(Node, 'Start'));
            Evaluate(EndRange, GetValueFromNode(Node, 'End'));
            PageRanges.Add(StartRange, EndRange);
        end;
    end;

    procedure CreatePageRangesNodeListFromResponse(Document: XmlDocument): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(Document, '/*/PageRange'));
    end;

    procedure BlockListResultToDictionary(Document: XmlDocument; var CommitedBlocks: Dictionary of [Text, Integer]; var UncommitedBlocks: Dictionary of [Text, Integer])
    var
        NodeList: XmlNodeList;
        Node: XmlNode;
        NameValue: Text;
        SizeValue: Integer;
    begin
        NodeList := CreateBlockListCommitedNodeListFromResponse(Document);

        if NodeList.Count > 0 then
            foreach Node in NodeList do begin
                Evaluate(NameValue, GetValueFromNode(Node, 'Name'));
                Evaluate(SizeValue, GetValueFromNode(Node, 'Size'));
                CommitedBlocks.Add(NameValue, SizeValue);
            end;

        NodeList := CreateBlockListUncommitedNodeListFromResponse(Document);

        if NodeList.Count > 0 then
            foreach Node in NodeList do begin
                Evaluate(NameValue, GetValueFromNode(Node, 'Name'));
                Evaluate(SizeValue, GetValueFromNode(Node, 'Size'));
                UncommitedBlocks.Add(NameValue, SizeValue);
            end;
    end;

    procedure CreateBlockListCommitedNodeListFromResponse(Document: XmlDocument): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(Document, '/*/CommittedBlocks/Block'));
    end;

    procedure CreateBlockListUncommitedNodeListFromResponse(Document: XmlDocument): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(Document, '/*/UncommittedBlocks/Block'));
    end;

    // #region Blob-specific Helper
    procedure CreateBlobNodeListFromResponse(ResponseAsText: Text): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(ResponseAsText, '/*/Blobs/Blob'));
    end;

    procedure BlobNodeListToTempRecord(NodeList: XmlNodeList)
    var
        ContainerContent: Record "ABS Container Content";
    begin
        BlobNodeListToTempRecord(NodeList, ContainerContent);
    end;

    procedure BlobNodeListToTempRecord(NodeList: XmlNodeList; var ContainerContent: Record "ABS Container Content")
    begin
        NodeListToTempRecord(NodeList, './/Name', ContainerContent);
    end;
    // #endregion

    // #region XML Helper
    local procedure GetXmlDocumentFromResponse(var Document: XmlDocument; ResponseAsText: Text)
    var
        ReadingAsXmlErr: Label 'Error reading Response as XML.';
    begin
        if not XmlDocument.ReadFrom(ResponseAsText, Document) then
            Error(ReadingAsXmlErr);
    end;

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

    local procedure CreateXPathNodeListFromResponse(Document: XmlDocument; XPath: Text): XmlNodeList
    var
        RootNode: XmlElement;
        NodeList: XmlNodeList;
    begin
        Document.GetRoot(RootNode);
        RootNode.SelectNodes(XPath, NodeList);
        exit(NodeList);
    end;

    procedure GetValueFromNode(Node: XmlNode; XPath: Text): Text
    var
        Node2: XmlNode;
        Value: Text;
    begin
        Node.SelectSingleNode(XPath, Node2);
        Value := Node2.AsXmlElement().InnerText();
        exit(Value);
    end;

    local procedure NodeListToTempRecord(NodeList: XmlNodeList; XPathName: Text; var ContainerContent: Record "ABS Container Content")
    var
        ContainerContentHelper: Codeunit "ABS Container Content Helper";
        Node: XmlNode;
    begin
        ContainerContent.DeleteAll();

        if NodeList.Count = 0 then
            exit;

        foreach Node in NodeList do
            ContainerContentHelper.AddNewEntryFromNode(ContainerContent, Node, XPathName);
    end;

    local procedure NodeListToTempRecord(NodeList: XmlNodeList; XPathName: Text; var Container: Record "ABS Container")
    var
        ContainerHelper: Codeunit "ABS Container Helper";
        Node: XmlNode;
    begin
        Container.DeleteAll();

        if NodeList.Count = 0 then
            exit;
        foreach Node in NodeList do
            ContainerHelper.AddNewEntryFromNode(Container, Node, XPathName);
    end;
    // #endregion

    // #region Format Helper
    procedure GetFieldByName(TableNo: Integer; FldName: Text; var FldNo: Integer): Boolean
    var
        Fld: Record Field;
    begin
        Clear(FldNo);
        Fld.Reset();
        Fld.SetRange(TableNo, TableNo);
        Fld.SetRange(FieldName, FldName);
        if Fld.FindFirst() then
            FldNo := Fld."No.";
        exit(FldNo <> 0);
    end;
    // #endregion
}