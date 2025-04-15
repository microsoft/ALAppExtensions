namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration;

tableextension 6246261 "ForNAV E-Document Service" extends "E-Document Service"
{
    procedure IsForNAVServiceIntegration(): Boolean
    begin
        exit("Service Integration V2" = ForNAVServiceIntegration());
    end;

    internal procedure ForNAVServiceIntegration(): Enum "Service Integration"
    begin
        exit("Service Integration V2"::FORNAV);
    end;
}