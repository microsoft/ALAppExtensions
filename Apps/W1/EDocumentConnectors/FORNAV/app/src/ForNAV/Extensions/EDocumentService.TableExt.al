namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration;

tableextension 6411 "ForNAV E-Document Service" extends "E-Document Service"
{
    internal procedure ForNAVIsServiceIntegration(): Boolean
    begin
        exit("Service Integration V2" = ForNAVServiceIntegration());
    end;

    internal procedure ForNAVServiceIntegration(): Enum "Service Integration"
    begin
        exit("Service Integration V2"::FORNAV);
    end;
}