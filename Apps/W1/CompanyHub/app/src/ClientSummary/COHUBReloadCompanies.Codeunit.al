namespace Mirosoft.Integration.CompanyHub;

using System.Telemetry;

codeunit 1163 "COHUB Reload Companies"
{
    trigger OnRun()
    var
        COHUBCompanyKPI: Record "COHUB Company KPI";
        COHUBGroupCompanySummary: Record "COHUB Group Company Summary";
        COHUBCompanyEndpoint: Record "COHUB Company Endpoint";
        COHUBCore: Codeunit "COHUB Core";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        COHUBCore.ShowNotSupportedOnPremNotification();
        FeatureTelemetry.LogUptake('0000IFW', COHUBCore.GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000IFX', COHUBCore.GetFeatureTelemetryName(), 'Reloaded Companies');

        COHUBCompanyEndpoint.DeleteAll();
        COHUBCompanyKPI.DeleteAll();
        COHUBGroupCompanySummary.DeleteAll();

        Commit();

        COHUBCore.UpdateAllCompanies(false);
        Codeunit.Run(Codeunit::"COHUB Group Summary Sync");
        if GuiAllowed then
            Message(DataUpdatedSuccessfullyLbl);
    end;

    var
        DataUpdatedSuccessfullyLbl: Label 'The data was updated successfully';
}