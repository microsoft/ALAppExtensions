// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 10540 "MTD Upgrade"
{
    Subtype = Upgrade;

    var
        MTDMgt: Codeunit "MTD Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";

    trigger OnUpgradePerCompany()
    begin
        UpgradeVATReportSetup();
        UpgradeDailyLimit();
    end;

    local procedure UpgradeVATReportSetup()
    var
        VATReportSetup: Record "VAT Report Setup";
        MTDInstall: Codeunit "MTD Install";
        IsModify: Boolean;
    begin
        if UpgradeTag.HasUpgradeTag(MTDMgt.GetVATReportSetupUpgradeTag()) then
            exit;

        with VATReportSetup do
            if Get() then begin
                IsModify := MTDInstall.InitProductionMode(VATReportSetup);
                IsModify := IsModify or MTDInstall.InitPeriodReminderCalculation(VATReportSetup);
                IsModify := IsModify or UpgradeFPSavedHeaders(VATReportSetup);
                if IsModify then
                    if Modify() then;
            end;

        UpgradeTag.SetUpgradeTag(MTDMgt.GetVATReportSetupUpgradeTag());
    end;

    local procedure UpgradeDailyLimit()
    var
        DummyOAuth20Setup: Record "OAuth 2.0 Setup";
        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
    begin
        if UpgradeTag.HasUpgradeTag(MTDMgt.GetDailyLimitUpgradeTag()) then
            exit;

        MTDOAuth20Mgt.InitOAuthSetup(DummyOAuth20Setup, MTDOAuth20Mgt.GetOAuthPRODSetupCode());

        UpgradeTag.SetUpgradeTag(MTDMgt.GetDailyLimitUpgradeTag());
    end;

    local procedure UpgradeFPSavedHeaders(var VATReportSetup: Record "VAT Report Setup") Result: Boolean
    var
        CurrentDT: DateTime;
    begin
        with VATReportSetup do begin
            if (not "MTD FP WinClient Json".HasValue() or ("MTD FP WinClient Due DateTime" = 0DT)) and
                (not "MTD FP WebClient Json".HasValue() or ("MTD FP WebClient Due DateTime" = 0DT)) and
                (not "MTD FP Batch Json".HasValue() or ("MTD FP Batch Due DateTime" = 0DT))
            then
                exit(false);

            CurrentDT := CurrentDateTime();
            if "MTD FP WinClient Due DateTime" <> 0DT then
                Result := "MTD FP WinClient Due DateTime" >= CurrentDT;
            if not Result and ("MTD FP WebClient Due DateTime" <> 0DT) then
                Result := "MTD FP WebClient Due DateTime" >= CurrentDT;
            if not Result and ("MTD FP Batch Due DateTime" <> 0DT) then
                Result := "MTD FP Batch Due DateTime" >= CurrentDT;

            if Result then begin
                "MTD FP WinClient Due DateTime" := 0DT;
                "MTD FP WebClient Due DateTime" := 0DT;
                "MTD FP Batch Due DateTime" := 0DT;
            end;
        end;
    end;

    local procedure GetCleanupElsterTag(): Code[250];
    begin
        exit('MS-332065-CleanupElster-20191029');
    end;
}
