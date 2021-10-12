#pragma warning disable AL0432,AL0603
codeunit 31240 "Install Application CZF"
{
    Subtype = Install;
    Permissions = tabledata "Classification Code CZF" = im,
                  tabledata "Tax Depreciation Group CZF" = im,
                  tabledata "FA Extended Posting Group CZF" = im,
                  tabledata "FA History Entry CZF" = im,
                  tabledata "FA Setup" = m,
                  tabledata "Fixed Asset" = m,
                  tabledata "Depreciation Book" = m,
                  tabledata "FA Posting Group" = m,
                  tabledata "FA Allocation" = m;

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
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"FA Extended Posting Group", Database::"FA Extended Posting Group CZF");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Classification Code", Database::"Classification Code CZF");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"FA History Entry", Database::"FA History Entry CZF");
        InstallApplicationsMgtCZL.InsertTableDataPermissions(AppInfo.Id(), Database::"Depreciation Group", Database::"Tax Depreciation Group CZF");
    end;

    local procedure CopyUsage();
    begin
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"FA Extended Posting Group", Database::"FA Extended Posting Group CZF");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Classification Code", Database::"Classification Code CZF");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"FA History Entry", Database::"FA History Entry CZF");
        InstallApplicationsMgtCZL.InsertTableDataUsage(Database::"Depreciation Group", Database::"Tax Depreciation Group CZF");
    end;

    local procedure CopyData()
    begin
        CopyFASetup();
        CopyClassificationCode();
        CopyDepreciationGroup();
        CopyFixedAsset();
        CopyDepreciationBook();
        CopyFADepreciationBook();
        CopyFAPostingGroup();
        CopyFAExtendedPostingGroup();
        CopyFAAllocation();
        CopyFAHistoryEntry();
    end;

    local procedure CopyFASetup();
    var
        FASetup: Record "FA Setup";
    begin
        if FASetup.Get() then begin
            FASetup."Fixed Asset History CZF" := FASetup."Fixed Asset History";
            if FASetup."Fixed Asset History CZF" then
                FASetup.Validate("Fixed Asset History", false);
            FASetup."Tax Depreciation Book CZF" := FASetup."Tax Depr. Book";
            FASetup."FA Acquisition As Custom 2 CZF" := FASetup."FA Acquisition As Custom 2";
            FASetup.Modify(false);
        end;
    end;

    local procedure CopyClassificationCode();
    var
        ClassificationCode: Record "Classification Code";
        ClassificationCodeCZF: Record "Classification Code CZF";
    begin
        if ClassificationCode.FindSet() then
            repeat
                if not ClassificationCodeCZF.Get(ClassificationCode.Code) then begin
                    ClassificationCodeCZF.Init();
                    ClassificationCodeCZF.Code := ClassificationCode.Code;
                    ClassificationCodeCZF.SystemId := ClassificationCode.SystemId;
                    ClassificationCodeCZF.Insert(false, true);
                end;
                ClassificationCodeCZF.Description := ClassificationCode.Description;
                ClassificationCodeCZF."Classification Type" := ClassificationCode."Classification Type";
                ClassificationCodeCZF.Modify(false);
            until ClassificationCode.Next() = 0;
    end;

    local procedure CopyDepreciationGroup();
    var
        DepreciationGroup: Record "Depreciation Group";
        TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF";
    begin
        if DepreciationGroup.FindSet() then
            repeat
                if not TaxDepreciationGroupCZF.Get(DepreciationGroup.Code, DepreciationGroup."Starting Date") then begin
                    TaxDepreciationGroupCZF.Init();
                    TaxDepreciationGroupCZF.Code := DepreciationGroup.Code;
                    TaxDepreciationGroupCZF."Starting Date" := DepreciationGroup."Starting Date";
                    TaxDepreciationGroupCZF.SystemId := DepreciationGroup.SystemId;
                    TaxDepreciationGroupCZF.Insert(false, true);
                end;
                TaxDepreciationGroupCZF.Description := DepreciationGroup.Description;
                TaxDepreciationGroupCZF."Depreciation Group" := DepreciationGroup."Depreciation Group";
                TaxDepreciationGroupCZF."Depreciation Type" := DepreciationGroup."Depreciation Type";
                TaxDepreciationGroupCZF."No. of Depreciation Years" := DepreciationGroup."No. of Depreciation Years";
                TaxDepreciationGroupCZF."No. of Depreciation Months" := DepreciationGroup."No. of Depreciation Months";
                TaxDepreciationGroupCZF."Min. Months After Appreciation" := DepreciationGroup."Min. Months After Appreciation";
                TaxDepreciationGroupCZF."Straight First Year" := DepreciationGroup."Straight First Year";
                TaxDepreciationGroupCZF."Straight Next Years" := DepreciationGroup."Straight Next Years";
                TaxDepreciationGroupCZF."Straight Appreciation" := DepreciationGroup."Straight Appreciation";
                TaxDepreciationGroupCZF."Declining First Year" := DepreciationGroup."Declining First Year";
                TaxDepreciationGroupCZF."Declining Next Years" := DepreciationGroup."Declining Next Years";
                TaxDepreciationGroupCZF."Declining Appreciation" := DepreciationGroup."Declining Appreciation";
                TaxDepreciationGroupCZF."Declining Depr. Increase %" := DepreciationGroup."Declining Depr. Increase %";
                TaxDepreciationGroupCZF.Modify(false);
            until DepreciationGroup.Next() = 0;
    end;

    local procedure CopyFixedAsset();
    var
        FixedAsset: Record "Fixed Asset";
    begin
        if FixedAsset.FindSet(true) then
            repeat
                FixedAsset."Tax Deprec. Group Code CZF" := FixedAsset."Tax Depreciation Group Code";
                FixedAsset."Classification Code CZF" := FixedAsset."Classification Code CZF";
                FixedAsset.Modify(false);
            until FixedAsset.Next() = 0;
    end;

    local procedure CopyDepreciationBook();
    var
        DepreciationBook: Record "Depreciation Book";
    begin
        if DepreciationBook.FindSet(true) then
            repeat
                DepreciationBook."Check Acq. Appr. bef. Dep. CZF" := DepreciationBook."Acqui.,Appr.before Depr. Check";
                DepreciationBook."All Acquisit. in same Year CZF" := DepreciationBook."All Acquil. in same Year";
                DepreciationBook."Check Deprec. on Disposal CZF" := DepreciationBook."Check Deprication on Disposal";
                DepreciationBook."Deprec. from 1st Year Day CZF" := DepreciationBook."Deprication from 1st Year Day";
                DepreciationBook."Deprec. from 1st Month Day CZF" := DepreciationBook."Deprication from 1st Month Day";
                DepreciationBook.Modify(false);
            until DepreciationBook.Next() = 0;
    end;

    local procedure CopyFADepreciationBook();
    var
        FADepreciationBook: Record "FA Depreciation Book";
    begin
        if FADepreciationBook.FindSet(true) then
            repeat
                FADepreciationBook."Deprec. Interrupted up to CZF" := FADepreciationBook."Depreciation Interupt up to";
                FADepreciationBook."Tax Deprec. Group Code CZF" := FADepreciationBook."Depreciation Group Code";
                FADepreciationBook."Keep Deprec. Ending Date CZF" := FADepreciationBook."Keep Depr. Ending Date";
                FADepreciationBook."Sum. Deprec. Entries From CZF" := FADepreciationBook."Summarize Depr. Entries From";
                FADepreciationBook."Prorated CZF" := FADepreciationBook.Prorated;
                FADepreciationBook.Modify(false);
            until FADepreciationBook.Next() = 0;
    end;

    local procedure CopyFAPostingGroup();
    var
        FAPostingGroup: Record "FA Posting Group";
    begin
        if FAPostingGroup.FindSet(true) then
            repeat
                FAPostingGroup."Acq. Cost Bal. Acc. Disp. CZF" := FAPostingGroup."Acq. Cost Bal. Acc. on Disp.";
                FAPostingGroup."Book Value Bal. Acc. Disp. CZF" := FAPostingGroup."Book Value Bal. Acc. on Disp.";
                FAPostingGroup.Modify(false);
            until FAPostingGroup.Next() = 0;
    end;

    local procedure CopyFAExtendedPostingGroup();
    var
        FAExtendedPostingGroup: Record "FA Extended Posting Group";
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
    begin
        if FAExtendedPostingGroup.FindSet() then
            repeat
                if not FAExtendedPostingGroupCZF.Get(FAExtendedPostingGroup."FA Posting Group Code", FAExtendedPostingGroup."FA Posting Type", FAExtendedPostingGroup.Code) then begin
                    FAExtendedPostingGroupCZF.Init();
                    FAExtendedPostingGroupCZF."FA Posting Group Code" := FAExtendedPostingGroup."FA Posting Group Code";
                    FAExtendedPostingGroupCZF."FA Posting Type" := FAExtendedPostingGroup."FA Posting Type";
                    FAExtendedPostingGroupCZF.Code := FAExtendedPostingGroup.Code;
                    FAExtendedPostingGroupCZF.SystemId := FAExtendedPostingGroup.SystemId;
                    FAExtendedPostingGroupCZF.Insert(false, true);
                end;
                FAExtendedPostingGroupCZF."Book Val. Acc. on Disp. (Gain)" := FAExtendedPostingGroup."Book Val. Acc. on Disp. (Gain)";
                FAExtendedPostingGroupCZF."Book Val. Acc. on Disp. (Loss)" := FAExtendedPostingGroup."Book Val. Acc. on Disp. (Loss)";
                FAExtendedPostingGroupCZF."Maintenance Expense Account" := FAExtendedPostingGroup."Maintenance Expense Account";
                FAExtendedPostingGroupCZF."Maintenance Balance Account" := FAExtendedPostingGroup."Maintenance Bal. Acc.";
                FAExtendedPostingGroupCZF."Sales Acc. On Disp. (Gain)" := FAExtendedPostingGroup."Sales Acc. On Disp. (Gain)";
                FAExtendedPostingGroupCZF."Sales Acc. On Disp. (Loss)" := FAExtendedPostingGroup."Sales Acc. On Disp. (Loss)";
                FAExtendedPostingGroupCZF.Modify(false);
            until FAExtendedPostingGroup.Next() = 0;
    end;

    local procedure CopyFAAllocation();
    var
        FAAllocation: Record "FA Allocation";
    begin
        if FAAllocation.FindSet(true) then
            repeat
                FAAllocation."Reason/Maintenance Code CZF" := FAAllocation."Reason/Maintenance Code";
                FAAllocation.Modify(false);
            until FAAllocation.Next() = 0;
    end;

    local procedure CopyFAHistoryEntry();
    var
        FAHistoryEntry: Record "FA History Entry";
        FAHistoryEntryCZF: Record "FA History Entry CZF";
    begin
        if FAHistoryEntry.FindSet() then
            repeat
                if not FAHistoryEntryCZF.Get(FAHistoryEntry."Entry No.") then begin
                    FAHistoryEntryCZF.Init();
                    FAHistoryEntryCZF."Entry No." := FAHistoryEntry."Entry No.";
                    FAHistoryEntryCZF.SystemId := FAHistoryEntry.SystemId;
                    FAHistoryEntryCZF.Insert(false, true);
                end;
                FAHistoryEntryCZF.Type := FAHistoryEntry.Type + 1;
                FAHistoryEntryCZF."FA No." := FAHistoryEntry."FA No.";
                FAHistoryEntryCZF."Old Value" := FAHistoryEntry."Old Value";
                FAHistoryEntryCZF."New Value" := FAHistoryEntry."New Value";
                FAHistoryEntryCZF."Posting Date" := FAHistoryEntry."Creation Date";
                FAHistoryEntryCZF."Closed by Entry No." := FAHistoryEntry."Closed by Entry No.";
                FAHistoryEntryCZF.Disposal := FAHistoryEntry.Disposal;
                FAHistoryEntryCZF."User ID" := FAHistoryEntry."User ID";
                FAHistoryEntryCZF.Modify(false);
            until FAHistoryEntry.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        DataClassEvalHandlerCZF: Codeunit "Data Class. Eval. Handler CZF";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        DataClassEvalHandlerCZF.ApplyEvaluationClassificationsForPrivacy();
        UpgradeTag.SetAllUpgradeTags();
    end;
}
