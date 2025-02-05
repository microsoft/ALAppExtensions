namespace Microsoft.EServices.EDocumentConnector.SignUp;


codeunit 148196 IntegrationHelpers
{
    internal procedure SetAPIWith200Code()
    begin
        this.SetAPICode('/signup/200');
    end;

    internal procedure SetAPIWith500Code()
    begin
        this.SetAPICode('/signup/500');
    end;

    internal procedure SetAPICode(Path: Text)
    var
        ConnectionSetup: Record ConnectionSetup;
    begin
        ConnectionSetup.Get();
        ConnectionSetup."Service URL" := this.SetMockServiceUrl(Path);
        ConnectionSetup.Modify(true);
    end;

    internal procedure SetCommonConnectionSetup()
    var
        ConnectionSetup: Record ConnectionSetup;
        Authentication: Codeunit Authentication;
    begin
        ConnectionSetup.Get();
        Authentication.StorageSet(ConnectionSetup."Root App ID", this.DummyId());
        Authentication.StorageSet(ConnectionSetup."Root Secret", this.DummyId());
        Authentication.StorageSet(ConnectionSetup."Root Tenant", this.DummyId());
        Authentication.StorageSet(ConnectionSetup."Client ID", this.DummyId());
        Authentication.StorageSet(ConnectionSetup."Client Secret", this.DummyId());
        Authentication.StorageSet(ConnectionSetup."Client Tenant", this.ClientTenantId());

        ConnectionSetup."Authentication URL" := this.SetMockServiceUrl('/%1/oauth2/token');
        ConnectionSetup."Environment Type" := ConnectionSetup."Environment Type"::Test;
        ConnectionSetup.Modify(true);
    end;

    internal procedure SetMockServiceUrl(Path: Text): Text[250]
    begin
        exit('http://localhost:8080' + Path);
    end;

    local procedure ClientTenantId(): Text
    begin
        exit('signup');
    end;

    local procedure DummyId(): Text[100]
    begin
        exit('0a4b7f70-452a-4883-844f-296443704124');
    end;

    internal procedure MockServiceDocumentId(): Text
    begin
        exit('485959a5-4a96-4a41-a208-13c30bb7e4d3');
    end;

    internal procedure MockCompanyId(): Text[100]
    begin
        exit('0007:SIGNUPSOFTWARE');
    end;
}