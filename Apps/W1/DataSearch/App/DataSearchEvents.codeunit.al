namespace Microsoft.Foundation.DataSearch;

codeunit 2682 "Data Search Events"
{
    SingleInstance = true;
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Specifies the Field No. for the table type field. For example "Sales Header" would specify 1 = "Document Type"
    /// </summary>
    /// <param name="TableNo">The table no. of the table that is being searched.</param>
    /// <param name="FieldNo">The field no. of the 'document type' field.</param>
    [IntegrationEvent(false, false)]
    procedure OnGetFieldNoForTableType(TableNo: Integer; var FieldNo: Integer)
    begin
    end;

    /// <summary>
    /// Specifies the parent table if a table is a sub-table in a header/lines construct, such as Sales Line
    /// </summary>
    /// <param name="SubTableNo">The table no. of the table that is being searched.</param>
    /// <param name="ParentTableNo">If the the table is a sub-table, please specify the parent table here</param>
    [IntegrationEvent(false, false)]
    procedure OnGetParentTable(SubTableNo: Integer; var ParentTableNo: Integer)
    begin
    end;

    /// <summary>
    /// Specifies the sub table if a table is a parent table in a header/lines construct, such as Sales Line / Sales Header
    /// </summary>
    /// <param name="ParentTableNo">The table no. of the table that is being searched.</param>
    /// <param name="SubTableNo">If the the table is a parent table, please specify the sub table here</param>
    [IntegrationEvent(false, false)]
    procedure OnGetSubTable(ParentTableNo: Integer; var SubTableNo: Integer)
    begin
    end;

    /// <summary>
    /// Specifies the list page no. to be used for displaying the record. 
    /// Only needed if the page is not the standard list/card page for the table
    /// </summary>
    /// <param name="TableNo">The table no. of the table that is being displayed.</param>
    /// <param name="TableType">If the table as a 'Document Type'-like field, this value specifies the type as integer.</param>
    /// <param name="PageNo">The page to use to display the record.</param>
    [IntegrationEvent(false, false)]
    procedure OnGetListPageNo(TableNo: Integer; TableType: Integer; var PageNo: Integer)
    begin
    end;

    /// <summary>
    /// Specifies the card page no. to be used for displaying the record. If no card exists, then specify the list page no.
    /// Only needed if the page is not the standard list/card page for the table
    /// </summary>
    /// <param name="TableNo">The table no. of the table that is being displayed.</param>
    /// <param name="TableType">If the table as a 'Document Type'-like field, this value specifies the type as integer.</param>
    /// <param name="PageNo">The page to use to display the record.</param>
    [IntegrationEvent(false, false)]
    procedure OnGetCardPageNo(TableNo: Integer; TableType: Integer; var PageNo: Integer)
    begin
    end;

    /// <summary>
    /// Specifies the header RecordRef to a corresponding line RecordRef for e.g. sales line -> sales header
    /// </summary>
    /// <param name="LineRecRef">The line record</param>
    /// <param name="HeaderRecRef">The parent of the line record</param>
    [IntegrationEvent(false, false)]
    procedure OnMapLineRecToHeaderRec(var LineRecRef: RecordRef; var HeaderRecRef: RecordRef)
    begin
    end;

    /// <summary>
    /// Enables adding and removing tables from the default initial setup for tables to search.
    /// </summary>
    /// <param name="ProfileID">Page ID for the selected role center</param>
    /// <param name="ListOfTableNumbers">List of integer. Already filled with standard tables.</param>
    [IntegrationEvent(false, false)]
    procedure OnAfterGetRolecCenterTableList(RoleCenterID: Integer; var ListOfTableNumbers: List of [Integer])
    begin
    end;

    /// <summary>
    /// Enables adding and removing tables from the default initial setup for tables to search.
    /// </summary>
    /// <param name="TableNo">The table no. of the table that is being set up.</param>
    /// <param name="ListOfFieldNumbers">List of integer. You can specifify additional fields for a table here or remove unwanted.</param>
    [IntegrationEvent(false, false)]
    procedure OnAfterGetFieldListForTable(TableNo: Integer; var ListOfFieldNumbers: List of [Integer])
    begin
    end;

    /// <summary>
    /// Specifies whether a field is excluded from the default fields in a table, based on its table relation.
    /// Typically we would exclude fields from search that have relations to posting groups, reason codes, etc.
    /// </summary>
    /// <param name="RelatedTableNo">The table no. that the field has relation to.</param>
    /// <param name="IsExcluded">true/false whether the field should be excluded from the default setup.</param>
    [IntegrationEvent(false, false)]
    procedure OnGetExcludedRelatedTableField(RelatedTableNo: Integer; var IsExcluded: Boolean)
    begin
    end;

    /// <summary>
    /// Specifies the table subtype for a page.
    /// Typically this means 'document type' for a specific table that is source table for the page.
    /// </summary>
    /// <param name="PageNo">The page no. that we want to get the subtype ('document type') for.</param>
    /// <param name="TableSubType">Integer. The value of the subtype/document type.</param>
    [IntegrationEvent(false, false)]
    procedure OnGetTableSubTypeFromPage(PageNo: Integer; var TableSubtype: Integer)
    begin
    end;

    /// <summary>
    /// Allows the addition of additional filters for the specified <paramref name="RecordRef"/> during the search.
    /// </summary>
    /// <param name="RecordRef">The record on which the search is being conducted.</param>
    [IntegrationEvent(false, false)]
    procedure OnBeforeSearchTable(var RecordRef: RecordRef)
    begin
    end;
}