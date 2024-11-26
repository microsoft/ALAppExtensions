namespace Microsoft.EServices.EDocumentConnector.Logiq;

using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Integration.Interfaces;

enumextension 6381 "E-Document Integration" extends "Service Integration"
{
    value(6381; "Logiq")
    {
        Caption = 'Logiq';
        Implementation = IDocumentSender = "E-Document Integration", IDocumentReceiver = "E-Document Integration";
    }
}