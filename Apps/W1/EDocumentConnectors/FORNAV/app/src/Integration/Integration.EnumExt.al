namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Integration;


enumextension 6246260 "ForNAV Integration" extends "Service Integration"
{
    value(6246260; "FORNAV")
    {
        Implementation = IDocumentSender = "ForNAV Integration Impl.", IDocumentReceiver = "ForNAV Integration Impl.", IConsentManager = "ForNAV Integration Impl.";
    }
}