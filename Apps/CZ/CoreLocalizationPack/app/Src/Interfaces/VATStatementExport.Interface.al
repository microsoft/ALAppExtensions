interface "VAT Statement Export CZL"
{
    /// <summary>
    /// Export VAT Statement to XML file.
    /// </summary>
    /// <param name="VATStatementName">Record "VAT Statement Name" which will be calculated and exported.</param>
    /// <returns>Exported file name.</returns>
    procedure ExportToXMLFile(VATStatementName: Record "VAT Statement Name"): Text

    /// <summary>
    /// Export VAT Statement to TempBlob.
    /// </summary>
    /// <param name="VATStatementName">Record "VAT Statement Name" which will be calculated and exported.</param>
    /// <param name="TempBlob">Pointer of type Codeunit "Temp Blob" into which the XML export output is filled.</param>
    procedure ExportToXMLBlob(VATStatementName: Record "VAT Statement Name"; var TempBlob: Codeunit "Temp Blob")

    /// <summary>
    /// Fill "VAT Attribute Code CZL" table with set of records for a specific XML Format.
    /// </summary>
    /// <param name="VATStatementTemplateName">VAT statement template name for which attributes are initialized.</param>
    procedure InitVATAttributes(VATStatementTemplateName: Code[10])
}
