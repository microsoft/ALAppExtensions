codeunit 12107 "Upg Mig BaseApp Local IT 19x"
{
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
        UpgradeTags: Codeunit "Upgrade Tag Def - Country";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTags.GetVATReportTaxAuthDocNoUpgradeTag()) then
            exit;

        if VATReportHeader.FindSet() then
            repeat
                VATReportHeader."Tax Auth. Document No." := VATReportHeader."Tax Auth. Doc. No.";
                VATReportHeader.Modify();
            until VATReportHeader.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTags.GetVATReportTaxAuthDocNoUpgradeTag());
    end;
}

