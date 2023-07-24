codeunit 139514 "Xml Data Handling SAF-T Test" implements XmlDataHandlingSAFT
{
    var
        NamespacePrefixTxt: label 'n1', Locked = true;
        NamespaceUriTxt: label 'urn:StandardAuditFile-Taxation-Financial:TEST', Locked = true;

    procedure GetAuditFileNamespace(var NamespacePrefix: Text; var NamespaceUri: Text)
    begin
        NamespacePrefix := NamespacePrefixTxt;
        NamespaceUri := NamespaceUriTxt;
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