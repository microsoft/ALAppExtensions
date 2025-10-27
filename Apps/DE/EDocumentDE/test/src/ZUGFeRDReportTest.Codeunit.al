namespace Microsoft.eServices.EDocument.Formats;

codeunit 13923 "ZUGFeRD Report Test"
{
    Access = Internal;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export ZUGFeRD Document", OnGetZUGFeRDReportIntegrations, '', false, false)]
    local procedure ExportZUGFeRDDocument_OnGetZUGFeRDReportIntegrations(var ZUGFeRDReportIntegrations: List of [Interface "ZUGFeRD Report Integration"])
    var
        ZUGFeRDCustomReport: Codeunit "ZUGFeRD Custom Report";
    begin
        ZUGFeRDReportIntegrations.Add(ZUGFeRDCustomReport);
    end;

}