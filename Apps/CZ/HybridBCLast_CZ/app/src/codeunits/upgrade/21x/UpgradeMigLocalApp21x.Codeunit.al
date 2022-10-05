// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#if not CLEAN21
codeunit 11803 "Upgrade Mig Local App 21x"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '21.0';

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnUpgradePerCompanyDataUpgrade(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 21.0 then
            exit;

        UpdateBankPaymentApplicationRule();
    end;

    local procedure UpdateBankPaymentApplicationRule()
    var
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
        BankPmtApplRule2: Record "Bank Pmt. Appl. Rule";
        BankPmtApplSettings: Record "Bank Pmt. Appl. Settings";
        BankPmtApplSettings2: Record "Bank Pmt. Appl. Settings";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetBankPaymentApplicationWithoutCodeUpgradeTag()) then
            exit;

        BankPmtApplRule.SetRange("Bank Pmt. Appl. Rule Code", DefaultCodeTxt);
        if BankPmtApplRule.FindSet(true) then begin
            BankPmtApplRule2.SetRange("Bank Pmt. Appl. Rule Code", GetDefaultCode());
            BankPmtApplRule2.DeleteAll();
            repeat
                BankPmtApplRule2.Init();
                BankPmtApplRule2 := BankPmtApplRule;
                BankPmtApplRule2."Bank Pmt. Appl. Rule Code" := GetDefaultCode();
                BankPmtApplRule2.Insert();
            until BankPmtApplRule.Next() = 0;
            BankPmtApplRule.DeleteAll();
        end;

        if BankPmtApplSettings.Get(DefaultCodeTxt) then begin
            if BankPmtApplSettings2.Get(GetDefaultCode()) then
                BankPmtApplSettings2.Delete();
            BankPmtApplSettings2.Init();
            BankPmtApplSettings2 := BankPmtApplSettings;
            BankPmtApplSettings2.PrimaryKey := GetDefaultCode();
            BankPmtApplSettings2.Insert();
            BankPmtApplSettings.Delete();
        end;

        UpgradeTag.SetUpgradeTag(GetBankPaymentApplicationWithoutCodeUpgradeTag());
    end;

    local procedure GetDefaultCode(): Code[10]
    begin
        exit('');
    end;

    local procedure GetBankPaymentApplicationWithoutCodeUpgradeTag(): Code[250]
    begin
        exit('CZ-443967-BankPaymentApplicationWithoutCode-20220726');
    end;

    var
        DefaultCodeTxt: Label 'DEFAULT';
}
#endif