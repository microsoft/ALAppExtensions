namespace Microsoft.EServices.EDocumentConnector.ForNAV;

codeunit 6413 "ForNAV Peppol Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;

    trigger OnUpgradePerCompany()
    var
        PeppolJobQueue: Codeunit "ForNAV Peppol Job Queue";
        PeppolOauth: Codeunit "ForNAV Peppol Oauth";
    begin
        PeppolJobQueue.SetupJobQueue();
        PeppolOauth.ValidateEndpoint(PeppolOauth.GetDefaultEndpoint(), true);
    end;
}