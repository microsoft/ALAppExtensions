codeunit 31251 "Upgrade Application CZA"
{
    Subtype = Upgrade;
    Permissions = tabledata "Detailed G/L Entry CZA" = im,
                  tabledata "G/L Entry" = m,
                  tabledata "Inventory Setup" = m,
                  tabledata "Manufacturing Setup" = m;

    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZA: Codeunit "Upgrade Tag Definitions CZA";
        InstallApplicationsMgtCZL: Codeunit "Install Applications Mgt. CZL";
        AppInfo: ModuleInfo;

    trigger OnUpgradePerDatabase()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        UpgradePermission();
        SetDatabaseUpgradeTags();
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();
        BindSubscription(InstallApplicationsMgtCZL);
        UpgradeUsage();
        UpgradeData();
        UnbindSubscription(InstallApplicationsMgtCZL);
        SetCompanyUpgradeTags();
    end;

    local procedure UpgradePermission()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerDatabaseUpgradeTag()) then
            exit;

        NavApp.GetCurrentModuleInfo(AppInfo);
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Detailed G/L Entry", Database::"Detailed G/L Entry CZA");
        UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerDatabaseUpgradeTag());
    end;

    local procedure UpgradeUsage()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerDatabaseUpgradeTag()) then
            exit;

        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Detailed G/L Entry", Database::"Detailed G/L Entry CZA");
    end;

    local procedure UpgradeData()
    begin
        UpgradeDetailedGLEntry();
        UpgradeGLEntry();
        UpgradeDefaultDimension();
        UpgradeInventorySetup();
        UpgradeManufacturingSetup();
    end;

    local procedure UpgradeDetailedGLEntry()
    var
        DetailedGLEntry: Record "Detailed G/L Entry";
        DetailedGLEntryCZA: Record "Detailed G/L Entry CZA";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerCompanyUpgradeTag()) then
            exit;

        if DetailedGLEntry.FindSet() then
            repeat
                if not DetailedGLEntryCZA.Get(DetailedGLEntry."Entry No.") then begin
                    DetailedGLEntryCZA.Init();
                    DetailedGLEntryCZA."Entry No." := DetailedGLEntry."Entry No.";
                    DetailedGLEntryCZA.SystemId := DetailedGLEntry.SystemId;
                    DetailedGLEntryCZA.Insert(false, true);
                end;
                DetailedGLEntryCZA."G/L Entry No." := DetailedGLEntry."G/L Entry No.";
                DetailedGLEntryCZA."Applied G/L Entry No." := DetailedGLEntry."Applied G/L Entry No.";
                DetailedGLEntryCZA."G/L Account No." := DetailedGLEntry."G/L Account No.";
                DetailedGLEntryCZA."Posting Date" := DetailedGLEntry."Posting Date";
                DetailedGLEntryCZA."Document No." := DetailedGLEntry."Document No.";
                DetailedGLEntryCZA."Transaction No." := DetailedGLEntry."Transaction No.";
                DetailedGLEntryCZA.Amount := DetailedGLEntry.Amount;
                DetailedGLEntryCZA.Unapplied := DetailedGLEntry.Unapplied;
                DetailedGLEntryCZA."Unapplied by Entry No." := DetailedGLEntry."Unapplied by Entry No.";
                DetailedGLEntryCZA."User ID" := DetailedGLEntry."User ID";
                DetailedGLEntryCZA.Modify(false);
            until DetailedGLEntry.Next() = 0;
    end;

    local procedure UpgradeGLEntry();
    var
        GLEntry: Record "G/L Entry";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerCompanyUpgradeTag()) then
            exit;

        if GLEntry.FindSet(true) then
            repeat
                GLEntry."Closed CZA" := GLEntry.Closed;
                GLEntry."Closed at Date CZA" := GLEntry."Closed at Date";
                GLEntry."Applied Amount CZA" := GLEntry."Applied Amount";
                GLEntry.Modify(false);
            until GLEntry.Next() = 0;
    end;

    local procedure UpgradeDefaultDimension();
    var
        DefaultDimension: Record "Default Dimension";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion183PerCompanyUpgradeTag()) then
            exit;

        if DefaultDimension.FindSet(true) then
            repeat
                if DefaultDimension."Automatic Create" then begin
                    DefaultDimension."Automatic Create CZA" := DefaultDimension."Automatic Create";
                    DefaultDimension."Dim. Description Field ID CZA" := DefaultDimension."Dimension Description Field ID";
                    DefaultDimension."Dim. Description Format CZA" := DefaultDimension."Dimension Description Format";
                    DefaultDimension."Dim. Description Update CZA" := DefaultDimension."Dimension Description Update";
                    case DefaultDimension."Automatic Cr. Value Posting" of
                        DefaultDimension."Automatic Cr. Value Posting"::" ":
                            DefaultDimension."Auto. Create Value Posting CZA" := DefaultDimension."Auto. Create Value Posting CZA"::" ";
                        DefaultDimension."Automatic Cr. Value Posting"::"No Code":
                            DefaultDimension."Auto. Create Value Posting CZA" := DefaultDimension."Auto. Create Value Posting CZA"::"No Code";
                        DefaultDimension."Automatic Cr. Value Posting"::"Same Code":
                            DefaultDimension."Auto. Create Value Posting CZA" := DefaultDimension."Auto. Create Value Posting CZA"::"Same Code";
                        DefaultDimension."Automatic Cr. Value Posting"::"Code Mandatory":
                            DefaultDimension."Auto. Create Value Posting CZA" := DefaultDimension."Auto. Create Value Posting CZA"::"Code Mandatory";
                    end;
                    Clear(DefaultDimension."Automatic Create");
                    Clear(DefaultDimension."Dimension Description Field ID");
                    Clear(DefaultDimension."Dimension Description Format");
                    Clear(DefaultDimension."Dimension Description Update");
                    Clear(DefaultDimension."Automatic Cr. Value Posting");
                    DefaultDimension.Modify(false);
                end;
            until DefaultDimension.Next() = 0;
    end;

    local procedure UpgradeInventorySetup();
    var
        InventorySetup: Record "Inventory Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerCompanyUpgradeTag()) then
            exit;

        if InventorySetup.Get() then begin
            InventorySetup."Exact Cost Revers. Mandat. CZA" := InventorySetup."Exact Cost Reversing Mandatory";
            InventorySetup.Modify(false);
        end;
    end;

    local procedure UpgradeManufacturingSetup();
    var
        ManufacturingSetup: Record "Manufacturing Setup";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerCompanyUpgradeTag()) then
            exit;

        if ManufacturingSetup.Get() then begin
            ManufacturingSetup."Exact Cost Rev.Mand. Cons. CZA" := ManufacturingSetup."Exact Cost Rev.Manda. (Cons.)";
            ManufacturingSetup.Modify(false);
        end;
    end;

    local procedure SetDatabaseUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion180PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion180PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerDatabaseUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion183PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion183PerDatabaseUpgradeTag());
    end;

    local procedure SetCompanyUpgradeTags();
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion180PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion180PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion182PerCompanyUpgradeTag());
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion183PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZA.GetDataVersion183PerCompanyUpgradeTag());
    end;
}
