namespace Microsoft.EServices.EDocumentConnector.SignUp;


codeunit 148197 IntegrationEvents
{
    EventSubscriberInstance = Manual;

    var
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        IntegrationHelpers: Codeunit IntegrationHelpers;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Processing, OnBeforeGetTargetDocumentRequest, '', true, true)]
    local procedure ProcessingOnBeforeGetTargetDocumentRequest()
    begin
        this.LibraryLowerPermissions.AddPermissionSet('SignUpEDCOEdit');
        this.IntegrationHelpers.SetAPICode('/signup/200/download');
        this.LibraryLowerPermissions.AddPermissionSet('SignUpEDCORead');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Processing, OnBeforeGetTargetDocumentRequest, '', true, true)]
    local procedure ProcessingOnBeforeMarkFetched()
    begin
        this.LibraryLowerPermissions.AddPermissionSet('SignUpEDCOEdit');
        this.IntegrationHelpers.SetAPICode('/signup/200/markdownloaded');
        this.LibraryLowerPermissions.AddPermissionSet('SignUpEDCORead');
    end;
}