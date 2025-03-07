namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.Company;

codeunit 8051 "Sub. Billing Installation"
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerCompany()
    var
        ServiceContractSetup: Record "Subscription Contract Setup";
    begin
        ServiceContractSetup.InitRecord();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure OnCompanyInitialize()
    var
        ServiceContractSetup: Record "Subscription Contract Setup";
    begin
        ServiceContractSetup.InitRecord();
    end;
}