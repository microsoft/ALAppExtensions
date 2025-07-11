namespace Microsoft.Finance.CashDesk;

using System.Telemetry;

codeunit 31153 "Alloc. Acc. Telemetry CZP"
{
    SingleInstance = true;
    Access = Internal;

    internal procedure LogCashDocumentPostingUsage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if LoggedCashDocumentPosting then
            exit;

        FeatureTelemetry.LogUptake('0000MXH', GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::Used);
        FeatureTelemetry.LogUsage('0000MXI', GetFeatureTelemetryName(), 'Posted Gash Document Line with Allocation Account');
        LoggedCashDocumentPosting := true;
    end;

    internal procedure GetFeatureTelemetryName(): Text
    begin
        exit('Allocation Accounts');
    end;

    var
        LoggedCashDocumentPosting: Boolean;
}