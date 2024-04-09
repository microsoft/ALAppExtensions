namespace Microsoft.Integration.Shopify;

using System.IO;
using System.Reflection;
using Microsoft.Sales.Customer;
using Microsoft.Finance.Dimension;
using Microsoft.Inventory.Item;
using System.Upgrade;

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
#if not CLEAN22
        SetShpfyStockCalculation();
#endif
        SetAllowOutgoingRequests();
#if CLEAN22
        MoveTemplatesData();
#endif
        PriceCalculationUpgrade();
        LoggingModeUpgrade();
        LocationUpgrade();
        SyncPricesWithProductsUpgrade();
        SendShippingConfirmationUpgrade();
#if CLEAN24
        OrderAttributeValueUpgrade();
#endif
        CreditMemoCanBeCreatedUpgrade();
    end;

#if CLEAN22
    local procedure MoveTemplatesData()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetMoveTemplatesDataTag()) then
            exit;
        UpgradeTemplatesData();
    end;
#endif

    internal procedure UpgradeTemplatesData()
    var
        Shop: Record "Shpfy Shop";
        ShpfyCustomerTemplate: Record "Shpfy Customer Template";
        CustomerTemplCreated: Dictionary of [Code[10], Code[20]];
        Modified: Boolean;
    begin
        if Shop.FindSet() then
            repeat
                Modified := false;
                if Shop."Customer Template Code" <> '' then
                    if not CustomerTemplCreated.ContainsKey(Shop."Customer Template Code") then begin
                        Shop."Customer Templ. Code" := CreateCustomerTemplate(Shop."Customer Template Code");
                        CustomerTemplCreated.Add(Shop."Customer Template Code", Shop."Customer Templ. Code");
                        Modified := true;
                    end;
                if Shop."Item Template Code" <> '' then begin
                    Shop."Item Templ. Code" := CreateItemTemplate(Shop."Item Template Code");
                    Modified := true;
                end;
                if Modified then
                    Shop.Modify();
            until Shop.Next() = 0;
        ShpfyCustomerTemplate.SetFilter("Customer Template Code", '<> %1', '');
        if ShpfyCustomerTemplate.FindSet() then
            repeat
                if not CustomerTemplCreated.ContainsKey(ShpfyCustomerTemplate."Customer Template Code") then begin
                    ShpfyCustomerTemplate."Customer Templ. Code" := CreateCustomerTemplate(ShpfyCustomerTemplate."Customer Template Code");
                    CustomerTemplCreated.Add(ShpfyCustomerTemplate."Customer Template Code", ShpfyCustomerTemplate."Customer Templ. Code");
                end else
                    ShpfyCustomerTemplate."Customer Templ. Code" := CustomerTemplCreated.Get(ShpfyCustomerTemplate."Customer Template Code");
                ShpfyCustomerTemplate.Modify();
            until ShpfyCustomerTemplate.Next() = 0;
    end;

    local procedure CopyConfigTemplateLinesToRecordRef(var ConfigTemplateLine: Record "Config. Template Line"; var RecordRef: RecordRef)
    var
        Field: Record Field;
        TypeHelper: Codeunit "Type Helper";
        FieldRef: FieldRef;
        DateFormulaDefaultValue: DateFormula;
        BoolDefaultValue: Boolean;
        DateDefaultValue: Date;
        DateTimeDefaultValue: DateTime;
        TimeDefaultValue: Time;
    begin
        if not ConfigTemplateLine.FindSet() then
            exit;
        repeat
            if (ConfigTemplateLine."Field ID" > 2) and RecordRef.FieldExist(ConfigTemplateLine."Field ID") then begin
                FieldRef := RecordRef.Field(ConfigTemplateLine."Field ID");
                Field.Get(ConfigTemplateLine."Table ID", ConfigTemplateLine."Field ID");
                case Field.Type of
                    Field.Type::Option:
                        FieldRef.Value := TypeHelper.GetOptionNo(ConfigTemplateLine."Default Value", FieldRef.OptionMembers);
                    Field.Type::Boolean:
                        if Evaluate(BoolDefaultValue, ConfigTemplateLine."Default Value") then
                            FieldRef.Value := BoolDefaultValue;
                    Field.Type::Date:
                        if Evaluate(DateDefaultValue, ConfigTemplateLine."Default Value") then
                            FieldRef.Value := DateDefaultValue;
                    Field.Type::DateTime:
                        if Evaluate(DateTimeDefaultValue, ConfigTemplateLine."Default Value") then
                            FieldRef.Value := DateTimeDefaultValue;
                    Field.Type::DateFormula:
                        if Evaluate(DateFormulaDefaultValue, ConfigTemplateLine."Default Value") then
                            FieldRef.Value := DateFormulaDefaultValue;
                    Field.Type::Time:
                        if Evaluate(TimeDefaultValue, ConfigTemplateLine."Default Value") then
                            FieldRef.Value := TimeDefaultValue;
                    else
                        FieldRef.Value := ConfigTemplateLine."Default Value";
                end;
            end;
        until ConfigTemplateLine.Next() = 0;
        RecordRef.Modify();
    end;

    local procedure CreateCustomerTemplate(TemplateCode: Code[10]): Code[20]
    var
        CustomerTempl: Record "Customer Templ.";
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        CustomerTemplRecordRef: RecordRef;
    begin
        CustomerTempl.SetRange(Code, TemplateCode);
        if not CustomerTempl.IsEmpty() then
            exit(TemplateCode);
        ConfigTemplateHeader.Get(TemplateCode);
        CustomerTempl.Reset();
        CustomerTempl.Code := TemplateCode;
        CustomerTempl.Description := ConfigTemplateHeader.Description;
        CustomerTempl.Insert();
        CustomerTemplRecordRef.GetTable(CustomerTempl);
        ConfigTemplateLine.SetRange("Data Template Code", TemplateCode);
        ConfigTemplateLine.SetRange("Table ID", Database::Customer);
        ConfigTemplateLine.SetRange(Type, ConfigTemplateLine.Type::Field);
        CopyConfigTemplateLinesToRecordRef(ConfigTemplateLine, CustomerTemplRecordRef);
        TransferDimensionsFromTemplate(TemplateCode, Database::Customer, Database::"Customer Templ.");
        exit(TemplateCode);
    end;

    local procedure TransferDimensionsFromTemplate(TemplateCode: Code[10]; TableNo: Integer; TemplTableNo: Integer)
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        DefaultDimension: Record "Default Dimension";
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        RecordRef: RecordRef;
        DimensionCode: Code[20];
    begin
        ConfigTemplateLine.SetRange("Data Template Code", TemplateCode);
        ConfigTemplateLine.SetRange("Table ID", TableNo);
        ConfigTemplateLine.SetRange(Type, ConfigTemplateLine.Type::"Related Template");
        if not ConfigTemplateLine.FindSet() then
            exit;
        repeat
            if ConfigTemplateHeader.Get(ConfigTemplateLine."Template Code") then
                if ConfigTemplateHeader."Table ID" = Database::"Default Dimension" then begin
                    DimensionCode := GetDimensionCodeFromTemplate(ConfigTemplateHeader.Code);
                    if DimensionCode <> '' then begin
                        DefaultDimension.Reset();
                        DefaultDimension."Table ID" := TemplTableNo;
                        DefaultDimension."No." := TemplateCode;
                        DefaultDimension."Dimension Code" := DimensionCode;
                        DefaultDimension.Insert();
                        RecordRef.GetTable(DefaultDimension);
                        ConfigTemplateManagement.UpdateRecord(ConfigTemplateHeader, RecordRef);
                        RecordRef.SetTable(DefaultDimension);
                        DefaultDimension.Modify();
                    end;
                end;
        until ConfigTemplateLine.Next() = 0;
    end;

    local procedure GetDimensionCodeFromTemplate(TemplateCode: Code[10]): Code[20]
    var
        DefaultDimension: Record "Default Dimension";
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        ConfigTemplateLine.SetRange("Data Template Code", TemplateCode);
        ConfigTemplateLine.SetRange(Type, ConfigTemplateLine.Type::Field);
        ConfigTemplateLine.SetRange("Field ID", DefaultDimension.FieldNo("Dimension Code"));
        if not ConfigTemplateLine.FindFirst() then
            exit('');
        exit(CopyStr(ConfigTemplateLine."Default Value", 1, 20));
    end;

    local procedure CreateItemTemplate(TemplateCode: Code[10]): Code[20]
    var
        ItemTempl: Record "Item Templ.";
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
        ItemTemplRecordRef: RecordRef;
    begin
        ItemTempl.SetRange(Code, TemplateCode);
        if not ItemTempl.IsEmpty() then
            exit(TemplateCode);
        ConfigTemplateHeader.Get(TemplateCode);
        ItemTempl.Reset();
        ItemTempl.Code := TemplateCode;
        ItemTempl.Description := ConfigTemplateHeader.Description;
        ItemTempl.Insert();
        ItemTemplRecordRef.GetTable(ItemTempl);
        ConfigTemplateLine.SetRange("Data Template Code", TemplateCode);
        ConfigTemplateLine.SetRange("Table ID", Database::Item);
        ConfigTemplateLine.SetRange(Type, ConfigTemplateLine.Type::Field);
        CopyConfigTemplateLinesToRecordRef(ConfigTemplateLine, ItemTemplRecordRef);
        TransferDimensionsFromTemplate(TemplateCode, Database::Item, Database::"Item Templ.");
        exit(TemplateCode);
    end;

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

        Shop.SetFilter("Customer Template Code", '<>%1', '');
        Shop.SetRange("Customer Posting Group", '');
        if Shop.FindSet(true) then
            repeat
#if not CLEAN22
                Shop.CopyPriceCalculationFieldsFromCustomerTemplate(Shop."Customer Template Code");
#else
                Shop.CopyPriceCalculationFieldsFromCustomerTempl(Shop."Customer Templ. Code");
#endif
                Shop.Modify();
            until Shop.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetPriceCalculationUpgradeTag());
    end;

    local procedure LoggingModeUpgrade()
    var
        Shop: Record "Shpfy Shop";
        UpgradeTag: Codeunit "Upgrade Tag";
        ShopDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(GetLoggingModeUpgradeTag()) then
            exit;

        ShopDataTransfer.SetTables(Database::"Shpfy Shop", Database::"Shpfy Shop");
        ShopDataTransfer.AddSourceFilter(Shop.FieldNo("Log Enabled"), '=%1', true);
        ShopDataTransfer.AddConstantValue("Shpfy Logging Mode"::All, Shop.FieldNo("Logging Mode"));
        ShopDataTransfer.UpdateAuditFields := false;
        ShopDataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(GetLoggingModeUpgradeTag());
    end;

    local procedure LocationUpgrade()
    var
        ShopLocation: Record "Shpfy Shop Location";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetLocationUpgradeTag()) then
            exit;

        if ShopLocation.FindSet(true) then
            repeat
                ShopLocation."Default Product Location" := true;
                ShopLocation.Modify();
            until ShopLocation.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetLocationUpgradeTag());
    end;

    local procedure SyncPricesWithProductsUpgrade()
    var
        Shop: Record "Shpfy Shop";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetSyncPricesWithProductsUpgradeTag()) then
            exit;

        if Shop.FindSet(true) then
            repeat
                Shop."Sync Prices" := true;
                Shop.Modify();
            until Shop.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetSyncPricesWithProductsUpgradeTag());
    end;

#if not CLEAN22
    internal procedure SetShpfyStockCalculation()
    var
        ShopLocation: Record "Shpfy Shop Location";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetStockCalculationUpgradeTag()) then
            exit;

        if ShopLocation.FindSet() then
            repeat
                if ShopLocation.Disabled then begin
                    ShopLocation.Disabled := false;
                    ShopLocation."Stock Calculation" := ShopLocation."Stock Calculation"::Disabled;
                    ShopLocation.Modify();
                end;
            until ShopLocation.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetStockCalculationUpgradeTag());
    end;
#endif

    internal procedure SetAutoReleaseSalesOrder()
    var
        ShpfyShop: Record "Shpfy Shop";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetAutoReleaseSalesOrderTag()) then
            exit;
        ShpfyShop.ModifyAll("Auto Release Sales Orders", true);
        UpgradeTag.SetUpgradeTag(GetAutoReleaseSalesOrderTag());
    end;

    internal procedure SetB2BEnabled()
    var
        Shop: Record "Shpfy Shop";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetShopifyB2BEnabledUpgradeTag()) then
            exit;

        Shop.SetRange(Enabled, true);
        if Shop.FindSet() then
            repeat
                Shop."B2B Enabled" := Shop.GetB2BEnabled();
                Shop.Modify();
            until Shop.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetShopifyB2BEnabledUpgradeTag());
    end;

    local procedure SendShippingConfirmationUpgrade()
    var
        Shop: Record "Shpfy Shop";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetSendShippingConfirmationUpgradeTag()) then
            exit;

        if Shop.FindSet(true) then
            repeat
                Shop."Send Shipping Confirmation" := true;
                Shop.Modify();
            until Shop.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetSendShippingConfirmationUpgradeTag());
    end;

#if CLEAN24
    local procedure OrderAttributeValueUpgrade()
    var
        OrderAttribute: Record "Shpfy Order Attribute";
        UpgradeTag: Codeunit "Upgrade Tag";
        OrderAttributeDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(GetOrderAttributeValueUpgradeTag()) then
            exit;

        if not OrderAttribute.IsEmpty() then begin
            OrderAttributeDataTransfer.SetTables(Database::"Shpfy Order Attribute", Database::"Shpfy Order Attribute");
            OrderAttributeDataTransfer.AddFieldValue(OrderAttribute.FieldNo(Value), OrderAttribute.FieldNo("Attribute Value"));
            OrderAttributeDataTransfer.UpdateAuditFields := false;
            OrderAttributeDataTransfer.CopyFields();
        end;

        UpgradeTag.SetUpgradeTag(GetOrderAttributeValueUpgradeTag());
    end;
#endif

    local procedure CreditMemoCanBeCreatedUpgrade()
    var
        RefundHeader: Record "Shpfy Refund Header";
        UpgradeTag: Codeunit "Upgrade Tag";
        HeadersInFilter, MaxHeadersInFilter : Integer;
        RefundIdFilter: Text;
    begin
        if UpgradeTag.HasUpgradeTag(GetCreditMemoCanBeCreatedUpgradeTag()) then
            exit;

        MaxHeadersInFilter := 100;
        RefundHeader.SetFilter("Total Refunded Amount", '>%1', 0);
        if RefundHeader.FindSet() then
            repeat
                if RefundIdFilter <> '' then
                    RefundIdFilter += '|';
                RefundIdFilter += Format(RefundHeader."Refund Id");
                HeadersInFilter += 1;
                if HeadersInFilter >= MaxHeadersInFilter then begin
                    SetCanCreateCreditMemoInRefundLines(RefundIdFilter);
                    RefundIdFilter := '';
                    HeadersInFilter := 0;
                end;
            until RefundHeader.Next() = 0;
        if RefundIdFilter <> '' then
            SetCanCreateCreditMemoInRefundLines(RefundIdFilter);

        UpgradeTag.SetUpgradeTag(GetCreditMemoCanBeCreatedUpgradeTag());
    end;

    local procedure SetCanCreateCreditMemoInRefundLines(RefundIdFilter: Text)
    var
        RefundLine: Record "Shpfy Refund Line";
        RefundLineDataTransfer: DataTransfer;
    begin
        RefundLineDataTransfer.SetTables(Database::"Shpfy Refund Line", Database::"Shpfy Refund Line");
        RefundLineDataTransfer.AddSourceFilter(RefundLine.FieldNo("Refund Id"), RefundIdFilter);
        RefundLineDataTransfer.AddConstantValue(true, RefundLine.FieldNo("Can Create Credit Memo"));
        RefundLineDataTransfer.UpdateAuditFields(false);
        RefundLineDataTransfer.CopyFields();
    end;

    local procedure GetShopifyB2BEnabledUpgradeTag(): Code[250]
    begin
        exit('MS-490178-ShopifyB2B-20231101');
    end;

    internal procedure GetAllowOutgoingRequestseUpgradeTag(): Code[250]
    begin
        exit('MS-445989-AllowOutgoingRequestseUpgradeTag-20220816');
    end;

    internal procedure GetNewAvailabilityCalculationTag(): Code[250]
    begin
        exit('MS-454264-NewAvailabilityCalculationTag-20221121');
    end;

    internal procedure GetAutoReleaseSalesOrderTag(): code[250]
    begin
        exit('MS-459849-AutoReleaseSalesOrderTag-20230106')
    end;

#if CLEAN22
    local procedure GetMoveTemplatesDataTag(): Code[250]
    begin
        exit('MS-445489-MoveTemplatesData-20230209');
    end;
#endif

    internal procedure GetPriceCalculationUpgradeTag(): Code[250]
    begin
        exit('MS-460298-PriceCalculationUpgradeTag-20221201');
    end;

    local procedure GetLoggingModeUpgradeTag(): Code[250]
    begin
        exit('MS-447972-LoggingMode-20230425');
    end;

    internal procedure GetLocationUpgradeTag(): Code[250]
    begin
        exit('MS-472953-LocationUpgradeTag-20230525');
    end;

    internal procedure GetSyncPricesWithProductsUpgradeTag(): Code[250]
    begin
        exit('MS-480542-SyncPricesWithProductsUpgradeTag-20230814');
    end;

    local procedure GetSendShippingConfirmationUpgradeTag(): Code[250]
    begin
        exit('MS-495193-SendShippingConfirmationUpgradeTag-20231221');
    end;

#if not CLEAN22
    local procedure GetStockCalculationUpgradeTag(): Code[250]
    begin
        exit('MS-495993-StockCalculationUpgradeTag-20240108');
    end;
#endif

#if CLEAN24
    local procedure GetOrderAttributeValueUpgradeTag(): Code[250]
    begin
        exit('MS-497909-OrderAttributeValueUpgradeTag-20240125');
    end;
#endif

    local procedure GetCreditMemoCanBeCreatedUpgradeTag(): Code[250]
    begin
        exit('MS-471880-CreditMemoCanBeCreatedUpgradeTag-20240201');
    end;

    local procedure GetDateBeforeFeature(): DateTime
    begin
        exit(CreateDateTime(DMY2Date(1, 8, 2022), 0T));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetAllowOutgoingRequestseUpgradeTag());
        PerCompanyUpgradeTags.Add(GetPriceCalculationUpgradeTag());
        PerCompanyUpgradeTags.Add(GetNewAvailabilityCalculationTag());
        PerCompanyUpgradeTags.Add(GetAutoReleaseSalesOrderTag());
#if CLEAN22
        PerCompanyUpgradeTags.Add(GetMoveTemplatesDataTag());
#endif
        PerCompanyUpgradeTags.Add(GetLoggingModeUpgradeTag());
        PerCompanyUpgradeTags.Add(GetLocationUpgradeTag());
        PerCompanyUpgradeTags.Add(GetSyncPricesWithProductsUpgradeTag());
    end;
}