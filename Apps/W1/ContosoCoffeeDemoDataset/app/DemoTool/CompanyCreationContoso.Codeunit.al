codeunit 5382 "Company Creation Contoso"
{
    TableNo = "Contoso Demo Data Module";
    Access = Internal;

    trigger OnRun()
    var
        ContosoDemoDataModule: Record "Contoso Demo Data Module";
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        GLSetup: Record "General Ledger Setup";
        ContosoDemoTool: Codeunit "Contoso Demo Tool";
    begin
        AssistedCompanySetupStatus.Get(CompanyName);
        AssistedCompanySetupStatus."Server Instance ID" := ServiceInstanceId();
        AssistedCompanySetupStatus."Company Setup Session ID" := SessionId();
        AssistedCompanySetupStatus.Modify();
        Commit();

        // Init Company
        if not GLSetup.Get() then
            CODEUNIT.Run(CODEUNIT::"Company-Initialize");

        ContosoDemoTool.RefreshModules(ContosoDemoDataModule);

        ContosoDemoTool.CreateNewCompanyDemoData(Rec, Rec."Is Setup Company");

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

        if ContosoDemoDataModuleTemp.FindSet() then
            repeat
                ContosoDemoDataModuleTemp."Is Setup Company" := IsSetup;
            until ContosoDemoDataModuleTemp.Next() = 0;

        ScheduleRunningContosoDemoData(ContosoDemoDataModuleTemp, NewCompanyName);
    end;

    local procedure ScheduleRunningContosoDemoData(var ContosoDemoDataModuleTemp: Record "Contoso Demo Data Module" temporary; NewCompanyName: Text[30])
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
        ImportSessionID: Integer;
    begin
        AssistedCompanySetupStatus.LockTable();
        AssistedCompanySetupStatus.Get(NewCompanyName);

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
}