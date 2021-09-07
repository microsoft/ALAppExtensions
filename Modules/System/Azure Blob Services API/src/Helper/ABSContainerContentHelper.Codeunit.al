// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9054 "ABS Container Content Helper"
{
    Access = Internal;

    [NonDebuggable]
    procedure AddNewEntryFromNode(var ContainerContent: Record "ABS Container Content"; var Node: XmlNode; XPathName: Text)
    var
        HelperLibrary: Codeunit "ABS Helper Library";
        NameFromXml: Text;
        OuterXml: Text;
        ChildNodes: XmlNodeList;
        PropertiesNode: XmlNode;
    begin
        NameFromXml := HelperLibrary.GetValueFromNode(Node, XPathName);
        Node.WriteTo(OuterXml);
        Node.SelectSingleNode('.//Properties', PropertiesNode);
        ChildNodes := PropertiesNode.AsXmlElement().GetChildNodes();
        if ChildNodes.Count = 0 then
            AddNewEntry(ContainerContent, NameFromXml, OuterXml)
        else
            AddNewEntry(ContainerContent, NameFromXml, OuterXml, ChildNodes);
    end;

    [NonDebuggable]
    procedure AddNewEntry(var ContainerContent: Record "ABS Container Content"; NameFromXml: Text; OuterXml: Text)
    var
        ChildNodes: XmlNodeList;
    begin
        AddNewEntry(ContainerContent, NameFromXml, OuterXml, ChildNodes);
    end;

    [NonDebuggable]
    procedure AddNewEntry(var ContainerContent: Record "ABS Container Content"; NameFromXml: Text; OuterXml: Text; ChildNodes: XmlNodeList)
    var
        NextEntryNo: Integer;
        Outstr: OutStream;
    begin
        if NameFromXml.Contains('/') then
            AddParentEntry(ContainerContent, NameFromXml);

        NextEntryNo := GetNextEntryNo(ContainerContent);

        ContainerContent.Init();

        ContainerContent."Entry No." := NextEntryNo;
        ContainerContent."Parent Directory" := GetDirectParentName(NameFromXml);
        ContainerContent.Level := GetLevel(NameFromXml);
        ContainerContent."Full Name" := CopyStr(NameFromXml, 1, 250);
        ContainerContent.Name := GetName(NameFromXml);
        SetPropertyFields(ContainerContent, ChildNodes);
        ContainerContent."XML Value".CreateOutStream(Outstr);
        Outstr.Write(OuterXml);

        ContainerContent.Insert(true);
    end;

    [NonDebuggable]
    local procedure AddParentEntry(var ContainerContent: Record "ABS Container Content"; NameFromXml: Text)
    var
        NextEntryNo: Integer;
    begin
        NextEntryNo := GetNextEntryNo(ContainerContent);

        ContainerContent.Init();

        ContainerContent."Entry No." := NextEntryNo;
        ContainerContent.Level := GetLevel(NameFromXml) - 1;
        ContainerContent.Name := GetDirectParentName(NameFromXml);
        ContainerContent."Parent Directory" := GetDirectParentName(NameFromXml);
        ContainerContent."Content Type" := 'Directory';

        ContainerContent.Insert(true);
    end;

    [NonDebuggable]
    local procedure SetPropertyFields(var ContainerContent: Record "ABS Container Content"; ChildNodes: XmlNodeList)
    var
        FormatHelper: Codeunit "ABS Format Helper";
        HelperLibrary: Codeunit "ABS Helper Library";
        RecRef: RecordRef;
        FldRef: FieldRef;
        ChildNode: XmlNode;
        PropertyName: Text;
        PropertyValue: Text;
        FldNo: Integer;
    begin
        foreach ChildNode in ChildNodes do begin
            PropertyName := ChildNode.AsXmlElement().Name;
            PropertyValue := ChildNode.AsXmlElement().InnerText;
            if PropertyValue <> '' then begin
                RecRef.GetTable(ContainerContent);
                if HelperLibrary.GetFieldByName(Database::"ABS Container Content", PropertyName, FldNo) then begin
                    FldRef := RecRef.Field(FldNo);
                    case FldRef.Type of
                        FldRef.Type::DateTime:
                            FldRef.Value := FormatHelper.ConvertToDateTime(PropertyValue);
                        FldRef.Type::Integer:
                            FldRef.Value := FormatHelper.ConvertToInteger(PropertyValue);
                        else
                            FldRef.Value := PropertyValue;
                    end;
                end;
            end;
            RecRef.SetTable(ContainerContent);
        end;
    end;

    [NonDebuggable]
    local procedure GetNextEntryNo(var ContainerContent: Record "ABS Container Content"): Integer
    begin
        if ContainerContent.FindLast() then
            exit(ContainerContent."Entry No." + 1)
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
    internal procedure GetFullNameFromXML(var ContainerContent: Record "ABS Container Content"): Text
    var
        HelperLibrary: Codeunit "ABS Helper Library";
        Node: XmlNode;
        NameFromXml: Text;
    begin
        GetXmlNodeForEntry(ContainerContent, Node);
        NameFromXml := HelperLibrary.GetValueFromNode(Node, './/Name');
        exit(NameFromXml);
    end;

    [NonDebuggable]
    local procedure GetXmlNodeForEntry(var ContainerContent: Record "ABS Container Content"; var Node: XmlNode)
    var
        InStr: InStream;
        XmlAsText: Text;
        Document: XmlDocument;
    begin
        ContainerContent.CalcFields("XML Value");
        ContainerContent."XML Value".CreateInStream(InStr);
        InStr.Read(XmlAsText);
        XmlDocument.ReadFrom(XmlAsText, Document);
        Node := Document.AsXmlNode();
    end;
}