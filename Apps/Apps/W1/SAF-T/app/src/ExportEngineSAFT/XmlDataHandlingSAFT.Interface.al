#pragma warning disable AA0247
interface XmlDataHandlingSAFT
{
    /// <summary>
    /// Returns the namespace prefix and URI for the AuditFile element of the SAF-T xml file.
    /// </summary>
    /// <param name="Prefix">The namespace prefix.</param>
    /// <param name="Uri">The namespace URI.</param>
    procedure GetAuditFileNamespace(var Prefix: Text; var Uri: Text)

    /// <summary>
    /// Defines if the child nodes of the Header node can be modified/removed or other child nodes can be added.
    /// </summary>
    /// <param name="AddPrevSiblingsAllowed">Defines if other nodes can be added before the specific node.</param>
    /// <param name="AddNextSiblingsAllowed">Defines if other nodes can be added after the specific node.</param>
    /// <param name="AddChildNodesAllowed">Defines if child nodes can be added to the specific node.</param>
    /// <param name="SetNameValueAllowed">Defines if the name and value of the specific node can be modified.</param>
    /// <param name="RemoveNodeAllowed">Defines if the specific node can be removed.</param>
    procedure GetHeaderModificationAllowed(var AddPrevSiblingsAllowed: Boolean; var AddNextSiblingsAllowed: Boolean; var AddChildNodesAllowed: Boolean; var SetNameValueAllowed: Boolean; var RemoveNodeAllowed: Boolean)

    /// <summary>
    /// Defines if the child nodes of the MasterFiles node can be modified/removed or other child nodes can be added.
    /// The function is used to enchance the performance of the export process by allowing the specific modifications of the specific nodes.
    /// </summary>
    /// <param name="AuditFileExportDataType">The type of the data which defines the node name, for example Customers, Suppliers, Products, etc.</param>
    /// <param name="AddPrevSiblingsAllowed">Defines if other nodes can be added before the specific node.</param>
    /// <param name="AddNextSiblingsAllowed">Defines if other nodes can be added after the specific node.</param>
    /// <param name="AddChildNodesAllowed">Defines if child nodes can be added to the specific node.</param>
    /// <param name="SetNameValueAllowed">Defines if the name and value of the specific node can be modified.</param>
    /// <param name="RemoveNodeAllowed">Defines if the specific node can be removed.</param>
    procedure GetNodeModificationAllowed(AuditFileExportDataType: Enum "Audit File Export Data Type"; var AddPrevSiblingsAllowed: Boolean; var AddNextSiblingsAllowed: Boolean; var AddChildNodesAllowed: Boolean; var SetNameValueAllowed: Boolean; var RemoveNodeAllowed: Boolean)

    /// <summary>
    /// Returns the list of the nodes which should be added before the selected node.
    /// </summary>
    /// <param name="RecRef">The RecordRef of the record which is exported at the moment.</param>
    /// <param name="XPath">The XPath of the selected node.</param>
    /// <param name="NamespaceUri">The namespace URI of the nodes to add.</param>
    /// <param name="Params">The optional parameters that can be used to pass additional information to the implementation.</param>
    /// <returns>The list of the nodes which should be added before the selected node.</returns>
    procedure GetPrevSiblingsToAdd(RecRef: RecordRef; XPath: Text; NamespaceUri: Text; var Params: Dictionary of [Text, Text]) SiblingXmlNodes: XmlNodeList

    /// <summary>
    /// Returns the list of the nodes which should be added after the selected node.
    /// </summary>
    /// <param name="RecRef">The RecordRef of the record which is exported at the moment.</param>
    /// <param name="XPath">The XPath of the selected node.</param>
    /// <param name="NamespaceUri">The namespace URI of the nodes to add.</param>
    /// <param name="Params">The optional parameters that can be used to pass additional information to the implementation.</param>
    /// <returns>The list of the nodes which should be added after the selected node.</returns>
    procedure GetNextSiblingsToAdd(RecRef: RecordRef; XPath: Text; NamespaceUri: Text; var Params: Dictionary of [Text, Text]) SiblingXmlNodes: XmlNodeList

    /// <summary>
    /// Returns the list of the nodes which should be added as child nodes of the selected node.
    /// </summary>
    /// <param name="RecRef">The RecordRef of the record which is exported at the moment.</param>
    /// <param name="XPath">The XPath of the selected node.</param>
    /// <param name="NamespaceUri">The namespace URI of the nodes to add.</param>
    /// <param name="Params">The optional parameters that can be used to pass additional information to the implementation.</param>
    /// <returns>The list of the nodes which should be added as child nodes of the selected node.</returns>
    procedure GetChildNodesToAdd(RecRef: RecordRef; XPath: Text; NamespaceUri: Text; var Params: Dictionary of [Text, Text]) ChildXmlNodes: XmlNodeList

    /// <summary>
    /// Returns updated name and value of the selected node.
    /// </summary>
    /// <param name="Name">The new name of the selected node.</param>
    /// <param name="Content">The new value of the selected node.</param>
    /// <param name="EmptyContentAllowed">Defines if the selected node can be added with the empty value.</param>
    /// <param name="RecRef">The RecordRef of the record which is exported at the moment.</param>
    /// <param name="XPath">The XPath of the selected node.</param>
    /// <param name="Params">The optional parameters that can be used to pass additional information to the implementation.</param>
    procedure SetCurrXmlElementNameValue(var Name: Text; var Content: Text; var EmptyContentAllowed: Boolean; RecRef: RecordRef; XPath: Text; var Params: Dictionary of [Text, Text])

    /// <summary>
    /// Defines if the selected node should not be added.
    /// </summary>
    /// <param name="RecRef">The RecordRef of the record which is exported at the moment.</param>
    /// <param name="XPath">The XPath of the selected node.</param>
    /// <param name="Params">The optional parameters that can be used to pass additional information to the implementation.</param>
    /// <returns>True if the selected node should not be added, otherwise false.</returns>
    procedure RemoveCurrentXmlElement(RecRef: RecordRef; XPath: Text; var Params: Dictionary of [Text, Text]) RemoveElement: Boolean
}
