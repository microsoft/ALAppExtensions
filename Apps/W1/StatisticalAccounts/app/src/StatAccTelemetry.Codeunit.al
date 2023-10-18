namespace Microsoft.Finance.Analysis.StatisticalAccount;

using System.Telemetry;

codeunit 2627 "Stat. Acc. Telemetry"
{
    SingleInstance = true;

    internal procedure LogAnalysisViewsUsage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if LoggedAnalysisViews then
            exit;

        FeatureTelemetry.LogUptake('0000KDU', GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000KDZ', GetFeatureTelemetryName(), 'Used Ananysis Views with Statistical Accounts');
        LoggedAnalysisViews := true;
    end;

    internal procedure LogFinancialReportUsage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if LoggedFinancialReports then
            exit;

        FeatureTelemetry.LogUptake('0000KDV', GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000KE0', GetFeatureTelemetryName(), 'Used Ananysis Views with Financial Reports');
        LoggedFinancialReports := true;
    end;

    internal procedure LogPostingUsage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if LoggedPosting then
            exit;

        FeatureTelemetry.LogUptake('0000KDW', GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000KE1', GetFeatureTelemetryName(), 'Posting used for Statistical Account Entries');
        LoggedPosting := true;
    end;

    internal procedure LogDiscovered()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000KDX', GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Discovered);
    end;

    internal procedure LogSetup()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000KDY', GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::"Set up");
    end;

    internal procedure GetFeatureTelemetryName(): Text
    begin
        exit('Statistical Accounts');
    end;

    var
        LoggedAnalysisViews: Boolean;
        LoggedFinancialReports: Boolean;
        LoggedPosting: Boolean;
}