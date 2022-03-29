// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9043 "ABS Helper Library"
{
    Access = Internal;
    Permissions = tabledata Field = r;

    // #region Container-specific Helper
    [NonDebuggable]
    procedure ContainerNodeListTotempRecord(NodeList: XmlNodeList; var ABSContainer: Record "ABS Container")
    begin
        NodeListToTempRecord(NodeList, './/Name', ABSContainer);
    end;

    [NonDebuggable]
    procedure CreateContainerNodeListFromResponse(ResponseAsText: Text): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(ResponseAsText, '/*/Containers/Container'));
    end;
    // #endregion

    [NonDebuggable]
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

    [NonDebuggable]
    procedure CreatePageRangesNodeListFromResponse(Document: XmlDocument): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(Document, '/*/PageRange'));
    end;

    [NonDebuggable]
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

    [NonDebuggable]
    procedure CreateBlockListCommitedNodeListFromResponse(Document: XmlDocument): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(Document, '/*/CommittedBlocks/Block'));
    end;

    [NonDebuggable]
    procedure CreateBlockListUncommitedNodeListFromResponse(Document: XmlDocument): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(Document, '/*/UncommittedBlocks/Block'));
    end;

    // #region Blob-specific Helper
    [NonDebuggable]
    procedure CreateBlobNodeListFromResponse(ResponseAsText: Text): XmlNodeList
    begin
        exit(CreateXPathNodeListFromResponse(ResponseAsText, '/*/Blobs/Blob'));
    end;

    [NonDebuggable]
    procedure BlobNodeListToTempRecord(NodeList: XmlNodeList)
    var
        ABSContainerContent: Record "ABS Container Content";
    begin
        BlobNodeListToTempRecord(NodeList, ABSContainerContent);
    end;

    [NonDebuggable]
    procedure BlobNodeListToTempRecord(NodeList: XmlNodeList; var ABSContainerContent: Record "ABS Container Content")
    begin
        NodeListToTempRecord(NodeList, './/Name', ABSContainerContent);
    end;
    // #endregion

    // #region XML Helper
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
    local procedure CreateXPathNodeListFromResponse(Document: XmlDocument; XPath: Text): XmlNodeList
    var
        RootNode: XmlElement;
        NodeList: XmlNodeList;
    begin
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
    local procedure NodeListToTempRecord(NodeList: XmlNodeList; XPathName: Text; var ABSContainerContent: Record "ABS Container Content")
    var
        ABSContainerContentHelper: Codeunit "ABS Container Content Helper";
        Node: XmlNode;
    begin
        ABSContainerContent.DeleteAll();

        if NodeList.Count = 0 then
            exit;

        foreach Node in NodeList do
            ABSContainerContentHelper.AddNewEntryFromNode(ABSContainerContent, Node, XPathName);
    end;

    [NonDebuggable]
    local procedure NodeListToTempRecord(NodeList: XmlNodeList; XPathName: Text; var ABSContainer: Record "ABS Container")
    var
        ContainerHelper: Codeunit "ABS Container Helper";
        Node: XmlNode;
    begin
        ABSContainer.DeleteAll();

        if NodeList.Count = 0 then
            exit;
        foreach Node in NodeList do
            ContainerHelper.AddNewEntryFromNode(ABSContainer, Node, XPathName);
    end;
    // #endregion

    // #region Format Helper
    [NonDebuggable]
    procedure GetFieldByName(TableNo: Integer; FldName: Text; var FldNo: Integer): Boolean
    var
        Field: Record Field;
    begin
        Clear(FldNo);
        Field.Reset();
        Field.SetRange(TableNo, TableNo);
        Field.SetRange(FieldName, CopyStr(FldName, 1, MaxStrLen(Field.FieldName)));
        if Field.FindFirst() then
            FldNo := Field."No.";
        exit(FldNo <> 0);
    end;
    // #endregion
}