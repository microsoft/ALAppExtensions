#pragma warning disable AL0432
codeunit 31097 "Substitute Report Handler CZL"
{
    Permissions = tabledata "NAV App Installed App" = r,
                  tabledata "Feature Data Update Status" = r;

    var
        InstructionMgt: Codeunit "Instruction Mgt.";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)]
    local procedure OnSubstituteGeneralReport(ReportId: Integer; var NewReportId: Integer)
    var
        UsedStandardReportMsg: Label 'Used standard report (ID %1) instead of Core Localization Pack for Czech report.', Comment = '%1 = NewReportId';
    begin
        if IsTestingEnvironment() then
            exit;

#if not CLEAN20
        if not IsReplaceMulIntRateEnabled() then
            case ReportId of
                Report::"Finance Charge Memo CZL":
                    begin
                        NewReportId := Report::"Finance Charge Memo MIR CZL";
                        exit;
                    end;
                Report::"Reminder CZL":
                    begin
                        NewReportId := Report::"Reminder MIR CZL";
                        exit;
                    end;
            end;
#endif
        if not InstructionMgt.IsEnabled(GetSubstituteGeneralReportsNotificationId()) then begin
            // "Use standard general reports substitution" in My Notifications is disabled
            case ReportId of
                Report::"Balance Sheet CZL":
                    NewReportId := Report::"Balance Sheet";
                Report::"Adjust Exchange Rates CZL":
#if CLEAN20
                    NewReportId := Report::"Exch. Rate Adjustment";
#else
                    NewReportId := Report::"Adjust Exchange Rates";
#endif
                Report::"Calc. and Post VAT Settl. CZL":
                    NewReportId := Report::"Calc. and Post VAT Settlement";
                Report::"Cash Flow Date List CZL":
                    NewReportId := Report::"Cash Flow Date List";
                Report::"Close Income Statement CZL":
                    NewReportId := Report::"Close Income Statement";
                Report::"Create Stockkeeping Unit CZL":
                    NewReportId := Report::"Create Stockkeeping Unit";
                Report::"Income Statement CZL":
                    NewReportId := Report::"Income Statement";
                Report::"VAT Statement CZL":
                    NewReportId := Report::"VAT Statement";
                Report::"Batch Post Sales Orders CZL":
                    NewReportId := Report::"Batch Post Sales Orders";
                Report::"Batch Post Sales Invoices CZL":
                    NewReportId := Report::"Batch Post Sales Invoices";
                Report::"Batch Post Sales Cr. Memos CZL":
                    NewReportId := Report::"Batch Post Sales Credit Memos";
                Report::"Batch Post Purchase Orders CZL":
                    NewReportId := Report::"Batch Post Purchase Orders";
                Report::"Batch Post Purchase Inv. CZL":
                    NewReportId := Report::"Batch Post Purchase Invoices";
                Report::"Batch Post Purch. Cr.Memos CZL":
                    NewReportId := Report::"Batch Post Purch. Credit Memos";
                Report::"Batch Post Sales Ret. Ord. CZL":
                    NewReportId := Report::"Batch Post Sales Return Orders";
                Report::"Batch Post Purch. Ret.Ord. CZL":
                    NewReportId := Report::"Batch Post Purch. Ret. Orders";
                Report::"VAT Register CZL":
                    NewReportId := Report::"VAT Register";
                Report::"VAT Exceptions CZL":
                    NewReportId := Report::"VAT Exceptions";
            end;
            if GuiAllowed() then
                if (NewReportId <> ReportId) and (NewReportId <> -1) then
                    Message(UsedStandardReportMsg, NewReportId);
        end else
            case ReportId of
                Report::"Balance Sheet":
                    NewReportId := Report::"Balance Sheet CZL";
#if CLEAN20
                Report::"Exch. Rate Adjustment":
#else
                Report::"Adjust Exchange Rates":
#endif
                    NewReportId := Report::"Adjust Exchange Rates CZL";
                Report::"Calc. and Post VAT Settlement":
                    NewReportId := Report::"Calc. and Post VAT Settl. CZL";
                Report::"Cash Flow Date List":
                    NewReportId := Report::"Cash Flow Date List CZL";
                Report::"Close Income Statement":
                    NewReportId := Report::"Close Income Statement CZL";
                Report::"Create Stockkeeping Unit":
                    NewReportId := Report::"Create Stockkeeping Unit CZL";
                Report::"Income Statement":
                    NewReportId := Report::"Income Statement CZL";
                Report::"VAT Statement":
                    NewReportId := Report::"VAT Statement CZL";
                Report::"Batch Post Sales Orders":
                    NewReportId := Report::"Batch Post Sales Orders CZL";
                Report::"Batch Post Sales Invoices":
                    NewReportId := Report::"Batch Post Sales Invoices CZL";
                Report::"Batch Post Sales Credit Memos":
                    NewReportId := Report::"Batch Post Sales Cr. Memos CZL";
                Report::"Batch Post Purchase Orders":
                    NewReportId := Report::"Batch Post Purchase Orders CZL";
                Report::"Batch Post Purchase Invoices":
                    NewReportId := Report::"Batch Post Purchase Inv. CZL";
                Report::"Batch Post Purch. Credit Memos":
                    NewReportId := Report::"Batch Post Purch. Cr.Memos CZL";
                Report::"Batch Post Sales Return Orders":
                    NewReportId := Report::"Batch Post Sales Ret. Ord. CZL";
                Report::"Batch Post Purch. Ret. Orders":
                    NewReportId := Report::"Batch Post Purch. Ret.Ord. CZL";
                Report::"VAT Register":
                    NewReportId := Report::"VAT Register CZL";
                Report::"VAT Exceptions":
                    NewReportId := Report::"VAT Exceptions CZL";
            end;
    end;

#if not CLEAN20
    local procedure IsReplaceMulIntRateEnabled(): Boolean
    var
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
#pragma warning disable AL0432
        ReplaceMulIntRateMgt: Codeunit "Replace Mul. Int. Rate Mgt.";
    begin
        if not FeatureDataUpdateStatus.Get(ReplaceMulIntRateMgt.GetFeatureKey(), CompanyName()) then
            exit(false);
        exit(ReplaceMulIntRateMgt.IsEnabled());
#pragma warning restore AL0432
    end;

#endif
    local procedure IsTestingEnvironment(): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        exit(NAVAppInstalledApp.Get('fa3e2564-a39e-417f-9be6-c0dbe3d94069')); // application "Tests-ERM"
    end;

    local procedure GetSubstituteGeneralReportsNotificationId(): Guid
    begin
        exit('0333b157-cab9-4135-864f-13c7e20835d7');
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDeGeneralultState()
    var
        MyNotifications: Record "My Notifications";
        UseStandardGeneralReportsSubstitutionTxt: Label 'Use standard general reports substitution.';
        UseStandardGeneralReportsSubstitutionDescriptionTxt: Label 'If substitution is not enabled, general reports from Base Application will be invoked, even though application "Core Localization Pack for Czech" is installed.';
    begin
        MyNotifications.InsertDefault(GetSubstituteGeneralReportsNotificationId(),
          UseStandardGeneralReportsSubstitutionTxt,
          UseStandardGeneralReportsSubstitutionDescriptionTxt,
          true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"My Notifications", 'OnStateChanged', '', false, false)]
    local procedure OnStateChanged(NotificationId: Guid; NewEnabledState: Boolean)
    begin
        case NotificationId of
            GetSubstituteGeneralReportsNotificationId():
                if NewEnabledState then
                    InstructionMgt.EnableMessageForCurrentUser(GetSubstituteGeneralReportsNotificationId())
                else
                    InstructionMgt.DisableMessageForCurrentUser(GetSubstituteGeneralReportsNotificationId());
        end;
    end;
}