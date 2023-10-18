// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

codeunit 5282 "Xml Data Handling SAF-T" implements XmlDataHandlingSAFT
{
    Access = Internal;

    procedure GetAuditFileNamespace(var Prefix: Text; var Uri: Text)
    begin
    end;

    procedure GetHeaderModificationAllowed(var AddPrevSiblingsAllowed: Boolean; var AddNextSiblingsAllowed: Boolean; var AddChildNodesAllowed: Boolean; var SetNameValueAllowed: Boolean; var RemoveNodeAllowed: Boolean)
    begin
        AddPrevSiblingsAllowed := false;
        AddNextSiblingsAllowed := false;
        AddChildNodesAllowed := false;
        SetNameValueAllowed := false;
        RemoveNodeAllowed := false;
    end;

    procedure GetNodeModificationAllowed(AuditFileExportDataType: Enum "Audit File Export Data Type"; var AddPrevSiblingsAllowed: Boolean; var AddNextSiblingsAllowed: Boolean; var AddChildNodesAllowed: Boolean; var SetNameValueAllowed: Boolean; var RemoveNodeAllowed: Boolean)
    begin
        AddPrevSiblingsAllowed := false;
        AddNextSiblingsAllowed := false;
        AddChildNodesAllowed := false;
        SetNameValueAllowed := false;
        RemoveNodeAllowed := false;
    end;

    procedure GetPrevSiblingsToAdd(RecRef: RecordRef; XPath: Text; NamespaceUri: Text; var Params: Dictionary of [Text, Text]) SiblingXmlNodes: XmlNodeList
    begin
    end;

    procedure GetNextSiblingsToAdd(RecRef: RecordRef; XPath: Text; NamespaceUri: Text; var Params: Dictionary of [Text, Text]) SiblingXmlNodes: XmlNodeList
    begin
    end;

    procedure GetChildNodesToAdd(RecRef: RecordRef; XPath: Text; NamespaceUri: Text; var Params: Dictionary of [Text, Text]) ChildXmlNodes: XmlNodeList
    begin
    end;

    procedure SetCurrXmlElementNameValue(var Name: Text; var Content: Text; var EmptyContentAllowed: Boolean; RecRef: RecordRef; XPath: Text; var Params: Dictionary of [Text, Text])
    begin
    end;

    procedure RemoveCurrentXmlElement(RecRef: RecordRef; XPath: Text; var Params: Dictionary of [Text, Text]) RemoveElement: Boolean
    begin
    end;
}
