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
        PriceCalculationUpgrade();
        ActivateFulfillmentServices();
    end;
#if not CLEAN21

    local procedure MoveShpfyRegisteredStore()
    var
        RegisteredStore: Record "Shpfy Registered Store";
        RegisteredStoreNew: Record "Shpfy Registered Store New";
    begin
        if RegisteredStoreNew.IsEmpty then
            if RegisteredStore.FindSet() then
                repeat
                    RegisteredStoreNew.TransferFields(RegisteredStore, true);
                    RegisteredStoreNew.SystemId := RegisteredStore.SystemId;
                    RegisteredStoreNew.Insert(true, true);
                until RegisteredStore.next() = 0;
    end;
#endif

    local procedure SetAllowOutgoingRequests()
    var
        Shop: Record "Shpfy Shop";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetAllowOutgoingRequestseUpgradeTag()) then
            exit;

        Shop.SetFilter(SystemCreatedAt, '<%1', GetDateBeforeFeature());
        if Shop.FindSet() then
            repeat
                if not Shop."Allow Outgoing Requests" then begin
                    Shop."Allow Outgoing Requests" := true;
                    Shop.Modify();
                end;
            until Shop.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetAllowOutgoingRequestseUpgradeTag());
    end;

    local procedure PriceCalculationUpgrade()
    var
        Shop: Record "Shpfy Shop";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetPriceCalculationUpgradeTag()) then
            exit;

        if Shop.FindSet(true, false) then
            repeat
                Shop.CopyPriceCalculationFieldsFromCustomerTemplate(Shop."Customer Template Code");
                Shop.Modify();
            until Shop.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetPriceCalculationUpgradeTag());
    end;

    local procedure ActivateFulfillmentServices()
    var
        Shop: Record "Shpfy Shop";
        UpgradeTag: Codeunit "Upgrade Tag";
        FulfillmentOrdersAPI: Codeunit "Shpfy Fulfillment Orders API";
    begin
        if UpgradeTag.HasUpgradeTag(GetActivateFulfillmentServiceUpgradeTag()) then
            exit;

        if Shop.FindSet(true, false) then
            repeat
                FulfillmentOrdersAPI.RegisterFulfillmentService(Shop);
            until Shop.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetActivateFulfillmentServiceUpgradeTag());
    end;

    internal procedure SetShpfyStockCalculation()
    var
        ShopLocation: Record "Shpfy Shop Location";
    begin
        if ShopLocation.FindSet() then
            repeat
                if ShopLocation.Disabled then begin
                    ShopLocation.Disabled := false;
                    ShopLocation."Stock Calculation" := ShopLocation."Stock Calculation"::Disabled;
                    ShopLocation.Modify();
                end;
            until ShopLocation.Next() = 0;
    end;

    internal procedure GetNewAvailabilityCalculationTag(): Code[250]
    begin
        exit('MS-454264-NewAvailabilityCalculationTag-20221121');
    end;

    internal procedure GetAllowOutgoingRequestseUpgradeTag(): Code[250]
    begin
        exit('MS-445989-AllowOutgoingRequestseUpgradeTag-20220816');
    end;

    internal procedure GetPriceCalculationUpgradeTag(): Code[250]
    begin
        exit('PriceCalculationUpgradeTag-20221201');
    end;

    internal procedure GetActivateFulfillmentServiceUpgradeTag(): Code[250]
    begin
        exit('ActivateFulfillmentServiceUpgradeTag-20230201');
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

        if not UpgradeTag.HasUpgradeTag(GetPriceCalculationUpgradeTag()) then
            PerCompanyUpgradeTags.Add(GetPriceCalculationUpgradeTag());
    end;
}