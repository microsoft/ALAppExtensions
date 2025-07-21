// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool;

using Microsoft.Utilities;
using Microsoft.Finance.GeneralLedger.Setup;
using System.Environment;
using Microsoft.Foundation.Company;

codeunit 5382 "Company Creation Contoso"
{
    Access = Internal;
    TableNo = "Contoso Demo Data Module";
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        TempContosoDemoDataModule: Record "Contoso Demo Data Module" temporary;
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        GLSetup: Record "General Ledger Setup";
        ContosoDemoTool: Codeunit "Contoso Demo Tool";
        IsSetup: Boolean;
    begin
        if AssistedCompanySetupStatus.Get(CompanyName) then begin
            AssistedCompanySetupStatus."Server Instance ID" := ServiceInstanceId();
            AssistedCompanySetupStatus."Company Setup Session ID" := SessionId();
            AssistedCompanySetupStatus.Modify();
            Commit();
        end;

        // Init Company
        if not GLSetup.Get() then
            CODEUNIT.Run(CODEUNIT::"Company-Initialize");

        IsSetup := AssistedCompanySetupStatus."Company Demo Data" = Enum::"Company Demo Data Type"::"Production - Setup Data Only";

        if Rec.IsEmpty() then begin
            ContosoDemoTool.GetRefreshedModules(TempContosoDemoDataModule);
            TempContosoDemoDataModule.ModifyAll(Install, true);

            Session.LogMessage('0000OL3', StrSubstNo(RunningAllContosoModulesLbl, CompanyName, IsSetup), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ContosoCoffeeDemoDatasetFeatureNameTok);

            ContosoDemoTool.CreateNewCompanyDemoData(TempContosoDemoDataModule, IsSetup);
        end else begin
            ContosoDemoTool.RefreshModules();

            Session.LogMessage('0000OL4', StrSubstNo(RunningCustomContosoModulesLbl, CompanyName, IsSetup), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ContosoCoffeeDemoDatasetFeatureNameTok);

            ContosoDemoTool.CreateNewCompanyDemoData(Rec, IsSetup);
        end;

        // Set company setup status to completed
        AssistedCompanySetupStatus.Get(CompanyName);

        AssistedCompanySetupStatus."Company Setup Session ID" := 0;
        AssistedCompanySetupStatus."Server Instance ID" := 0;
        Clear(AssistedCompanySetupStatus."Task ID");
        AssistedCompanySetupStatus.Modify();
        Commit();
    end;

    procedure CreateContosoDemodataInCompany(var ContosoDemoDataModuleTemp: Record "Contoso Demo Data Module" temporary; NewCompanyName: Text[30]; NewCompanyData: Enum "Company Demo Data Type")
    var
        Company: Record Company;
        DataClassificationEvalData: Codeunit "Data Classification Eval. Data";
        IsSetup: Boolean;
    begin
        IsSetup := NewCompanyData = NewCompanyData::"Production - Setup Data Only";

        if not IsSetup then begin
            Company.Get(NewCompanyName);
            Company."Evaluation Company" := true;
            Company.Modify();
            Commit();
            DataClassificationEvalData.CreateEvaluationData();
            Session.LogMessage('0000HUJ', StrSubstNo(CompanyEvaluationTxt, Company."Evaluation Company"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CompanyEvaluationCategoryTok);
        end;

        ScheduleRunningContosoDemoData(ContosoDemoDataModuleTemp, NewCompanyName, IsSetup);

        Session.LogMessage('0000OL5', StrSubstNo(ScheduledDemoDataLbl, NewCompanyName, IsSetup), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ContosoCoffeeDemoDatasetFeatureNameTok);
    end;

    local procedure ScheduleRunningContosoDemoData(var ContosoDemoDataModuleTemp: Record "Contoso Demo Data Module" temporary; NewCompanyName: Text[30]; IsSetup: Boolean)
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        ImportSessionID: Integer;
    begin
        AssistedCompanySetupStatus.LockTable();
        AssistedCompanySetupStatus.Get(NewCompanyName);
        if IsSetup then
            AssistedCompanySetupStatus."Company Demo Data" := Enum::"Company Demo Data Type"::"Production - Setup Data Only"
        else
            AssistedCompanySetupStatus."Company Demo Data" := Enum::"Company Demo Data Type"::"Evaluation - Contoso Sample Data";
        AssistedCompanySetupStatus.Modify();

        Commit();
        AssistedCompanySetupStatus."Task ID" := CreateGuid();
        ImportSessionID := 0;

        StartSession(ImportSessionID, CODEUNIT::"Generate Contoso Demo Data", AssistedCompanySetupStatus."Company Name", ContosoDemoDataModuleTemp);

        AssistedCompanySetupStatus."Company Setup Session ID" := ImportSessionID;
        if AssistedCompanySetupStatus."Company Setup Session ID" = 0 then
            Clear(AssistedCompanySetupStatus."Task ID");
        AssistedCompanySetupStatus.Modify();
        Commit();
    end;

    var
        CompanyEvaluationTxt: Label 'Company Evaluation:%1', Comment = '%1 = Company Evaluation', Locked = true;
        CompanyEvaluationCategoryTok: Label 'Company Evaluation', Locked = true;
        ContosoCoffeeDemoDatasetFeatureNameTok: Label 'ContosoCoffeeDemoDataset', Locked = true;
        ScheduledDemoDataLbl: Label 'Scheduled demo data generation for company %1 with setup data %2', Comment = '%1 = Company Name, %2 = Is Setup Company', Locked = true;
        RunningAllContosoModulesLbl: Label 'Running all Contoso modules for company %1 with setup data %2', Locked = true;
        RunningCustomContosoModulesLbl: Label 'Running custom Contoso modules for company %1 with setup data %2', Locked = true;
}
