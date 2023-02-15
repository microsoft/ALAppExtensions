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

        AddNewEntry(ABSContainerContent, NameFromXml, OuterXml, ChildNodes);
    end;

    [NonDebuggable]
    procedure AddNewEntry(var ABSContainerContent: Record "ABS Container Content"; NameFromXml: Text; OuterXml: Text; ChildNodes: XmlNodeList)
    var
        OutStream: OutStream;
        EntryNo: Integer;
    begin
        AddParentEntries(NameFromXml, ABSContainerContent);

        EntryNo := GetNextEntryNo(ABSContainerContent);

        ABSContainerContent.Init();
        ABSContainerContent.Level := GetLevel(NameFromXml);
        ABSContainerContent."Parent Directory" := GetParentDirectory(NameFromXml);
        ABSContainerContent."Full Name" := CopyStr(NameFromXml, 1, 250);
        ABSContainerContent.Name := GetName(NameFromXml);

        SetPropertyFields(ABSContainerContent, ChildNodes);

        ABSContainerContent."XML Value".CreateOutStream(OutStream);
        OutStream.Write(OuterXml);

        ABSContainerContent."Entry No." := EntryNo;
        ABSContainerContent.Insert(true);
    end;

    [NonDebuggable]
    local procedure AddParentEntries(NameFromXml: Text; var ABSContainerContent: Record "ABS Container Content")
    var
        ParentEntries: List of [Text];
        CurrentParent, ParentEntryFullName, ParentEntryName : Text[2048];
        Level, EntryNo : Integer;
    begin
        // Check if the entry has parents: the Name will be something like /folder1/folder2/blob-name.
        // For every parent folder, add a parent entry.
        // The list of node that comes from sorted by full name, so there is no need for extra re-arrangement.

        if not NameFromXml.Contains('/') then
            exit;

        CurrentParent := ''; // used to accumulate the full names of the entries

        ParentEntries := NameFromXml.Split('/');

        for Level := 1 to ParentEntries.Count() - 1
        do begin
            ParentEntryName := CopyStr(ParentEntries.Get(Level), 1, MaxStrLen(ABSContainerContent.Name));
            ParentEntryFullName := CopyStr(CurrentParent + ParentEntryName, 1, MaxStrLen(ABSContainerContent.Name));

            // Only create the parent entry if it doesn't exist already.
            // The full name should be unique.
            ABSContainerContent.SetRange("Full Name", ParentEntryFullName);
            if not ABSContainerContent.FindLast() then begin
                EntryNo := GetNextEntryNo(ABSContainerContent);

                ABSContainerContent.Init();
                ABSContainerContent.Level := Level - 1; // Levels start from 0 to be used for indentation
                ABSContainerContent.Name := ParentEntryName;
                ABSContainerContent."Full Name" := ParentEntryFullName;
                ABSContainerContent."Parent Directory" := CurrentParent;

                ABSContainerContent."Entry No." := EntryNo;
                ABSContainerContent.Insert(true);
            end;

            CurrentParent := CopyStr(ABSContainerContent."Full Name" + '/', 1, MaxStrLen(ABSContainerContent.Name));
        end;
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
        if ChildNodes.Count = 0 then
            exit;

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
                        FieldRef.Type::Option:
                            FieldRef.Value := ABSFormatHelper.ConvertToEnum(FieldRef.Name, PropertyValue);
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
        ABSContainerContent.Reset();

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
    local procedure GetParentDirectory(Name: Text): Text[250]
    var
        Parent: Text;
    begin
        if (not Name.Contains('/')) then
            exit('');

        Parent := CopyStr(Name, 1, Name.LastIndexOf('/'));

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