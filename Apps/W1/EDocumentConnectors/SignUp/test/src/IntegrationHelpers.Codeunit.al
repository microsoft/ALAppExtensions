namespace Microsoft.EServices.EDocumentConnector.SignUp;


codeunit 148194 IntegrationHelpers
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
        SignUpConnectionSetup: Record "SignUp Connection Setup";
    begin
        SignUpConnectionSetup.Get();
        SignUpConnectionSetup."Service URL" := this.SetMockServiceUrl(Path);
        SignUpConnectionSetup.Modify(true);
    end;

    internal procedure SetCommonConnectionSetup()
    var
        SignUpConnectionSetup: Record "SignUp Connection Setup";
        SignUpAuthentication: Codeunit "SignUp Authentication";
    begin
        SignUpConnectionSetup.Get();
        SignUpAuthentication.StorageSet(SignUpConnectionSetup."Marketplace App ID", this.DummyId());
        SignUpAuthentication.StorageSet(SignUpConnectionSetup."Marketplace Secret", this.DummyId());
        SignUpAuthentication.StorageSet(SignUpConnectionSetup."Marketplace Tenant", this.DummyId());
        SignUpAuthentication.StorageSet(SignUpConnectionSetup."Client ID", this.DummyId());
        SignUpAuthentication.StorageSet(SignUpConnectionSetup."Client Secret", this.DummyId());
        SignUpAuthentication.StorageSet(SignUpConnectionSetup."Client Tenant", this.ClientTenantId());

        SignUpConnectionSetup."Authentication URL" := this.SetMockServiceUrl('/%1/oauth2/token');
        SignUpConnectionSetup."Environment Type" := SignUpConnectionSetup."Environment Type"::Test;
        SignUpConnectionSetup.Modify(true);
    end;

    internal procedure SetMockServiceUrl(Path: Text): Text[250]
    begin
        exit('https://localhost:8080' + Path);
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