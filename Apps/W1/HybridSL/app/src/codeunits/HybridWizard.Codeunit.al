// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.DataMigration;
using System.Environment;

codeunit 42012 "SL Hybrid Wizard"
{
    Access = Internal;

    var
        ProductIdLbl: Label 'DynamicsSL', Locked = true;
        ProductNameTxt: Label 'Dynamics SL', Locked = true;
        TooManySegmentsErr: Label 'You have selected a company that has more than 9 segments. In order to migrate your data you need to reformat your Chart of Accounts in Dynamics SL to have less than 10 segments for these companies: %1', Comment = '%1 - Comma delimited list of companies.';
        AdditionalProcessesInProgressErr: Label 'Cannot start a new migration until the previous migration run and additional/posting processes have completed.';
        ProductDescriptionTxt: Label 'Use this option if you are migrating from Dynamics SL. The migration process transforms the Dynamics SL data to the Dynamics 365 Business Central format.';

    internal procedure ProductIdTxt(): Text[250]
    begin
        exit(CopyStr(ProductIdLbl, 1, 250));
    end;

    internal procedure ProductNameSL(): Text[250]
    begin
        exit(CopyStr(ProductNameTxt, 1, 250));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", OnGetHybridProductDescription, '', false, false)]
    local procedure HandleGetHybridProductDescription(ProductId: Text; var ProductDescription: Text)
    begin
        if ProductId = ProductIdLbl then
            ProductDescription := ProductDescriptionTxt;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", OnGetHybridProductType, '', false, false)]
    local procedure OnGetHybridProductType(var HybridProductType: Record "Hybrid Product Type")
    var
        extensionId: Guid;
        extensionInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(extensionInfo);
        extensionId := extensionInfo.Id();
        if not HybridProductType.Get(ProductIdLbl) then begin
            HybridProductType.Init();
            HybridProductType."App ID" := extensionId;
            HybridProductType."Display Name" := CopyStr(ProductNameTxt, 1, 250);
            HybridProductType.ID := CopyStr(ProductIdLbl, 1, 250);
            HybridProductType.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", OnGetHybridProductName, '', false, false)]
    local procedure HandleGetHybridProductName(ProductId: Text; var ProductName: Text)
    begin
        if not CanHandle(ProductId) then
            exit;

        ProductName := ProductNameTxt;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Companies IC", OnBeforeCreateCompany, '', false, false)]
    local procedure HandleOnBeforeCreateCompany(ProductId: Text; var CompanyDataType: Option "Evaluation Data","Standard Data",None,"Extended Data","Full No Data")
    begin

        if not CanHandle(ProductId) then
            exit;

        CompanyDataType := CompanyDataType::"Standard Data";
    end;

    internal procedure CanHandle(productId: Text): Boolean
    begin
        if productId = ProductIdLbl then
            exit(true);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", CanMapCustomTables, '', false, false)]
    local procedure OnCanMapCustomTables(var Enabled: Boolean)
    begin
        if not (GetSLMigrationEnabled()) then
            exit;

        Enabled := true;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", CanRunDiagnostic, '', false, false)]
    local procedure OnCanRunDiagnostic(var CanRun: Boolean)
    begin
        if not (GetSLMigrationEnabled()) then
            exit;

        CanRun := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", OnCanSetupAdlMigration, '', false, false)]
    local procedure OnCanSetupAdlMigration(var CanSetup: Boolean)
    begin
        if not (GetSLMigrationEnabled()) then
            exit;

        CanSetup := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Hybrid Cloud Management", OnBeforeShowProductSpecificSettingsPageStep, '', false, false)]
    local procedure BeforeShowProductSpecificSettingsPageStep(var HybridProductType: Record "Hybrid Product Type"; var ShowSettingsStep: Boolean)
    var
        CompanyList: List of [Text];
        CompanyName: Text;
        MessageTxt: Text;
    begin
        if not CanHandle(HybridProductType.ID) then
            exit;

        AnyCompaniesWithTooManySegments(CompanyList);
        if CompanyList.Count() > 0 then begin
            foreach CompanyName in CompanyList do
                MessageTxt := MessageTxt + ', ' + CompanyName;

            Error(TooManySegmentsErr, MessageTxt.TrimStart(','));
        end;

        ShowSettingsStep := false;
    end;

    internal procedure AnyCompaniesWithTooManySegments(var CompanyList: List of [Text])
    var
        SLCompanyMigrationSettings: Record "SL Company Migration Settings";
    begin
        SLCompanyMigrationSettings.SetFilter(Replicate, '=%1', true);
        SLCompanyMigrationSettings.SetFilter(NumberOfSegments, '>%1', 9);
        if SLCompanyMigrationSettings.FindSet() then
            repeat
                CompanyList.Add(SLCompanyMigrationSettings.Name);
            until SLCompanyMigrationSettings.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", CanShowUpdateReplicationCompanies, '', false, false)]
    local procedure OnCanShowUpdateReplicationCompanies(var Enabled: Boolean)
    begin
        if not (GetSLMigrationEnabled()) then
            exit;

        Enabled := false;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Intelligent Cloud Management", CheckAdditionalProcesses, '', false, false)]
    local procedure CheckAdditionalProcesses(var AdditionalProcessesRunning: Boolean; var ErrorMessage: Text)
    begin
        AdditionalProcessesRunning := ProcessesAreRunning();

        if AdditionalProcessesRunning then
            ErrorMessage := AdditionalProcessesInProgressErr;
    end;

    [EventSubscriber(ObjectType::Table, Database::Company, OnAfterDeleteEvent, '', false, false)]
    local procedure CompanyOnAfterDelete(var Rec: Record Company; RunTrigger: Boolean)
    var
        SLCompanyMigrationSettings: Record "SL Company Migration Settings";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        HybridCompany: Record "Hybrid Company";
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridReplicationDetail: Record "Hybrid Replication Detail";
        SLMigrationErrorOverview: Record "SL Migration Error Overview";
        SLMigrationWarnings: Record "SL Migration Warnings";
    begin
        if Rec.IsTemporary() then
            exit;

        if (SLCompanyMigrationSettings.Get(Rec.Name)) then
            SLCompanyMigrationSettings.Delete();

        if (SLCompanyAdditionalSettings.Get(Rec.Name)) then
            SLCompanyAdditionalSettings.Delete();

        if (HybridCompanyStatus.Get(Rec.Name)) then
            HybridCompanyStatus.Delete();

        if (HybridCompany.Get(Rec.Name)) then
            HybridCompany.Delete();

        HybridReplicationDetail.SetRange("Company Name", Rec.Name);
        if not HybridReplicationDetail.IsEmpty() then
            HybridReplicationDetail.DeleteAll();

        SLMigrationErrorOverview.SetRange("Company Name", Rec.Name);
        if not SLMigrationErrorOverview.IsEmpty() then
            SLMigrationErrorOverview.DeleteAll();

        SLMigrationWarnings.SetRange("Company Name", Rec.Name);
        if not SLMigrationWarnings.IsEmpty() then
            SLMigrationWarnings.DeleteAll();
    end;

    internal procedure ProcessesAreRunning(): Boolean
    var
        SLCompanyMigrationSettings: Record "SL Company Migration Settings";
    begin
        SLCompanyMigrationSettings.Reset();
        SLCompanyMigrationSettings.SetRange(Replicate, true);
        SLCompanyMigrationSettings.SetRange(ProcessesAreRunning, true);
        if SLCompanyMigrationSettings.IsEmpty() then
            exit(false);

        exit(true);
    end;

    internal procedure GetSLMigrationEnabled(): Boolean
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
    begin
        if not IntelligentCloudSetup.Get() then
            exit(false);

        exit(CanHandle(IntelligentCloudSetup."Product ID"));
    end;
}