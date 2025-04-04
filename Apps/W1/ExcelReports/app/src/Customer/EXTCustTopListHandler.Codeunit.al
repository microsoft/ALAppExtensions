codeunit 4407 "EXT Cust. Top List Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Small Business Report Catalog", OnBeforeRunCustomerTop10ListReport, '', false, false)]
    local procedure SmallBusinessReportCatalog_OnBeforeRunCustomerTop10ListReport(UseRequestPage: Boolean; var IsHandled: Boolean)
    var
        CustomerTopList: Report "EXR Customer Top List";
    begin
        CustomerTopList.UseRequestPage(UseRequestPage);
        CustomerTopList.Run();
        
        IsHandled := true;
    end;
}