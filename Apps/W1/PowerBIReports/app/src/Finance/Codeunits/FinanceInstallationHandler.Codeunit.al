namespace Microsoft.Finance.PowerBIReports;
using Microsoft.Finance.GeneralLedger.Account;

using Microsoft.Foundation.Company;

codeunit 36953 "Finance Installation Handler"
{
    Access = Internal;
    Subtype = Install;
    Permissions = tabledata "G/L Account Category" = r;

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
            InsertL1AccountCategories();
            InsertL2AccountCategories();
            InsertL3AccountCategories();
        end;
    end;

    local procedure InsertL1AccountCategories()
    begin
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L1Assets, 1, 0);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L1Liabilities, 10, 0);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L1Equity, 14, 0);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L1Revenue, 18, 0);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L1CostOfGoodsSold, 26, 0);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L1Expense, 31, 0);
    end;

    local procedure InsertL2AccountCategories()
    begin
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2CurrentAssets, 2, 1);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2CurrentLiabilities, 11, 1);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2PayrollLiabilities, 12, 1);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2LongTermLiabilities, 13, 1);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2ShareholdersEquity, 15, 1);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2InterestExpense, 34, 1);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2TaxExpense, 43, 1);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2InterestRevenue, 24, 1);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2DepreciationAmortizationExpense, 9, 2);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L2FixedAssets, 7, 1);
        InsertPowerBIAccountCategoryWithoutGLAccCategory(Enum::"Account Category Type"::L2ExtraordinaryExpense, 1);
        InsertPowerBIAccountCategoryWithoutGLAccCategory(Enum::"Account Category Type"::L2FXLossesExpense, 1);
        InsertPowerBIAccountCategoryWithoutGLAccCategory(Enum::"Account Category Type"::L2FXGainsIncome, 1);
        InsertPowerBIAccountCategoryWithoutGLAccCategory(Enum::"Account Category Type"::L2ExtraordinaryIncome, 1);
    end;

    local procedure InsertL3AccountCategories()
    begin
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L3Inventory, 6, 2);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L3AccountsReceivable, 4, 2);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L3PurchasePrepayments, 5, 2);
        InsertPowerBIAccountCategory(Enum::"Account Category Type"::L3LiquidAssets, 3, 2);
        InsertPowerBIAccountCategoryWithoutGLAccCategory(Enum::"Account Category Type"::L3Purchases, 2);
        InsertPowerBIAccountCategoryWithoutGLAccCategory(Enum::"Account Category Type"::L3AccountsPayable, 2);
    end;

    local procedure InsertPowerBIAccountCategoryWithoutGLAccCategory(AccountCategoryType: Enum "Account Category Type"; GLAccCatIndentation: Integer)
    begin
        InsertPowerBIAccountCategory(AccountCategoryType, 0, GLAccCatIndentation);
    end;

    [InherentPermissions(PermissionObjectType::TableData, Database::"Account Category", 'im')]
    local procedure InsertPowerBIAccountCategory(AccountCategoryType: Enum "Account Category Type"; GLAccCatEntryNo: Integer; GLAccCatIndentation: Integer)
    var
        NewPowerBIAccountCategory: Record "Account Category";
        GLAccCatParentEntryNo: Integer;
    begin
        NewPowerBIAccountCategory.Init();
        NewPowerBIAccountCategory."Account Category Type" := AccountCategoryType;
        NewPowerBIAccountCategory.Insert();

        if ValidateGLAccountCategory(GLAccCatEntryNo, GLAccCatIndentation, GLAccCatParentEntryNo) then begin
            NewPowerBIAccountCategory."G/L Acc. Category Entry No." := GLAccCatEntryNo;

            if GLAccCatParentEntryNo > 0 then
                NewPowerBIAccountCategory."Parent Acc. Category Entry No." := GLAccCatParentEntryNo;

            NewPowerBIAccountCategory.Modify();
        end;
    end;

    local procedure ValidateGLAccountCategory(EntryNo: Integer; Indentation: Integer; var ParentEntryNo: Integer): Boolean
    var
        GLAccountCategory: Record "G/L Account Category";
    begin
        if EntryNo = 0 then
            exit(false);

        GLAccountCategory.SetLoadFields(Indentation, "Parent Entry No.");
        if GLAccountCategory.Get(EntryNo) then
            if GLAccountCategory.Indentation = Indentation then begin
                ParentEntryNo := GLAccountCategory."Parent Entry No.";
                exit(true);
            end;
    end;
}