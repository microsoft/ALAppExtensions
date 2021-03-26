codeunit 2480 "SmartList Install"
{
    Subtype = Install;

    var
    // FinanceCategoryTxt: Label 'Finance';
    // SalesCategoryTxt: Label 'Sales';
    // PurchasingCategoryTxt: Label 'Purchasing';
    // InventoryCategoryTxt: Label 'Inventory';
    // HumanResourcesCategoryTxt: Label 'Human Resources';
    // JobsCategoryTxt: Label 'Jobs';
    // ResourceCategoryTxt: Label 'Resource';
    // ServiceManagementCategoryTxt: Label 'Service Management';
    // ManufacturingCategoryTxt: Label 'Manufacturing';
    // GreatPlainsCategoryTxt: Label 'Great Plains History';

    trigger OnInstallAppPerCompany();
    var
        AppInfo: ModuleInfo;
    begin
        ApplyEvaluationClassificationsForPrivacy();
        NavApp.GetCurrentModuleInfo(AppInfo);
        // if AppInfo.DataVersion() = Version.Create('0.0.0.0') then
        //     CreateDefaultSmartListRecords();
    end;

    // procedure CreateDefaultSmartListRecords()
    // var
    //     SmartListCategory: Record "SmartList Category";
    // begin
    //     if not SmartListCategory.FindFirst() then begin

    //         SmartListCategory.Init();
    //         SmartListCategory.ID := 1;
    //         SmartListCategory.Name := CopyStr(FinanceCategoryTxt, 1, 30);
    //         if SmartListCategory.Insert() then;

    //         SmartListCategory.Init();
    //         SmartListCategory.ID := 2;
    //         SmartListCategory.Name := CopyStr(SalesCategoryTxt, 1, 30);
    //         if SmartListCategory.Insert() then;

    //         SmartListCategory.Init();
    //         SmartListCategory.ID := 3;
    //         SmartListCategory.Name := CopyStr(PurchasingCategoryTxt, 1, 30);
    //         if SmartListCategory.Insert() then;

    //         SmartListCategory.Init();
    //         SmartListCategory.ID := 4;
    //         SmartListCategory.Name := CopyStr(InventoryCategoryTxt, 1, 30);
    //         if SmartListCategory.Insert() then;

    //         SmartListCategory.Init();
    //         SmartListCategory.ID := 5;
    //         SmartListCategory.Name := CopyStr(HumanResourcesCategoryTxt, 1, 30);
    //         if SmartListCategory.Insert() then;

    //         SmartListCategory.Init();
    //         SmartListCategory.ID := 6;
    //         SmartListCategory.Name := CopyStr(JobsCategoryTxt, 1, 30);
    //         if SmartListCategory.Insert() then;

    //         SmartListCategory.Init();
    //         SmartListCategory.ID := 7;
    //         SmartListCategory.Name := CopyStr(ResourceCategoryTxt, 1, 30);
    //         if SmartListCategory.Insert() then;

    //         SmartListCategory.Init();
    //         SmartListCategory.ID := 8;
    //         SmartListCategory.Name := CopyStr(ServiceManagementCategoryTxt, 1, 30);
    //         if SmartListCategory.Insert() then;

    //         SmartListCategory.Init();
    //         SmartListCategory.ID := 9;
    //         SmartListCategory.Name := CopyStr(ManufacturingCategoryTxt, 1, 30);
    //         if SmartListCategory.Insert() then;

    //         SmartListCategory.Init();
    //         SmartListCategory.ID := 99;
    //         SmartListCategory.Name := CopyStr(GreatPlainsCategoryTxt, 1, 30);
    //         if SmartListCategory.Insert() then;
    //     end;
    // end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
    begin
        // Do classification here
    end;
}