codeunit 5288 "Install SAF-T"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if (AppInfo.DataVersion() <> Version.Create('0.0.0.0')) then
            exit;

        SetupSAFT();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        SetupSAFT();
    end;

    local procedure SetupSAFT()
    var
        MappingHelperSAFT: Codeunit "Mapping Helper SAF-T";
    begin
        ApplyEvaluationClassificationsForPrivacy();
        MappingHelperSAFT.InsertSAFTSourceCodes();
        MappingHelperSAFT.UpdateMasterDataWithNoSeries();
        MappingHelperSAFT.UpdateSAFTSourceCodesBySetup();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Source Code SAF-T");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Missing Field SAF-T");
    end;
}