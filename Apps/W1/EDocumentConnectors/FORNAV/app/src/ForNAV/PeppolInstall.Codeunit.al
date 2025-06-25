namespace Microsoft.EServices.EDocumentConnector.ForNAV;

codeunit 6411 "ForNAV Peppol Install"
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerCompany()
    var
        PepplolJobQueue: Codeunit "ForNAV Peppol Job Queue";
        PeppolOauth: Codeunit "ForNAV Peppol Oauth";
    begin
        PepplolJobQueue.SetupJobQueue();
        PeppolOauth.ValidateEndpoint(PeppolOauth.GetDefaultEndpoint(), true);
    end;
}