namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Sales.History;

codeunit 13924 "ZUGFeRD Custom Report" implements "ZUGFeRD Report Integration"
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    InherentPermissions = X;

    var
        ZUGFeRDCustomReport: Codeunit "ZUGFeRD Custom Report";

    internal procedure BindSubscriptionForReportIntegration()
    begin
        BindSubscription(ZUGFeRDCustomReport);
    end;

    internal procedure UnbindSubscriptionForReportIntegration()
    begin
        UnbindSubscription(ZUGFeRDCustomReport);
    end;

    [EventSubscriber(ObjectType::Report, Report::"ZUGFeRD Custom Sales Invoice", OnPreReportOnBeforeInitializePDF, '', false, false)]
    local procedure OnBeforeInitializePDFSalesInvoice(SalesInvHeader: Record "Sales Invoice Header"; var CreateZUGFeRDXML: Boolean)
    begin
        CreateZUGFeRDXML := true;
    end;

}