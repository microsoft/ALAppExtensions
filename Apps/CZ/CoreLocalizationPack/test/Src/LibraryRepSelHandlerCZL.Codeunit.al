codeunit 148105 "Library - Rep.Sel. Handler CZL"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Report Selection", 'OnAfterGetReportId', '', false, false)]
    local procedure ConvertStandardReportsToCZLReportsOnAfterGetReportId(RecUsage: Enum "Report Selection Usage"; var ReportId: Integer)
    begin
        case RecUsage of
            RecUsage::"S.Quote":
                ReportId := Report::"Sales Quote CZL";
            RecUsage::"S.Order":
                ReportId := Report::"Sales Order Confirmation CZL";
            RecUsage::"S.Invoice":
                if ReportId = Report::"Standard Sales - Invoice" then
                    ReportId := Report::"Sales Invoice CZL";
            RecUsage::"S.Return":
                ReportId := Report::"Sales Return Order Confirm CZL";
            RecUsage::"S.Cr.Memo":
                ReportId := Report::"Sales Credit Memo CZL";
            RecUsage::"S.Shipment":
                ReportId := Report::"Sales Shipment CZL";
            RecUsage::"S.Ret.Rcpt.":
                ReportId := Report::"Sales Return Reciept CZL";
            RecUsage::"P.Quote":
                ReportId := Report::"Purchase Quote CZL";
            RecUsage::"P.Blanket":
                ReportId := Report::"Blanket Purchase Order CZL";
            RecUsage::"P.Order":
                ReportId := Report::"Purchase Order CZL";
            RecUsage::Reminder:
                ReportId := Report::"Reminder CZL";
            RecUsage::"Fin.Charge":
                ReportId := Report::"Finance Charge Memo CZL";
            RecUsage::"SM.Quote":
                ReportId := Report::"Service Quote CZL";
            RecUsage::"SM.Order":
                ReportId := Report::"Service Order CZL";
            RecUsage::"SM.Invoice":
                ReportId := Report::"Service Invoice CZL";
            RecUsage::"SM.Credit Memo":
                ReportId := Report::"Service Credit Memo CZL";
            RecUsage::"SM.Shipment":
                ReportId := Report::"Service Shipment CZL";
            RecUsage::"SM.Contract Quote":
                ReportId := Report::"Service Contract Quote CZL";
            RecUsage::"SM.Contract":
                ReportId := Report::"Service Contract CZL";
        end;
    end;
}