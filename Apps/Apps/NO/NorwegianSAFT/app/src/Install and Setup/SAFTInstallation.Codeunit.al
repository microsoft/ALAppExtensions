// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Foundation.Company;
using System.Environment;
using System.Privacy;

codeunit 10670 "SAF-T Installation"
{
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
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        ApplyEvaluationClassificationsForPrivacy();
        SAFTMappingHelper.InsertDefaultNoSeriesInSAFTSetup();
        InsertDefaultMappingSources();
        SAFTMappingHelper.InsertSAFTSourceCodes();
        ImportMappingCodesIfSaaS();
        SAFTMappingHelper.UpdateMasterDataWithNoSeries();
        SAFTMappingHelper.UpdateSAFTSourceCodesBySetup();
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
        DataClassificationMgt.SetTableFieldsToNormal(Database::"SAF-T Missing Field");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"SAF-T Export File");
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
        SAFTMappingSource.SetRange("Source Type", SAFTMappingSourceType);
        SAFTMappingSource.SetRange("Source No.", SourceNo);
        if SAFTMappingSource.FindFirst() then
            exit;
        SAFTMappingSource."Source Type" := SAFTMappingSourceType;
        SAFTMappingSource."Source No." := SourceNo;
        SAFTMappingSource.Insert();
    end;
}
