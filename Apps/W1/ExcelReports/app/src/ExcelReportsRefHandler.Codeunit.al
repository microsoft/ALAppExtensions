codeunit 4413 "Excel Reports Ref. Handler"
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Small Business Report Catalog", OnBeforeRunVendorTop10ListReport, '', false, false)]
    local procedure SmallBusinessReportCatalog_OnBeforeRunVendorTop10ListReport(UseRequestPage: Boolean; var IsHandled: Boolean)
    var
        VendorTopList: Report "EXR Vendor Top List";
    begin
        VendorTopList.UseRequestPage(UseRequestPage);
        VendorTopList.Run();

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Small Business Report Catalog", OnBeforeRunTrialBalanceReport, '', false, false)]
    local procedure SmallBusinessReportCatalog_OnBeforeRunTrialBalanceReport(UseRequestPage: Boolean; var IsHandled: Boolean)
    var
        TrialBalance: Report "EXR Trial Balance Excel";
    begin
        TrialBalance.UseRequestPage(UseRequestPage);
        TrialBalance.Run();

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Small Business Report Catalog", OnBeforeRunAgedAccountsReceivableReport, '', false, false)]
    local procedure SmallBusinessReportCatalog_OnBeforeRunAgedAccountsReceivableReport(UseRequestPage: Boolean; var IsHandled: Boolean)
    var
        AgedAccountsReceivable: Report "EXR Aged Accounts Rec Excel";
    begin
        AgedAccountsReceivable.UseRequestPage(UseRequestPage);
        AgedAccountsReceivable.Run();

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Small Business Report Catalog", OnBeforeRunAgedAccountsPayableReport, '', false, false)]
    local procedure SmallBusinessReportCatalog_OnBeforeRunAgedAccountsPayableReport(UseRequestPage: Boolean; var IsHandled: Boolean)
    var
        AgedAccountsPayable: Report "EXR Aged Acc Payable Excel";
    begin
        AgedAccountsPayable.UseRequestPage(UseRequestPage);
        AgedAccountsPayable.Run();

        IsHandled := true;
    end;
}