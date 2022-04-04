// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9055 "ABS Container Helper"
{
    Access = Internal;

    [NonDebuggable]
    procedure AddNewEntryFromNode(var ABSContainer: Record "ABS Container"; var Node: XmlNode; XPathName: Text)
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
            AddNewEntry(ABSContainer, NameFromXml, OuterXml)
        else
            AddNewEntry(ABSContainer, NameFromXml, OuterXml, ChildNodes);
    end;

    [NonDebuggable]
    procedure AddNewEntry(var ABSContainer: Record "ABS Container"; NameFromXml: Text; OuterXml: Text)
    var
        ChildNodes: XmlNodeList;
    begin
        AddNewEntry(ABSContainer, NameFromXml, OuterXml, ChildNodes);
    end;

    [NonDebuggable]
    procedure AddNewEntry(var ABSContainer: Record "ABS Container"; NameFromXml: Text; OuterXml: Text; ChildNodes: XmlNodeList)
    var
        Outstr: OutStream;
    begin
        ABSContainer.Init();
        ABSContainer.Name := CopyStr(NameFromXml, 1, 250);
        SetPropertyFields(ABSContainer, ChildNodes);
        ABSContainer."XML Value".CreateOutStream(Outstr);
        Outstr.Write(OuterXml);
        ABSContainer.Insert(true);
    end;

    [NonDebuggable]
    local procedure SetPropertyFields(var ABSContainer: Record "ABS Container"; ChildNodes: XmlNodeList)
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
                RecordRef.GetTable(ABSContainer);
                if ABSHelperLibrary.GetFieldByName(Database::"ABS Container", PropertyName, FldNo) then begin
                    FieldRef := RecordRef.Field(FldNo);
                    case FieldRef.Type of
                        FieldRef.Type::DateTime:
                            FieldRef.Value := ABSFormatHelper.ConvertToDateTime(PropertyValue);
                        FieldRef.Type::Integer:
                            FieldRef.Value := ABSFormatHelper.ConvertToInteger(PropertyValue);
                        FieldRef.Type::Boolean:
                            FieldRef.Value := ABSFormatHelper.ConvertToBoolean(PropertyValue);
                        else
                            FieldRef.Value := PropertyValue;
                    end;
                end;
            end;
            RecordRef.SetTable(ABSContainer);
        end;
    end;
}