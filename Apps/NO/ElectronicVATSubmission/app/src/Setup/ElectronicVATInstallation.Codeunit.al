// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Utilities;
using System.Environment;
using System.Environment.Configuration;
using System.Media;
using System.Privacy;
using System.Security.Authentication;
using System.Telemetry;
using System.Upgrade;

codeunit 10681 "Electronic VAT Installation"
{
    Subtype = Install;

    var
        AssistedSetupTxt: Label 'Set up an electronic VAT submission';
        AssistedSetupDescriptionTxt: Label 'Connect to the ID-porten integration point and submit your VAT return to Skatteetaten.';
        AssistedSetupHelpTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2181211', Locked = true;
        AuthenticationURLTxt: Label 'https://oidc.difi.no/idporten-oidc-provider', Locked = true;

        ValidateVATReturnUrlLbl: Label 'https://idporten.api.skatteetaten.no/api/mva/grensesnittstoette/mva-melding/valider', Locked = true;
        ExchangeIDPortenToAltinnUrlLbl: Label 'https://platform.altinn.no/authentication/api/v1/exchange/id-porten', Locked = true;
        SubmissionEnvironmentUrlLbl: Label 'https://skd.apps.altinn.no/', Locked = true;
        SubmissionAppUrlLbl: Label 'skd/mva-melding-innsending-v1/', Locked = true;
        ElectronicVATLbl: Label 'ELEC VAT', Locked = true;
        ElectronicVATSetupTitleTxt: Label 'Set up electronic VAT submission';
        ElectronicVATSetupShortTitleTxt: Label 'Electronic VAT submission';
        ElectronicVATSetupDescriptionTxt: Label 'Set up Business Central to be able to report VAT to the Norwegian authorities.';


    trigger OnInstallAppPerCompany()
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        if (AppInfo.DataVersion() <> Version.Create('0.0.0.0')) then
            exit;

        RunExtensionSetup();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        RunExtensionSetup();
        UpgradeTag.SetAllUpgradeTags();
    end;

    procedure RunExtensionSetup()
    begin
        InsertElectronicVATSetup();
        UpdateVATReportSetup();
        CreateVATReportsConfiguration();
        ApplyEvaluationClassificationsForPrivacy();
    end;

    procedure InsertElectronicVATSetup()
    var
        ElecVATSetup: Record "Elec. VAT Setup";
        OAuth20: Codeunit OAuth2;
        RedirectUrl: Text;
    begin
        if ElecVATSetup.Get() then
            exit;

        ElecVATSetup.Init();
        ElecVATSetup.Insert(true);
        ElecVATSetup.Validate("OAuth Feature GUID", CreateGuid());
        ElecVATSetup.Validate("Authentication URL", AuthenticationURLTxt);
        OAuth20.GetDefaultRedirectURL(RedirectUrl);
        ElecVATSetup.Validate("Redirect URL", CopyStr(RedirectUrl, 1, MaxStrLen(ElecVATSetup."Redirect URL")));
        ElecVATSetup.Validate("Validate VAT Return Url", ValidateVATReturnUrlLbl);
        ElecVATSetup.Validate("Exchange ID-Porten Token Url", ExchangeIDPortenToAltinnUrlLbl);
        ElecVATSetup.Validate("Submission Environment URL", SubmissionEnvironmentUrlLbl);
        ElecVATSetup.Validate("Submission App URL", SubmissionAppUrlLbl);
        ElecVATSetup.Modify(true);
    end;

    local procedure UpdateVATReportSetup()
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        if not VATReportSetup.Get() then
            exit;
        VATReportSetup.Validate("Report VAT Base", true);
        VATReportSetup.Validate("Report VAT Note", true);
        VATReportSetup.Modify(true);
    end;

    local procedure CreateVATReportsConfiguration()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        NOVATReportTok: Label 'NO VAT Reporting', Locked = true;
    begin
        FeatureTelemetry.LogUptake('0000HTK', NOVATReportTok, Enum::"Feature Uptake Status"::"Set up");
        if VATReportsConfiguration.Get(VATReportsConfiguration."VAT Report Type"::"VAT Return", ElectronicVATLbl) then
            exit;
        VATReportsConfiguration.Validate("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"VAT Return");
        VATReportsConfiguration.validate("VAT Report Version", ElectronicVATLbl);
        VATReportsConfiguration.Validate("Suggest Lines Codeunit ID", Codeunit::"VAT Report Suggest Lines");
        VATReportsConfiguration.Validate("Content Codeunit ID", Codeunit::"Elec. VAT Create Content");
        VATReportsConfiguration.Validate("Submission Codeunit ID", Codeunit::"Elec. VAT Submit Return");
        VATReportsConfiguration.Validate("Validate Codeunit ID", Codeunit::"Elec. VAT Validate Return");
        VATReportsConfiguration.Validate("Response Handler Codeunit ID", Codeunit::"Elec. VAT Get Response");
        VATReportsConfiguration.Insert(true);
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        VATCode: Record "VAT Code";
        OAuth20Setup: Record "OAuth 2.0 Setup";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Elec. VAT Setup");
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Code", VATCode.FieldNo("VAT Rate For Reporting"));
        DataClassificationMgt.SetFieldToNormal(Database::"VAT Code", VATCode.FieldNo("Report VAT Rate"));
        DataClassificationMgt.SetFieldToNormal(Database::"OAuth 2.0 Setup", OAuth20Setup.FieldNo("Altinn Token"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure InsertIntoAssistedSetup()
    var
        ElecVATSetup: Record "Elec. VAT Setup";
        GuidedExperience: Codeunit "Guided Experience";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
    begin
        GuidedExperience.InsertAssistedSetup(AssistedSetupTxt, CopyStr(AssistedSetupTxt, 1, 50), AssistedSetupDescriptionTxt, 5, ObjectType::Page, Page::"Elec. VAT Submission Wizard", AssistedSetupGroup::Connect,
                                            '', VideoCategory::ReadyForBusiness, AssistedSetupHelpTxt);
        if ElecVATSetup.Get() and ElecVATSetup.Enabled then
            GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Elec. VAT Submission Wizard");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnAfterRunAssistedSetup', '', true, true)]
    local procedure UpdateAssistedSetupStatus(ExtensionID: Guid; ObjectType: ObjectType; ObjectID: Integer)
    var
        ElecVATSetup: Record "Elec. VAT Setup";
        GuidedExperience: Codeunit "Guided Experience";
        BaseAppID: Codeunit "BaseApp ID";
    begin
        if ExtensionId <> BaseAppID.Get() then
            exit;
        if ObjectID <> Page::"Elec. VAT Submission Wizard" then
            exit;
        if ElecVATSetup.Get() and ElecVATSetup.Enabled then
            GuidedExperience.CompleteAssistedSetup(ObjectType, ObjectID);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', true, true)]
    local procedure InsertIntoManualSetupOnRegisterManualSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.InsertManualSetup(ElectronicVATSetupTitleTxt, ElectronicVATSetupShortTitleTxt, ElectronicVATSetupDescriptionTxt, 5, ObjectType::Page, Page::"Electronic VAT Setup Card", "Manual Setup Category"::Finance, '', true);
    end;
}
