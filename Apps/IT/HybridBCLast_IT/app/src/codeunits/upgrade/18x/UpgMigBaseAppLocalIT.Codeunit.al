codeunit 12106 "Upg Mig BaseApp Local IT"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '21.0';

    trigger OnRun()
    begin
    end;

#if not CLEAN18
    var
        ITCountryCodeTxt: Label 'IT', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnUpgradePerCompanyDataUpgrade(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 18.0 then
            exit;

        UpgradeIntrastatJnlLine(CountryCode);
    end;

    local procedure UpgradeIntrastatJnlLine(CountryCode: Text)
    var
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetIntrastatJnlLinePartnerIDUpgradeTag()) THEN
            exit;

        if CountryCode <> ITCountryCodeTxt then
            exit;

        if IntrastatJnlLine.FindSet() then
            repeat
#pragma warning disable AL0432
                IntrastatJnlLine."Partner VAT ID" := IntrastatJnlLine."VAT Registration No.";
#pragma warning restore AL0432
                IntrastatJnlLine.Modify();
            until IntrastatJnlLine.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitions.GetIntrastatJnlLinePartnerIDUpgradeTag());
    end;
#endif
}

