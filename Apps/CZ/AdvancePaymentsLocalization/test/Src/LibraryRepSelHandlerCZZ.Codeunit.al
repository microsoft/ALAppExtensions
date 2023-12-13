codeunit 148118 "Library - Rep.Sel. Handler CZZ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Report Selection", 'OnAfterGetReportId', '', false, false)]
    local procedure ConvertStandardReportsToCZLReportsOnAfterGetReportId(RecUsage: Enum "Report Selection Usage"; var ReportId: Integer)
    begin
        case RecUsage of
            RecUsage::"S.Invoice":
                ReportId := Report::"Sales - Invoice with Adv. CZZ";
            RecUsage::"P.Invoice":
                ReportId := Report::"Purchase-Invoice with Adv. CZZ";
        end;
    end;
}