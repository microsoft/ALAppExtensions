namespace Microsoft.Finance.VAT.Reporting;

interface "Elec. VAT Decl. Payload Builder"
{
    /// <summary>
    /// Builds the payload (XML Body node) for the request to the skat services according to type of the request
    /// </summary>
    /// <param name="ElecVATDeclParameters">Parameters for the request, could include dates, VAT Return No. or Transaction ID, depending on the request type.</param>
    /// <param name="Body">Resulting body of the request as an XmlNode.</param>
    /// <param name="ReferenceList">List of text references that will be used for signing of this returned body.</param>
    /// <param name="TransactionID">Transaction ID generated for this request.</param>
    procedure BuildPayload(ElecVATDeclParameters: Record "Elec. VAT Decl. Parameters"; var Body: XmlNode; var ReferenceList: List of [Text]; var TransactionID: Code[100])
}