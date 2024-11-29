namespace Microsoft.Bank.Deposit;

using System.Environment;
using System.Upgrade;
using Microsoft.Foundation.Reporting;
using Microsoft.Bank.Reports;

codeunit 1714 "Upgrade Bank Deposits"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDefBankDeposits: Codeunit "Upg. Tag Def. Bank Deposits";
        Localization: Text;
    begin
        Localization := EnvironmentInformation.GetApplicationFamily();
        if (Localization <> 'NA') and (Localization <> 'US') and (Localization <> 'MX') and (Localization <> 'CA') then
            exit;
        if UpgradeTag.HasUpgradeTag(UpgTagDefBankDeposits.GetNADepositsUpgradeTag()) then
            exit;

#if not CLEAN24
        SetDepositsPageMgtPages();
#endif
        SetReportSelections();
        UpgradeTag.SetUpgradeTag(UpgTagDefBankDeposits.GetNADepositsUpgradeTag());
    end;

    local procedure SetReportSelections()
    var
        ReportSelections: Record "Report Selections";
    begin
        SelectReport(ReportSelections.Usage::"B.Stmt", Report::"Bank Account Statement");
        SelectReport(ReportSelections.Usage::"B.Recon.Test", Report::"Bank Acc. Recon. - Test");
    end;

    local procedure SelectReport(UsageValue: Enum "Report Selection Usage"; ReportID: Integer)
    var
        ReportSelections: Record "Report Selections";
    begin
        ReportSelections.SetRange(Usage, UsageValue);

        case true of
            ReportSelections.IsEmpty():
                begin
                    ReportSelections.Reset();
                    ReportSelections.InsertRecord(UsageValue, '1', ReportID);
                    exit;
                end;
            ReportSelections.Count = 1:
                begin
                    ReportSelections.FindFirst();
                    if ReportSelections."Report ID" <> ReportID then begin
                        ReportSelections.Validate("Report ID", ReportID);
                        ReportSelections.Modify();
                        exit;
                    end;
                end;
            else
                exit;
        end;
    end;

#if not CLEAN24
    local procedure SetDepositsPageMgtPages()
    var
        DepositsPageMgt: Codeunit "Deposits Page Mgt.";
    begin
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositsPage, Page::"Bank Deposits");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositPage, Page::"Bank Deposit");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositListPage, Page::"Bank Deposit List");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositReport, Report::"Bank Deposit");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositTestReport, Report::"Bank Deposit Test Report");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::PostedBankDepositListPage, Page::"Posted Bank Deposit List");
    end;
#endif
}