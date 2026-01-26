// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

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
        UpgradeFeatureConsentCheckbox();
        UpgradeDisablePeriodJob();
        UpgradeDefaultRedirect();
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

    local procedure UpgradeFeatureConsentCheckbox()
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        if UpgradeTag.HasUpgradeTag(MTDMgt.GetFeatureConsentCheckboxTag()) then
            exit;

        if VATReportSetup.Get() then begin
            VATReportSetup."MTD Enabled" := true;
            if VATReportSetup.Modify() then;
        end;

        UpgradeTag.SetUpgradeTag(MTDMgt.GetFeatureConsentCheckboxTag());
    end;

    local procedure UpgradeDisablePeriodJob()
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        if UpgradeTag.HasUpgradeTag(MTDMgt.GetDisablePeriodJobTag()) then
            exit;

        if VATReportSetup.Get() then begin
            VATReportSetup."Update Period Job Frequency" := VATReportSetup."Update Period Job Frequency"::Never;
            if VATReportSetup.Modify() then;
        end;

        UpgradeTag.SetUpgradeTag(MTDMgt.GetDisablePeriodJobTag());
    end;

    local procedure UpgradeDefaultRedirect()
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
    begin
        if UpgradeTag.HasUpgradeTag(MTDMgt.GetDefaultRedirectTag()) then
            exit;

        MTDOAuth20Mgt.InitOAuthSetup(OAuth20Setup, MTDOAuth20Mgt.GetOAuthPRODSetupCode());

        UpgradeTag.SetUpgradeTag(MTDMgt.GetDefaultRedirectTag());
    end;
}
