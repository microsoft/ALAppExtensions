/// <summary>
/// Handles installation verification for test libraries in SaaS environments.
/// </summary>
codeunit 132221 "Test Libraries SaaS Install"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        VerifyCanRunOnCurrentEnvironment();
    end;

    local procedure VerifyCanRunOnCurrentEnvironment()
    var
        UnsupportedEnvironmentErr: Label 'This functionality is only available in sandbox SaaS environments.';
    begin
        if not IsSupportedEnvironment() then
            Error(UnsupportedEnvironmentErr);
    end;


    procedure IsSupportedEnvironment(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit(true);

        if not EnvironmentInformation.IsSandbox() then
            exit(false);

        exit(true);
    end;
}