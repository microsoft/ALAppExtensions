codeunit 10670 "SAF-T Installation"
{
    Subtype = Install;

    var
        GeneralLedgerJournalsSourceCodeDescriptionLbl: Label 'General Ledger Journals';
        AccountReceivablesSourceCodeDescriptionLbl: Label 'Account Receivables';
        AccountPayablesSourceCodeDescriptionLbl: Label 'Account Payables';
        SAFTDimLbl: Label 'SAF-T Dimension No Series.';
        SAFTSetupGuideTxt: Label 'Set up SAF-T';

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
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        ApplyEvaluationClassificationsForPrivacy();
        InsertDefaultNoSeriesInSAFTSetup();
        InsertDefaultMappingSources();
        InsertSAFTSourceCodes();
        ImportMappingCodesIfSaaS();
        SAFTMappingHelper.UpdateMasterDataWithNoSeries();
        SAFTMappingHelper.UpdateSAFTSourceCodesBySetup();
        AddSAFTAssistedSetup();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"SAF-T Setup");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"SAF-T Source Code");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"SAF-T Mapping Source");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"SAF-T Mapping Category");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"SAF-T Mapping");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"SAF-T G/L Account Mapping");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"SAF-T Mapping Range");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"SAF-T Export Setup");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"SAF-T Export Header");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"SAF-T Export Line");
    end;

    local procedure InsertDefaultNoSeriesInSAFTSetup()
    var
        SAFTSetup: Record "SAF-T Setup";
    begin
        if not SAFTSetup.Get() then begin
            SAFTSetup.Init();
            SAFTSetup.Insert();
        end;
        if SAFTSetup."Dimension No. Series Code" = '' then
            SAFTSetup."Dimension No. Series Code" := InsertNoSeries('DIM', SAFTDimLbl);
        SAFTSetup.Modify();
    end;

    local procedure InsertNoSeries(NoSeriesCode: Code[20]; Description: Text[100]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeries.Init();
        NoSeries.Code := NoSeriesCode;
        NoSeries.Description := Description;
        NoSeries."Default Nos." := true;
        NoSeries."Manual Nos." := true;
        if not NoSeries.Insert() then begin
            NoSeries.Code += '-1';
            while (Not NoSeries.Insert()) do
                NoSeries.Code := IncStr(NoSeries.Code);
        end;

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine.Validate("Starting No.", NoSeries.Code + '-10000');
        NoSeriesLine.Validate("Ending No.", NoSeries.Code + '-99999');
        NoSeriesLine.Validate("Increment-by No.", 1);
        NoSeriesLine.Insert(true);

        exit(NoSeries.Code)
    end;

    local procedure ImportMappingCodesIfSaaS()
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit;

        if not SAFTMappingSource.FindSet() then
            exit;

        repeat
            SAFTXMlImport.ImportFromMappingSource(SAFTMappingSource);
        until SAFTMappingSource.Next() = 0;

    end;

    local procedure InsertDefaultMappingSources()
    var
        SAFTSetup: Record "SAF-T Setup";
        SAFTMappingSourceType: Enum "SAF-T Mapping Source Type";
    begin
        if not SAFTSetup.Get() then
            SAFTSetup.Insert();
        InsertMappingSource(SAFTMappingSourceType::"Two Digit Standard Account", 'General_Ledger_Standard_Accounts_2_character.xml');
        InsertMappingSource(SAFTMappingSourceType::"Four Digit Standard Account", 'General_Ledger_Standard_Accounts_4_character.xml');
        InsertMappingSource(SAFTMappingSourceType::"Income Statement", 'KA_Grouping_Category_Code.xml');
        InsertMappingSource(SAFTMappingSourceType::"Income Statement", 'RF-1167_Grouping_Category_Code.xml');
        InsertMappingSource(SAFTMappingSourceType::"Income Statement", 'RF-1175_Grouping_Category_Code.xml');
        InsertMappingSource(SAFTMappingSourceType::"Income Statement", 'RF-1323_Grouping_Category_Code.xml');
        InsertMappingSource(SAFTMappingSourceType::"Standard Tax Code", 'Standard_Tax_Codes.xml');
    end;

    local procedure InsertMappingSource(SAFTMappingSourceType: Enum "SAF-T Mapping Source Type"; SourceNo: Code[50])
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
    begin
        SAFTMappingSource.Init();
        SAFTMappingSource."Source Type" := SAFTMappingSourceType;
        SAFTMappingSource."Source No." := SourceNo;
        if not SAFTMappingSource.Find() then
            SAFTMappingSource.Insert();
    end;

    local procedure AddSAFTAssistedSetup()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        Info: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Info);
        AssistedSetup.Add(
            Info.Id(), PAGE::"SAF-T Setup Wizard", CopyStr(SAFTSetupGuideTxt, 1, 250),
            AssistedSetupGroup::GettingStarted);
    end;

    local procedure InsertSAFTSourceCodes()
    var
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        InsertSAFTSourceCode(SAFTMappingHelper.GetGLSAFTSourceCode(), GeneralLedgerJournalsSourceCodeDescriptionLbl);
        InsertSAFTSourceCode(SAFTMappingHelper.GetARSAFTSourceCode(), AccountReceivablesSourceCodeDescriptionLbl);
        InsertSAFTSourceCode(SAFTMappingHelper.GetAPSAFTSourceCode(), AccountPayablesSourceCodeDescriptionLbl);
        InsertSAFTSourceCode(SAFTMappingHelper.GetASAFTSourceCode(), SAFTMappingHelper.GetASAFTSourceCodeDescription());
    end;

    local procedure InsertSAFTSourceCode(Code: Code[9]; Description: Text[100])
    var
        SAFTSourceCode: Record "SAF-T Source Code";
    begin
        SAFTSourceCode.Init();
        SAFTSourceCode.Validate(Code, Code);
        SAFTSourceCode.Validate(Description, Description);
        if SAFTSourceCode.Insert(true) then;
    end;
}
