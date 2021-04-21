// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 14109 "CD Extension Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        if not InitializeDone() then
            UpgradeCDTracking();

        OnCompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure OnCompanyInitialize()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure OnAfterClassifyCountrySpecificTables()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure InitializeDone(): boolean
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() <> Version.Create('0.0.0.0'));
    end;

    local procedure UpgradeCDTracking()
    begin
        UpdateInventorySetup();

        MoveCDNoFormats();
        MoveCDNoHeaders();
        MoveCDTrackingSetup();

        UpdateItemTrackingCodes();
        UpdatePackageNoInformation();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        FixedAsset: Record "Fixed Asset";
        PackageNoInformation: Record "Package No. Information";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"CD Number Format");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"CD Number Header");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"CD FA Information");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"CD Location Setup");

        DataClassificationMgt.SetFieldToNormal(Database::"Fixed Asset", FixedAsset.FieldNo("CD Number"));
        DataClassificationMgt.SetFieldToNormal(Database::"Package No. Information", PackageNoInformation.FieldNo("CD Header Number"));
        DataClassificationMgt.SetFieldToNormal(Database::"Package No. Information", PackageNoInformation.FieldNo("Temporary CD Number"));
    end;

    local procedure UpdateItemTrackingCodes();
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if ItemTrackingCode.FindSet() then
            repeat
                ItemTrackingCode.Validate("Package Specific Tracking", ItemTrackingCode."CD Specific Tracking");
                ItemTrackingCode.Validate("Package Warehouse Tracking", ItemTrackingCode."CD Warehouse Tracking");
                ItemTrackingCode.Modify();
            until ItemTrackingCode.Next() = 0;
    end;

    local procedure UpdatePackageNoInformation();
    var
        PackageNoInformation: Record "Package No. Information";
    begin
        if PackageNoInformation.FindSet() then
            repeat
                PackageNoInformation."CD Header Number" := PackageNoInformation."CD Header No.";
                PackageNoInformation.Modify();
            until PackageNoInformation.Next() = 0;
    end;

    local procedure UpdateInventorySetup()
    var
        InventorySetup: Record "Inventory Setup";
        CDItemTrackingMgt: Codeunit "CD Item Tracking Mgt.";
    begin
        InventorySetup.Get();
        InventorySetup.TestField("Package Caption", '');
        InventorySetup."Package Caption" :=
            CopyStr(CDItemTrackingMgt.CDCaption(), 1, MaxStrLen(InventorySetup."Package Caption"));
        InventorySetup."Check CD Number Format" := InventorySetup."Check CD No. Format";
        InventorySetup.Modify();
    end;

    local procedure MoveCDNoFormats();
    var
        CDNoFormat: Record "CD No. Format";
        CDNumberFormat: Record "CD Number Format";
    begin
        if CDNoFormat.FindSet() then
            repeat
                CDNumberFormat.Init();
                CDNumberFormat."Line No." := CDNoFormat."Line No.";
                CDNumberFormat.Format := CDNoFormat.Format;
                CDNumberFormat.Insert();
            until CDNoFormat.Next() = 0;
    end;

    local procedure MoveCDNoHeaders();
    var
        CDNoHeader: Record "CD No. Header";
        CDNumberHeader: Record "CD Number Header";
    begin
        if CDNoHeader.FindSet() then
            repeat
                CDNumberHeader.Init();
                CDNumberHeader."No." := CDNoHeader."No.";
                CDNumberHeader."Declaration Date" := CDNoHeader."Declaration Date";
                CDNumberHeader.Description := CDNoHeader.Description;
                CDNumberHeader."Source Type" := CDNoHeader."Source Type";
                CDNumberHeader."Source No." := CDNoHeader."Source No.";
                CDNumberHeader."No. Series" := CDNoHeader."No. Series";
                CDNumberHeader.Insert();
            until CDNoHeader.Next() = 0;
    end;

    local procedure MoveCDTrackingSetup();
    var
        CDTrackingSetup: Record "CD Tracking Setup";
        CDLocationSetup: Record "CD Location Setup";
    begin
        if CDTrackingSetup.FindSet() then
            repeat
                CDLocationSetup.Init();
                CDLocationSetup."Location Code" := CDTrackingSetup."Location Code";
                CDLocationSetup."Item Tracking Code" := CDTrackingSetup."Item Tracking Code";
                CDLocationSetup.Description := CDTrackingSetup.Description;
                CDLocationSetup."Allow Temporary CD Number" := CDTrackingSetup."Allow Temporary CD No.";
                CDLocationSetup."CD Info. Must Exist" := CDTrackingSetup."CD Info. Must Exist";
                CDLocationSetup."CD Purchase Check on Release" := CDTrackingSetup."CD Purchase Check on Release";
                CDLocationSetup."CD Sales Check on Release" := CDTrackingSetup."CD Sales Check on Release";
                CDLocationSetup.Insert();
            until CDTrackingSetup.Next() = 0;
    end;
}