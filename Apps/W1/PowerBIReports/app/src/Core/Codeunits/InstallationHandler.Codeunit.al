namespace Microsoft.PowerBIReports;

using System.Environment.Configuration;
using System.Media;
using Microsoft.Foundation.Company;

codeunit 36950 "Installation Handler"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        GuidedExperience: Codeunit "Guided Experience";
        AppInfo: ModuleInfo;
        AssistedSetupLbl: Label 'Connect to Power BI', MaxLength = 50;
        AssistedSetupDescriptionTxt: Label 'Connect to your data to Power BI for better insights into your business. Here you connect and configure how your data will be displayed in Power BI.', MaxLength = 1024;
        AppHelpUrlTxt: Label 'https://learn.microsoft.com/dynamics365/business-central/', Locked = true;
    begin
        if NavApp.GetCurrentModuleInfo(AppInfo) then
            GuidedExperience.InsertAssistedSetup(
               AssistedSetupLbl,
               AssistedSetupLbl,
               AssistedSetupDescriptionTxt,
               5,
               ObjectType::Page,
               Page::"Assisted Setup",
               Enum::"Assisted Setup Group"::Connect,
               '',
               Enum::"Video Category"::Connect,
               AppHelpUrlTxt
           );
        RunAfterInstalled();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure OnCompanyInitialize()
    begin
        RunAfterInstalled();
    end;

    local procedure RunAfterInstalled()
    var
        PBIMgt: Codeunit Initialization;
        JobQueueDescLbl: Label 'Update Power BI Dimension Set Entries', MaxLength = 250;
    begin
        PBIMgt.InitialisePBISetup();
        PBIMgt.InitialisePBIWorkingDays();
        PBIMgt.InitialiseStartingEndingDates();
        PBIMgt.InitialiseJobQueue(Codeunit::"Update Dim. Set Entries", JobQueueDescLbl);
        PBIMgt.InitDimSetEntryLastUpdated();
    end;
}