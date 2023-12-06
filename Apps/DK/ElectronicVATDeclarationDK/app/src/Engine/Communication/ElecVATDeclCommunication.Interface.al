namespace Microsoft.Finance.VAT.Reporting;

interface "Elec. VAT Decl. Communication"
{
    /// <summary>
    /// Sends a message contained in EnvelopeInStream to the specified endpoint and returns the response as an interface.
    /// </summary>
    /// <param name="EnvelopeInStream">Soap envelope as a stream to send.</param>
    /// <param name="Endpoint">URL for endpoint where to send the message.</param>
    /// <returns>Response from the endpoint, wrapped in an interface.</returns>
    procedure SendMessage(EnvelopeInStream: InStream; Endpoint: Text) Response: Interface "Elec. VAT Decl. Response";
}