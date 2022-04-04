codeunit 11010 "Upgrade Mig Local App DE 19x"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '19.0';

    trigger OnRun()
    begin
        // This code is based on app upgrade logic for DACH.
        // Matching file: .\App\Layers\DACH\BaseApp\Upgrade\UPGLocalFunctionality.al
        // Based on commit: d4aef6b7b9
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnCompanyMigrationUpgrade(TargetVersion: Decimal)
    begin
        if TargetVersion <> 19.0 then
            exit;

        UpgradeCheckPartnerVATID();
    end;

#if not CLEAN19
    procedure UpgradeCheckPartnerVATID()
    var
        CompanyInformation: Record "Company Information";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefCountry: Codeunit "Upgrade Tag Def - Country";
    begin
#pragma warning disable AL0432
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefCountry.GetCheckPartnerVATIDTag()) then
            exit;

        if CompanyInformation.Get() then begin
            CompanyInformation."Check for Partner VAT ID" := true;
            CompanyInformation."Check for Country of Origin" := true;
            if CompanyInformation.Modify() then;
        end;

        UpgradeTag.SetUpgradeTag(UpgradeTagDefCountry.GetCheckPartnerVATIDTag());
    end;
#pragma warning restore AL0432
#endif
}