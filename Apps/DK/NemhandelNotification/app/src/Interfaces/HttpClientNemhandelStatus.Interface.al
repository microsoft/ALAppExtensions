namespace Microsoft.EServices;

interface "Http Client Nemhandel Status"
{
    /// <summary>
    /// Sends a GET request to the Nemhandelregisteret service to check if a company is registered in the service.
    /// </summary>
    /// <param name="RequestURI">The URI to send the request to.</param>
    /// <param name="RequestMessage">The request message to send.</param>
    /// <param name="ResponseMessage">The response message wrapped in the interface.</param>
    /// <returns>True if the request was successful, false otherwise.</returns>
    procedure SendGetRequest(RequestURI: Text; var RequestMessage: HttpRequestMessage; var ResponseMessage: Interface "Http Response Msg Nemhandel") Result: Boolean

    /// <summary>
    /// Returns the URI from the Nemhandelregisteret API which is used to check if a company is registered in the service.
    /// </summary>
    /// <param name="CVRNumber">The CVR number of a company.</param>
    procedure GetRequestURI(CVRNumber: Text): Text
}