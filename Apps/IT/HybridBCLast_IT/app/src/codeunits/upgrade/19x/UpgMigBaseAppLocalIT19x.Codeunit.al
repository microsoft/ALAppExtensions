// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#if not CLEAN19
codeunit 12107 "Upg Mig BaseApp Local IT 19x"
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
        if TargetVersion <> 19.0 then
            exit;

        UpgradeVATReportHeader();
    end;

    procedure UpgradeVATReportHeader();
    var
        VATReportHeader: Record "VAT Report Header";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefCountry: Codeunit "Upgrade Tag Def - Country";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefCountry.GetVATReportTaxAuthDocNoUpgradeTag()) then
            exit;

        if VATReportHeader.FindSet() then
            repeat
#pragma warning disable AL0432
                VATReportHeader."Tax Auth. Document No." := VATReportHeader."Tax Auth. Doc. No.";
#pragma warning restore AL0432
                VATReportHeader.Modify();
            until VATReportHeader.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefCountry.GetVATReportTaxAuthDocNoUpgradeTag());
    end;
}
#endif
