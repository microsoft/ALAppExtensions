// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#if not CLEAN19
codeunit 11305 "Upgrade BaseApp 19 BE"
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

        UpgradeCustomerVATLiable();
    end;

    local procedure UpgradeCustomerVATLiable()
    var
        Customer: Record Customer;
        UpgradeTagDefCountry: Codeunit "Upgrade Tag Def - Country";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefCountry.GetCustomerVATLiableTag()) THEN
            exit;

        Customer.ModifyAll("VAT Liable", true, false);

        UpgradeTag.SetUpgradeTag(UpgradeTagDefCountry.GetCustomerVATLiableTag());
    end;
}
#endif