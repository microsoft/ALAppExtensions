// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8961 "AFS Directory Content Helper"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [NonDebuggable]
    procedure AddNewEntryFromNode(DirectoryURI: Text; DirectoryPath: Text[2048]; var AFSDirectoryContent: Record "AFS Directory Content"; var Node: XmlNode; XPathName: Text)
    var
        AFSHelperLibrary: Codeunit "AFS Helper Library";
        NameFromXml: Text;
        OuterXml: Text;
        ChildNodes: XmlNodeList;
        PropertiesNode: XmlNode;
        AttributesNode: XmlNode;
        PermissionKeyNode: XmlNode;
        ResourceType: Enum "AFS File Resource Type";
    begin
        NameFromXml := AFSHelperLibrary.GetValueFromNode(Node, XPathName);
        Node.WriteTo(OuterXml);
        Node.SelectSingleNode('.//Properties', PropertiesNode);
        ChildNodes := PropertiesNode.AsXmlElement().GetChildNodes();
        if Node.SelectSingleNode('.//Attributes', AttributesNode) then;
        if Node.SelectSingleNode('.//PermissionKey', PermissionKeyNode) then;
        Evaluate(ResourceType, Node.AsXmlElement().Name);

        AddNewEntry(DirectoryURI, DirectoryPath, ResourceType, AFSDirectoryContent, NameFromXml, OuterXml, ChildNodes, AttributesNode, PermissionKeyNode);
    end;

    [NonDebuggable]
    procedure AddNewEntry(DirectoryURI: Text; DirectoryPath: Text[2048]; ResourceType: Enum "AFS File Resource Type"; var AFSDirectoryContent: Record "AFS Directory Content"; NameFromXml: Text; OuterXml: Text; ChildNodes: XmlNodeList; AttributesNode: XmlNode; PermissionKeyNode: XmlNode)
    var
        OutStream: OutStream;
        EntryNo: Integer;
    begin
        AddParentEntries(DirectoryPath, AFSDirectoryContent);

        EntryNo := GetNextEntryNo(AFSDirectoryContent);

        AFSDirectoryContent.Init();
        AFSDirectoryContent."Parent Directory" := DirectoryPath;
        AFSDirectoryContent."Full Name" := AFSDirectoryContent."Parent Directory";
        if DirectoryPath.EndsWith('/') or (DirectoryPath = '') then
            AFSDirectoryContent."Full Name" += NameFromXml
        else
            AFSDirectoryContent."Full Name" += '/' + NameFromXml;
        AFSDirectoryContent.Level := GetLevel(AFSDirectoryContent."Full Name");
        AFSDirectoryContent."Resource Type" := ResourceType;
        AFSDirectoryContent.Name := GetName(NameFromXml);
        if DirectoryURI.EndsWith('/') then
            AFSDirectoryContent.URI := DirectoryURI + GetName(NameFromXml)
        else
            AFSDirectoryContent.URI := DirectoryURI + '/' + GetName(NameFromXml);

        SetPropertyFields(AFSDirectoryContent, ChildNodes);
        SetAttributesFields(AFSDirectoryContent, AttributesNode);
        SetPermissionKeyField(AFSDirectoryContent, PermissionKeyNode);

        AFSDirectoryContent."XML Value".CreateOutStream(OutStream);
        OutStream.Write(OuterXml);

        AFSDirectoryContent."Entry No." := EntryNo;
        AFSDirectoryContent.Insert(true);
    end;

    [NonDebuggable]
    local procedure AddParentEntries(DirectoryPath: Text; var AFSDirectoryContent: Record "AFS Directory Content")
    var
        FullNameTooLongErr: Label 'The full name (%1) of the directory is too long (over %2 characters).', Comment = '%1 - full name, %2 - max length';
        ParentEntries: List of [Text];
        CurrentParent, ParentEntryFullName, ParentEntryName : Text[2048];
        Level, EntryNo : Integer;
    begin
        // Check if the entry has parents: the DirectoryPath will be something like folder1/folder2.
        // For every parent folder, add a parent entry.
        // The list of node that comes from sorted by full name, so there is no need for extra re-arrangement.

        if DirectoryPath = '' then
            exit;

        CurrentParent := ''; // used to accumulate the full names of the entries

        ParentEntries := DirectoryPath.Split('/');

        for Level := 1 to ParentEntries.Count() do begin
            ParentEntryName := CopyStr(ParentEntries.Get(Level), 1, MaxStrLen(AFSDirectoryContent.Name));
            ParentEntryFullName := CopyStr(CurrentParent + ParentEntryName, 1, MaxStrLen(AFSDirectoryContent.Name));

            // Only create the parent entry if it doesn't exist already.
            // The full name should be unique.
            AFSDirectoryContent.SetRange("Full Name", ParentEntryFullName);
            if not AFSDirectoryContent.FindLast() and (ParentEntryName <> '') then begin
                EntryNo := GetNextEntryNo(AFSDirectoryContent);

                AFSDirectoryContent.Init();
                AFSDirectoryContent.Level := Level - 1; // Levels start from 0 to be used for indentation
                AFSDirectoryContent.Name := ParentEntryName;
                AFSDirectoryContent."Full Name" := ParentEntryFullName;
                AFSDirectoryContent."Parent Directory" := CurrentParent;
                AFSDirectoryContent."Resource Type" := AFSDirectoryContent."Resource Type"::Directory;

                AFSDirectoryContent."Entry No." := EntryNo;
                AFSDirectoryContent.Insert(true);
            end;

            if StrLen(AFSDirectoryContent."Full Name" + '/') > 2048 then
                Error(FullNameTooLongErr, AFSDirectoryContent."Full Name", MaxStrLen(AFSDirectoryContent."Full Name"));
            CurrentParent := CopyStr(AFSDirectoryContent."Full Name" + '/', 1, MaxStrLen(AFSDirectoryContent.Name));
        end;
    end;

    [NonDebuggable]
    local procedure SetPropertyFields(var AFSDirectoryContent: Record "AFS Directory Content"; ChildNodes: XmlNodeList)
    var
        AFSFormatHelper: Codeunit "AFS Format Helper";
        AFSHelperLibrary: Codeunit "AFS Helper Library";
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
                RecordRef.GetTable(AFSDirectoryContent);
                if AFSHelperLibrary.GetFieldByCaption(Database::"AFS Directory Content", PropertyName, FldNo) then begin
                    FieldRef := RecordRef.Field(FldNo);
                    case FieldRef.Type of
                        FieldRef.Type::DateTime:
                            FieldRef.Value := AFSFormatHelper.ConvertToDateTime(PropertyValue);
                        FieldRef.Type::Integer:
                            FieldRef.Value := AFSFormatHelper.ConvertToInteger(PropertyValue);
                        FieldRef.Type::Option:
                            FieldRef.Value := AFSFormatHelper.ConvertToEnum(FieldRef.Name, PropertyValue);
                        else
                            FieldRef.Value := PropertyValue;
                    end;
                end;
            end;
            RecordRef.SetTable(AFSDirectoryContent);
        end;
    end;

    local procedure SetAttributesFields(var AFSDirectoryContent: Record "AFS Directory Content" temporary; AttributesNode: XmlNode)
    var
        AFSHelperLibrary: Codeunit "AFS Helper Library";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        AttributesList: List of [Text];
        Attribute: Text;
        FldNo: Integer;
    begin
        if not AttributesNode.IsXmlElement() then
            exit;

        AttributesList := AttributesNode.AsXmlElement().InnerText.Replace(' ', '').Split('|');
        foreach Attribute in AttributesList do begin
            RecordRef.GetTable(AFSDirectoryContent);
            if AFSHelperLibrary.GetFieldByCaption(Database::"AFS Directory Content", Attribute, FldNo) then begin
                FieldRef := RecordRef.Field(FldNo);
                if FieldRef.Type = FieldType::Boolean then
                    FieldRef.Value := true;
            end;
            RecordRef.SetTable(AFSDirectoryContent);
        end;
    end;

    local procedure SetPermissionKeyField(var AFSDirectoryContent: Record "AFS Directory Content" temporary; PermissionKeyNode: XmlNode)
    begin
        if not PermissionKeyNode.IsXmlElement() then
            exit;
        AFSDirectoryContent."Permission Key" := CopyStr(PermissionKeyNode.AsXmlElement().InnerText, 1, MaxStrLen(AFSDirectoryContent."Permission Key"));
    end;

    [NonDebuggable]
    local procedure GetNextEntryNo(var AFSDirectoryContent: Record "AFS Directory Content"): Integer
    begin
        AFSDirectoryContent.Reset();

        if AFSDirectoryContent.FindLast() then
            exit(AFSDirectoryContent."Entry No." + 1)
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
}