codeunit 10685 "Elec. VAT Submit Return"
{

    TableNo = "VAT Report Header";

    trigger OnRun()
    var
        ElecVATConnectionMgt: Codeunit "Elec. VAT Connection Mgt.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        NOVATReportTok: Label 'NO VAT Reporting', Locked = true;
    begin
        FeatureTelemetry.LogUptake('0000HTI', NOVATReportTok, Enum::"Feature Uptake Status"::"Used");
        ElecVATConnectionMgt.SubmitVATReturn(Rec);
        FeatureTelemetry.LogUsage('0000HTJ', NOVATReportTok, 'NO VAT Reported Generated');
    end;
}