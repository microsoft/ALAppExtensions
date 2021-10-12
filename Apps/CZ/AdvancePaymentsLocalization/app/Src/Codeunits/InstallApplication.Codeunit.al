#pragma warning disable AL0432,AL0603
codeunit 31087 "Install Application CZZ"
{
    Subtype = Install;

    var
        InstallApplicationsMgtCZL: Codeunit "Install Applications Mgt. CZL";
        AppInfo: ModuleInfo;

    trigger OnInstallAppPerDatabase()
    begin
        CopyPermission();
    end;

    trigger OnInstallAppPerCompany()
    begin
        if not InitializeDone() then begin
            BindSubscription(InstallApplicationsMgtCZL);
            CopyUsage();
            CopyData();
            UnbindSubscription(InstallApplicationsMgtCZL);
        end;
        CompanyInitialize();
    end;

    local procedure InitializeDone(): boolean
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() <> Version.Create('0.0.0.0'));
    end;

    local procedure CopyPermission();
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Purchase Adv. Payment Template", Database::"Advance Letter Template CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Purch. Advance Letter Header", Database::"Purch. Adv. Letter Header CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Purch. Advance Letter Line", Database::"Purch. Adv. Letter Line CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Purch. Advance Letter Entry", Database::"Purch. Adv. Letter Entry CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Sales Adv. Payment Template", Database::"Advance Letter Template CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Sales Advance Letter Header", Database::"Sales Adv. Letter Header CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Sales Advance Letter Line", Database::"Sales Adv. Letter Line CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Sales Advance Letter Entry", Database::"Sales Adv. Letter Entry CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Advance Link", Database::"Advance Letter Application CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Advance Letter Line Relation", Database::"Advance Letter Application CZZ");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Advance Link Buffer", Database::"Advance Letter Link Buffer CZZ");
    end;

    local procedure CopyUsage();
    begin
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Purchase Adv. Payment Template", Database::"Advance Letter Template CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Purch. Advance Letter Header", Database::"Purch. Adv. Letter Header CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Purch. Advance Letter Line", Database::"Purch. Adv. Letter Line CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Purch. Advance Letter Entry", Database::"Purch. Adv. Letter Entry CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Sales Adv. Payment Template", Database::"Advance Letter Template CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Sales Advance Letter Header", Database::"Sales Adv. Letter Header CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Sales Advance Letter Line", Database::"Sales Adv. Letter Line CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Sales Advance Letter Entry", Database::"Sales Adv. Letter Entry CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Advance Link", Database::"Advance Letter Application CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Advance Letter Line Relation", Database::"Advance Letter Application CZZ");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Advance Link Buffer", Database::"Advance Letter Link Buffer CZZ");
    end;

    local procedure CopyData()
    begin
        // invoked by enabling in Feature Management
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        DataClassEvalHandlerCZZ: Codeunit "Data Class. Eval. Handler CZZ";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        DataClassEvalHandlerCZZ.ApplyEvaluationClassificationsForPrivacy();
        UpgradeTag.SetAllUpgradeTags();
    end;
}
