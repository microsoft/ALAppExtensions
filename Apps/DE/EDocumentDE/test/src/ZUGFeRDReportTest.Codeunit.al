codeunit 13923 "ZUGFeRD Report Test"
{
    Access = Internal;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Export ZUGFeRD Document", OnGetZUGFeRDReportIntegrations, '', false, false)]
    local procedure ExportZUGFeRDDocument_OnGetZUGFeRDReportIntegrations(var ZUGFeRDReportIntegrations: List of [Interface "ZUGFeRD Report Integration"])
    var
        ZUGFeRDXMLDocumentTests: Codeunit "ZUGFeRD XML Document Tests";
    begin
        ZUGFeRDReportIntegrations.Add(ZUGFeRDXMLDocumentTests);
    end;

}