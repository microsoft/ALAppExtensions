namespace Microsoft.Sustainability.Setup;

using Microsoft.Foundation.Company;

codeunit 6217 "Install Sustainability Setup"
{
    Subtype = Install;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnInstallAppPerCompany()
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.InitRecord();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure OnCompanyInitialize()
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.InitRecord();
    end;
}