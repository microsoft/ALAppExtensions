namespace Microsoft.Finance.PowerBIReports;

using Microsoft.Foundation.Company;

codeunit 36953 "Finance Installation Handler"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        FinanceAppInfo: ModuleInfo;
    begin
        if NavApp.GetCurrentModuleInfo(FinanceAppInfo) then
            if FinanceAppInfo.DataVersion = Version.Create('0.0.0.0') then
                InitializePowerBIAccountCategories();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure OnCompanyInitialize()
    begin
        InitializePowerBIAccountCategories();
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"Account Category", 'r')]
    local procedure InitializePowerBIAccountCategories()
    var
        PowerBIAccountCategory: Record "Account Category";
    begin
        if PowerBIAccountCategory.IsEmpty() then begin
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L1Assets);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L1Liabilities);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L1Equity);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L1Revenue);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L1CostOfGoodsSold);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L1Expense);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2CurrentAssets);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2CurrentLiabilities);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2PayrollLiabilities);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2LongTermLiabilities);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2ShareholdersEquity);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L3Inventory);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2InterestExpense);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2TaxExpense);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2ExtraordinaryExpense);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L3AccountsPayable);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L3AccountsReceivable);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L3Purchases);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2FXLossesExpense);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2DepreciationAmortizationExpense);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2InterestRevenue);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2FXGainsIncome);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2ExtraordinaryIncome);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L3PurchasePrepayments);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L3LiquidAssets);
            InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2FixedAssets);
        end;
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"Account Category", 'i')]
    local procedure InsertPowerBIAccountCategory(AccountCategoryType: Enum "Account Category Type")
    var
        NewPowerBIAccountCategory: Record "Account Category";
    begin
        NewPowerBIAccountCategory.Init();
        NewPowerBIAccountCategory."Account Category Type" := AccountCategoryType;
        NewPowerBIAccountCategory.Insert();
    end;
}