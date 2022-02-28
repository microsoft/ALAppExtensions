// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9054 "ABS Container Content Helper"
{
    Access = Internal;

    [NonDebuggable]
    procedure AddNewEntryFromNode(var ABSContainerContent: Record "ABS Container Content"; var Node: XmlNode; XPathName: Text)
    var
        ABSHelperLibrary: Codeunit "ABS Helper Library";
        NameFromXml: Text;
        OuterXml: Text;
        ChildNodes: XmlNodeList;
        PropertiesNode: XmlNode;
    begin
        NameFromXml := ABSHelperLibrary.GetValueFromNode(Node, XPathName);
        Node.WriteTo(OuterXml);
        Node.SelectSingleNode('.//Properties', PropertiesNode);
        ChildNodes := PropertiesNode.AsXmlElement().GetChildNodes();
        if ChildNodes.Count = 0 then
            AddNewEntry(ABSContainerContent, NameFromXml, OuterXml)
        else
            AddNewEntry(ABSContainerContent, NameFromXml, OuterXml, ChildNodes);
    end;

    [NonDebuggable]
    procedure AddNewEntry(var ABSContainerContent: Record "ABS Container Content"; NameFromXml: Text; OuterXml: Text)
    var
        ChildNodes: XmlNodeList;
    begin
        AddNewEntry(ABSContainerContent, NameFromXml, OuterXml, ChildNodes);
    end;

    [NonDebuggable]
    procedure AddNewEntry(var ABSContainerContent: Record "ABS Container Content"; NameFromXml: Text; OuterXml: Text; ChildNodes: XmlNodeList)
    var
        NextEntryNo: Integer;
        OutStream: OutStream;
    begin
        if NameFromXml.Contains('/') then
            AddParentEntry(ABSContainerContent, NameFromXml);

        NextEntryNo := GetNextEntryNo(ABSContainerContent);

        ABSContainerContent.Init();

        ABSContainerContent."Entry No." := NextEntryNo;
        ABSContainerContent."Parent Directory" := GetDirectParentName(NameFromXml);
        ABSContainerContent.Level := GetLevel(NameFromXml);
        ABSContainerContent."Full Name" := CopyStr(NameFromXml, 1, 250);
        ABSContainerContent.Name := GetName(NameFromXml);
        SetPropertyFields(ABSContainerContent, ChildNodes);
        ABSContainerContent."XML Value".CreateOutStream(OutStream);
        OutStream.Write(OuterXml);

        ABSContainerContent.Insert(true);
    end;

    [NonDebuggable]
    local procedure AddParentEntry(var ABSContainerContent: Record "ABS Container Content"; NameFromXml: Text)
    var
        NextEntryNo: Integer;
    begin
        NextEntryNo := GetNextEntryNo(ABSContainerContent);

        ABSContainerContent.Init();

        ABSContainerContent."Entry No." := NextEntryNo;
        ABSContainerContent.Level := GetLevel(NameFromXml) - 1;
        ABSContainerContent.Name := GetDirectParentName(NameFromXml);
        ABSContainerContent."Parent Directory" := GetDirectParentName(NameFromXml);
        ABSContainerContent."Content Type" := 'Directory';

        ABSContainerContent.Insert(true);
    end;

    [NonDebuggable]
    local procedure SetPropertyFields(var ABSContainerContent: Record "ABS Container Content"; ChildNodes: XmlNodeList)
    var
        ABSFormatHelper: Codeunit "ABS Format Helper";
        ABSHelperLibrary: Codeunit "ABS Helper Library";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        ChildNode: XmlNode;
        PropertyName: Text;
        PropertyValue: Text;
        FldNo: Integer;
    begin
        foreach ChildNode in ChildNodes do begin
            PropertyName := ChildNode.AsXmlElement().Name;
            PropertyValue := ChildNode.AsXmlElement().InnerText;
            if PropertyValue <> '' then begin
                RecordRef.GetTable(ABSContainerContent);
                if ABSHelperLibrary.GetFieldByName(Database::"ABS Container Content", PropertyName, FldNo) then begin
                    FieldRef := RecordRef.Field(FldNo);
                    case FieldRef.Type of
                        FieldRef.Type::DateTime:
                            FieldRef.Value := ABSFormatHelper.ConvertToDateTime(PropertyValue);
                        FieldRef.Type::Integer:
                            FieldRef.Value := ABSFormatHelper.ConvertToInteger(PropertyValue);
                        else
                            FieldRef.Value := PropertyValue;
                    end;
                end;
            end;
            RecordRef.SetTable(ABSContainerContent);
        end;
    end;

    [NonDebuggable]
    local procedure GetNextEntryNo(var ABSContainerContent: Record "ABS Container Content"): Integer
    begin
        if ABSContainerContent.FindLast() then
            exit(ABSContainerContent."Entry No." + 1)
        else
            exit(1);
    end;

    [NonDebuggable]
    local procedure GetLevel(Name: Text): Integer
    var
        StringSplit: List of [Text];
    begin
        if not Name.Contains('/') then
            exit(0);
        StringSplit := Name.Split('/');
        exit(StringSplit.Count() - 1);
    end;

    [NonDebuggable]
    local procedure GetName(Name: Text): Text[250]
    var
        StringSplit: List of [Text];
    begin
        if not Name.Contains('/') then
            exit(CopyStr(Name, 1, 250));
        StringSplit := Name.Split('/');
        exit(CopyStr(StringSplit.Get(StringSplit.Count()), 1, 250));
    end;

    [NonDebuggable]
    local procedure GetDirectParentName(Name: Text): Text[250]
    var
        StringSplit: List of [Text];
        Parent: Text;
    begin
        if not Name.Contains('/') then
            exit('root');
        StringSplit := Name.Split('/');
        Parent := StringSplit.Get(1);
        if StringSplit.Count > 2 then
            Parent := StringSplit.Get(StringSplit.Count() - 1);
        exit(CopyStr(Parent, 1, 250));
    end;

    /// <summary>
    /// The name will be shortened if it has more than 250 characters
    /// Use this function to retrieve the original name of the blob (read from saved XmlNode)
    /// </summary>
    /// <returns>The Full name of the Blob, recovered from saved XmlNode</returns>
    [NonDebuggable]
    internal procedure GetFullNameFromXML(var ABSContainerContent: Record "ABS Container Content"): Text
    var
        ABSHelperLibrary: Codeunit "ABS Helper Library";
        Node: XmlNode;
        NameFromXml: Text;
    begin
        GetXmlNodeForEntry(ABSContainerContent, Node);
        NameFromXml := ABSHelperLibrary.GetValueFromNode(Node, './/Name');
        exit(NameFromXml);
    end;

    [NonDebuggable]
    local procedure GetXmlNodeForEntry(var ABSContainerContent: Record "ABS Container Content"; var Node: XmlNode)
    var
        InStream: InStream;
        XmlAsText: Text;
        Document: XmlDocument;
    begin
        ABSContainerContent.CalcFields("XML Value");
        ABSContainerContent."XML Value".CreateInStream(InStream);
        InStream.Read(XmlAsText);
        XmlDocument.ReadFrom(XmlAsText, Document);
        Node := Document.AsXmlNode();
    end;
}