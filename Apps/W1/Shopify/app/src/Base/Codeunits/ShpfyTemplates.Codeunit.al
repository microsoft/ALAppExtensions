#if not CLEAN22
namespace Microsoft.Integration.Shopify;

using System.Environment.Configuration;
using System.IO;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.Navigate;

codeunit 30213 "Shpfy Templates" implements "Feature Data Update"
{
    Access = Internal;
    ObsoleteReason = 'Feature "Shopify new customer an item templates" will be enabled by default in version 25';
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';

    var
        TableType: Option Customer,Item;
        WarningType: Option FieldNotExist,TemplateAlreadyExist;
        TaskDescriptionTxt: Label 'If you decide, we will create the customer and item templates by copying the ones you are using in your Shopify shops. If you already have templates with the same code we will skip the creation of these.';
        FeatureIdTok: Label 'ShopifyNewCustomerItemTemplates', Locked = true;


    internal procedure NewTemplatesEnabled(): Boolean
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        exit(FeatureManagementFacade.IsEnabled(FeatureIdTok))
    end;

    internal procedure FeatureKey(): Text
    begin
        exit('ShopifyNewCustomerItemTemplates');
    end;

    procedure IsDataUpdateRequired(): Boolean
    var
        Shop: Record "Shpfy Shop";
        ShpfyCustomerTemplate: Record "Shpfy Customer Template";
    begin
        Shop.SetFilter("Item Template Code", '<> %1', '');
        if not Shop.IsEmpty() then
            exit(true);
        Shop.SetFilter("Customer Template Code", '<> %1', '');
        if not Shop.IsEmpty() then
            exit(true);
        ShpfyCustomerTemplate.SetFilter("Customer Template Code", '<> %1', '');
        exit(not ShpfyCustomerTemplate.IsEmpty())
    end;

    procedure ReviewData();
    var
        Shop: Record "Shpfy Shop";
        ShpfyCustomerTemplate: Record "Shpfy Customer Template";
        TempDocumentEntry: Record "Document Entry" temporary;
        DataUpgradeOverview: Page "Data Upgrade Overview";
        CustomerTemplCounted: Dictionary of [Text, Boolean];
        ShopsCounted: Dictionary of [Text, Boolean];
        NoOfConfigTemplateHeaders: Integer;
        NoOfConfigTemplateLines: Integer;
        NoOfShops: Integer;
        NoOfShpfyCustomerTemplates: Integer;
    begin
        Shop.SetFilter("Item Template Code", '<> %1', '');
        if Shop.FindSet() then
            repeat
                ReviewTemplateData(Shop."Item Template Code", Database::Item, NoOfConfigTemplateHeaders, NoOfConfigTemplateLines);
                ShopsCounted.Add(Shop.Code, true);
                NoOfShops += 1;
            until Shop.Next() = 0;
        Shop.SetRange("Item Template Code");
        Shop.SetFilter("Customer Template Code", '<> %1', '');
        if Shop.FindSet() then
            repeat
                if not CustomerTemplCounted.ContainsKey(Shop."Customer Template Code") then begin
                    ReviewTemplateData(Shop."Customer Template Code", Database::Customer, NoOfConfigTemplateHeaders, NoOfConfigTemplateLines);
                    CustomerTemplCounted.Add(Shop."Customer Template Code", true);
                end;
                if not ShopsCounted.ContainsKey(Shop.Code) then
                    NoOfShops += 1;
            until Shop.Next() = 0;
        ShpfyCustomerTemplate.SetFilter("Customer Template Code", '<> %1', '');
        if ShpfyCustomerTemplate.FindSet() then
            repeat
                if not CustomerTemplCounted.ContainsKey(ShpfyCustomerTemplate."Customer Template Code") then begin
                    ReviewTemplateData(ShpfyCustomerTemplate."Customer Template Code", Database::Customer, NoOfConfigTemplateHeaders, NoOfConfigTemplateLines);
                    CustomerTemplCounted.Add(ShpfyCustomerTemplate."Customer Template Code", true);
                end;
                NoOfShpfyCustomerTemplates += 1;
            until ShpfyCustomerTemplate.Next() = 0;
        InsertDocumentEntry(TempDocumentEntry, Database::"Config. Template Header", NoOfConfigTemplateHeaders, 1);
        InsertDocumentEntry(TempDocumentEntry, Database::"Config. Template Line", NoOfConfigTemplateLines, 2);
        InsertDocumentEntry(TempDocumentEntry, Database::"Shpfy Shop", NoOfShops, 3);
        InsertDocumentEntry(TempDocumentEntry, Database::"Shpfy Customer Template", NoOfShpfyCustomerTemplates, 4);
        DataUpgradeOverview.Set(TempDocumentEntry);
        DataUpgradeOverview.RunModal();
    end;

    local procedure InsertDocumentEntry(var TempDocumentEntry: Record "Document Entry" temporary; TableId: Integer; NoOfRecords: Integer; EntryNo: Integer)
    var
        RecordRef: RecordRef;
    begin
        RecordRef.Open(TableId);
        TempDocumentEntry."Entry No." := EntryNo;
        TempDocumentEntry."Table ID" := TableId;
        TempDocumentEntry."No. of Records" := NoOfRecords;
        TempDocumentEntry."Table Name" := CopyStr(RecordRef.Caption(), 1, 100);
        TempDocumentEntry.Insert();
    end;

    local procedure ReviewTemplateData(TemplateCode: Code[10]; TableNo: Integer; var NoOfConfigTemplateHeaders: Integer; var NoOfConfigTemplateLines: Integer)
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateLine: Record "Config. Template Line";
    begin
        ConfigTemplateHeader.SetRange(Code, TemplateCode);
        ConfigTemplateHeader.SetRange("Table ID", TableNo);
        if ConfigTemplateHeader.IsEmpty() then
            exit;
        NoOfConfigTemplateHeaders += 1;
        ConfigTemplateLine.SetRange("Data Template Code", TemplateCode);
        ConfigTemplateLine.SetRange("Table ID", TableNo);
        NoOfConfigTemplateLines += ConfigTemplateLine.Count();
    end;

    procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    var
        ShpfyUpgradeMgt: Codeunit "Shpfy Upgrade Mgt.";
    begin
        if not FeatureDataUpdateStatus."Shpfy Templates Migrate" then
            exit;
        ShpfyUpgradeMgt.UpgradeTemplatesData();
    end;

    procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    begin
    end;

    procedure GetTaskDescription(): Text;
    begin
        exit(TaskDescriptionTxt);
    end;

    internal procedure CanUpgradeAllFields(var TempShpfyTemplateWarnings: Record "Shpfy Templates Warnings" temporary): Boolean
    var
        Shop: Record "Shpfy Shop";
        ShpfyCustomerTemplate: Record "Shpfy Customer Template";
        CanUpgradeFields: Boolean;
    begin
        CanUpgradeFields := true;
        TempShpfyTemplateWarnings.DeleteAll();
        if Shop.FindSet() then
            repeat
                if Shop."Item Template Code" <> '' then begin
                    if not CanUpgradeAllFieldsOfTemplate(TempShpfyTemplateWarnings, TableType::Item, Shop."Item Template Code") then
                        CanUpgradeFields := false;
                    VerifyNonExistingItemTemplate(TempShpfyTemplateWarnings, Shop."Item Template Code");
                end;
                if Shop."Customer Template Code" <> '' then begin
                    if not CanUpgradeAllFieldsOfTemplate(TempShpfyTemplateWarnings, TableType::Customer, Shop."Customer Template Code") then
                        CanUpgradeFields := false;
                    VerifyNonExistingCustomerTemplate(TempShpfyTemplateWarnings, Shop."Customer Template Code");
                end
            until Shop.Next() = 0;

        if ShpfyCustomerTemplate.FindSet() then
            repeat
                if ShpfyCustomerTemplate."Customer Template Code" <> '' then
                    if not CanUpgradeAllFieldsOfTemplate(TempShpfyTemplateWarnings, TableType::Customer, ShpfyCustomerTemplate."Customer Template Code") then
                        CanUpgradeFields := false;
            until ShpfyCustomerTemplate.Next() = 0;
        exit(CanUpgradeFields);
    end;

    local procedure VerifyNonExistingItemTemplate(var TempShpfyTemplateWarnings: Record "Shpfy Templates Warnings" temporary; TemplateCode: Code[10])
    var
        ItemTempl: Record "Item Templ.";
    begin
        if not ItemTempl.Get(TemplateCode) then
            exit;
        AddUpgradeWarning(TempShpfyTemplateWarnings, WarningType::TemplateAlreadyExist, TableType::Item, '', 0, TemplateCode);
    end;


    local procedure VerifyNonExistingCustomerTemplate(var TempShpfyTemplateWarnings: Record "Shpfy Templates Warnings" temporary; TemplateCode: Code[10])
    var
        CustomerTempl: Record "Customer Templ.";
    begin
        if not CustomerTempl.Get(TemplateCode) then
            exit;
        AddUpgradeWarning(TempShpfyTemplateWarnings, WarningType::TemplateAlreadyExist, TableType::Customer, '', 0, TemplateCode);
    end;

    local procedure CanUpgradeAllFieldsOfTemplate(var TempShpfyTemplateWarnings: Record "Shpfy Templates Warnings" temporary; TemplateTableType: Option; TemplateCode: Code[10]): Boolean
    var
        ConfigTemplateLine: Record "Config. Template Line";
        RecordRef: RecordRef;
        TemplTableNo: Integer;
        TableNo: Integer;
        CanUpgradeField: Boolean;
    begin
        if TemplateTableType = TableType::Customer then begin
            TemplTableNo := Database::"Customer Templ.";
            TableNo := Database::Customer;
        end else begin
            TemplTableNo := Database::"Item Templ.";
            TableNo := Database::Item;
        end;
        CanUpgradeField := true;
        RecordRef.Open(TemplTableNo);
        ConfigTemplateLine.SetRange("Table ID", TableNo);
        ConfigTemplateLine.SetRange("Data Template Code", TemplateCode);
        ConfigTemplateLine.SetRange(Type, ConfigTemplateLine.Type::Field);
        if not ConfigTemplateLine.FindSet() then
            exit(true);
        repeat
            if not RecordRef.FieldExist(ConfigTemplateLine."Field ID") then begin
                AddUpgradeWarning(TempShpfyTemplateWarnings, WarningType::FieldNotExist, TemplateTableType, ConfigTemplateLine."Field Name", ConfigTemplateLine."Field ID", TemplateCode);
                CanUpgradeField := false;
            end
        until ConfigTemplateLine.Next() = 0;
        exit(CanUpgradeField);
    end;

    local procedure AddUpgradeWarning(var TempShpfyTemplateWarnings: Record "Shpfy Templates Warnings" temporary; WarningTypeOption: Option; TemplateTableType: Option; FieldName: Text[2048]; FieldId: Integer; TemplateCode: Code[10])
    var
        Warning: Text[2048];
    begin
        if WarningTypeOption = WarningType::FieldNotExist then
            Warning := 'Field doesn''t exist'
        else
            Warning := 'Template already exists';
        if TempShpfyTemplateWarnings.Get(TemplateTableType, TemplateCode, FieldId, Warning) then
            exit;
        TempShpfyTemplateWarnings.Reset();
        TempShpfyTemplateWarnings.Warning := Warning;
        TempShpfyTemplateWarnings."Template Type" := TemplateTableType;
        TempShpfyTemplateWarnings."Template Code" := TemplateCode;
        TempShpfyTemplateWarnings."Field Name" := FieldName;
        TempShpfyTemplateWarnings."Field Id" := FieldId;
        TempShpfyTemplateWarnings.Insert();
    end;


}
#endif