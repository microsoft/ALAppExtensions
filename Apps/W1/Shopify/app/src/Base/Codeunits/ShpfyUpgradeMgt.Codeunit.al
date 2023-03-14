/// <summary>
/// Codeunit Shpfy Upgrade Mgt. (ID 30106).
/// </summary>
codeunit 30106 "Shpfy Upgrade Mgt."
{
    Access = Internal;
    Subtype = Upgrade;
    Permissions = tabledata "Shpfy Shop" = RM;

    trigger OnUpgradePerDatabase()
    begin
    end;

    trigger OnUpgradePerCompany()
    begin
        SetShpfyStockCalculation();
#if not CLEAN21
        MoveShpfyRegisteredStore();
#endif
        SetAllowOutgoingRequests();
    end;
#if not CLEAN21

    local procedure MoveShpfyRegisteredStore()
    var
        ShpfyRegisteredStore: Record "Shpfy Registered Store";
        ShpfyRegisteredStoreNew: Record "Shpfy Registered Store New";
    begin
        if ShpfyRegisteredStoreNew.IsEmpty then
            if ShpfyRegisteredStore.FindSet() then
                repeat
                    ShpfyRegisteredStoreNew.TransferFields(ShpfyRegisteredStore, true);
                    ShpfyRegisteredStoreNew.SystemId := ShpfyRegisteredStore.SystemId;
                    ShpfyRegisteredStoreNew.Insert(true, true);
                until ShpfyRegisteredStore.next() = 0;
    end;
#endif

    local procedure SetAllowOutgoingRequests()
    var
        ShpfyShop: Record "Shpfy Shop";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetAllowOutgoingRequestseUpgradeTag()) then
            exit;

        ShpfyShop.SetFilter(SystemCreatedAt, '<%1', GetDateBeforeFeature());
        if ShpfyShop.FindSet() then
            repeat
                if not ShpfyShop."Allow Outgoing Requests" then begin
                    ShpfyShop."Allow Outgoing Requests" := true;
                    ShpfyShop.Modify();
                end;
            until ShpfyShop.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetAllowOutgoingRequestseUpgradeTag());
    end;

    internal procedure SetShpfyStockCalculation()
    var
        ShpfyShopLocation: Record "Shpfy Shop Location";
    begin
        if ShpfyShopLocation.FindSet() then
            repeat
                if ShpfyShopLocation.Disabled then begin
                    ShpfyShopLocation.Disabled := false;
                    ShpfyShopLocation."Stock Calculation" := ShpfyShopLocation."Stock Calculation"::Disabled;
                    ShpfyShopLocation.Modify();
                end;
            until ShpfyShopLocation.Next() = 0;
    end;

    internal procedure GetNewAvailabilityCalculationTag(): Code[250]
    begin
        exit('MS-454264-NewAvailabilityCalculationTag-20221121');
    end;

    internal procedure GetAllowOutgoingRequestseUpgradeTag(): Code[250]
    begin
        exit('MS-445989-AllowOutgoingRequestseUpgradeTag-20220816');
    end;

    local procedure GetDateBeforeFeature(): DateTime
    begin
        exit(CreateDateTime(DMY2Date(1, 8, 2022), 0T));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if not UpgradeTag.HasUpgradeTag(GetAllowOutgoingRequestseUpgradeTag()) then
            PerCompanyUpgradeTags.Add(GetAllowOutgoingRequestseUpgradeTag());
    end;
}