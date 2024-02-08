namespace Microsoft.EServices;

using Microsoft.Foundation.Company;
using System.Telemetry;

codeunit 13609 "Upd. Registered with Nemhandel"
{
    Access = Internal;

    var
        BckGrndTaskCompletedTxt: Label 'Background task to check if company registered in Nemhandel completed. Status: %1', Comment = '%1 - Registered/NotRegistered/Unknown', Locked = true;
        NemhandelsregisteretCategoryTxt: Label 'Nemhandelsregisteret', Locked = true;

    trigger OnRun()
    var
        CompanyInformation: Record "Company Information";
        NemhandelCompanyStatus: Codeunit "Nemhandel Status Page Bckgrnd";
        Telemetry: Codeunit Telemetry;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CompanyInformation.Get();
        CompanyInformation."Registered with Nemhandel" := NemhandelCompanyStatus.GetCompanyStatus(CompanyInformation."Registration No.");
        CompanyInformation."Last Nemhandel Status Check DT" := CurrentDateTime();
        CompanyInformation.Modify();

        CustomDimensions.Add('Category', NemhandelsregisteretCategoryTxt);
        Telemetry.LogMessage(
            '0000KXX', StrSubstNo(BckGrndTaskCompletedTxt, CompanyInformation."Registered with Nemhandel"), Verbosity::Normal,
            DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, CustomDimensions);
    end;
}