namespace Microsoft.PowerBIReports;

using System.Environment.Configuration;
using Microsoft.Foundation.Company;
using System.DataAdministration;

codeunit 36950 "Installation Handler"
{
    Access = Internal;
    Subtype = Install;

    var
        Initialization: Codeunit Initialization;

    trigger OnInstallAppPerCompany()
    begin
        Initialization.SetupDefaultsForPowerBIReportsIfNotInitialized();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure OnCompanyInitialize()
    begin
        Initialization.SetupDefaultsForPowerBIReportsIfNotInitialized();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure OnClearCompanyConfig(CompanyName: Text)
    begin
        ClearCompanySpecificSetup(CompanyName);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure OnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    begin
        ClearCompanySpecificSetup(NewCompanyName);
    end;

    local procedure ClearCompanySpecificSetup(CompanyName: Text)
    var
        PowerBIReportsSetup: Record "PowerBI Reports Setup";
    begin
        if CompanyName <> '' then
            PowerBIReportsSetup.ChangeCompany(CompanyName);
        if PowerBIReportsSetup.FindFirst() then begin
            Clear(PowerBIReportsSetup."Finance Report Id");
            Clear(PowerBIReportsSetup."Finance Report Name");
            Clear(PowerBIReportsSetup."Sales Report Id");
            Clear(PowerBIReportsSetup."Sales Report Name");
            Clear(PowerBIReportsSetup."Purchases Report Id");
            Clear(PowerBIReportsSetup."Purchases Report Name");
            Clear(PowerBIReportsSetup."Inventory Report Id");
            Clear(PowerBIReportsSetup."Inventory Report Name");
            Clear(PowerBIReportsSetup."Projects Report Id");
            Clear(PowerBIReportsSetup."Projects Report Name");
            Clear(PowerBIReportsSetup."Manufacturing Report Id");
            Clear(PowerBIReportsSetup."Manufacturing Report Name");
            PowerBIReportsSetup.Modify();
        end;
    end;
}