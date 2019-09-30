// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 10540 "MTD Upgrade"
{
    Subtype = Upgrade;

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
        with VATReportSetup do
            if Get() then begin
                IsModify := MTDInstall.InitProductionMode(VATReportSetup);
                IsModify := IsModify or MTDInstall.InitPeriodReminderCalculation(VATReportSetup);
                if IsModify then
                    if Modify() then;
            end;
    end;

    local procedure UpgradeDailyLimit()
    var
        DummyOAuth20Setup: Record "OAuth 2.0 Setup";
        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
    begin
        MTDOAuth20Mgt.InitOAuthSetup(DummyOAuth20Setup, MTDOAuth20Mgt.GetOAuthPRODSetupCode());
    end;
}
