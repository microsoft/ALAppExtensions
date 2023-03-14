// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#if not CLEAN19
codeunit 10036 "Upgrade Mig. MX CFDI"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '19.0';

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 19.0 then
            exit;

        UpdateCFDIEnabled();
    end;

    local procedure UpdateCFDIEnabled()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefCountry: Codeunit "Upgrade Tag Def - Country";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefCountry.GetCFDIEnableOptionUpgradeTag()) then
            exit;

        if GeneralLedgerSetup.Get() then begin
            GeneralLedgerSetup."CFDI Enabled" :=
                GeneralLedgerSetup."PAC Environment" in [GeneralLedgerSetup."PAC Environment"::Test, GeneralLedgerSetup."PAC Environment"::Production];
            GeneralLedgerSetup.Modify();
        end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefCountry.GetCFDIEnableOptionUpgradeTag());
    end;
}
#endif