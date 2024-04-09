// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.GeneralLedger.Setup;
#if not CLEAN22
using System.Environment;
using System.Environment.Configuration;
#endif

codeunit 5316 "SIE Management"
{
    var
        AuditFileNameSIETxt: label 'SIE.se', Locked = true;
#if not CLEAN22
        FeatureNotEnabledMsg: label 'The %1 page is part of the new SIE feature, which is not enabled yet in your Business Central. An administrator can enable the feature on the Feature Management page.', Comment = '%1 - page caption';
#endif

    procedure GetStandardAccountsCSVDocSIE(StandardAccountType: enum "Standard Account Type") CSVDocContent: Text
    var
        StandardAccountSIE: Codeunit "Standard Account SIE";
    begin
        if StandardAccountType = Enum::"Standard Account Type"::"Four Digit Standard Account (SRU)" then
            CSVDocContent := StandardAccountSIE.GetStandardAccountsCSV();
    end;

    procedure GetAuditFileName(): Text[1024]
    begin
        exit(AuditFileNameSIETxt);
    end;

    local procedure UpdateDimensionSIE(ShortCutDimNo: Integer; OldDimensionCode: Code[20]; NewDimensionCode: Code[20])
    var
        DimensionSIE: Record "Dimension SIE";
    begin
        if OldDimensionCode = NewDimensionCode then
            exit;

        if OldDimensionCode <> '' then begin
            DimensionSIE.SetRange("Dimension Code", OldDimensionCode);
            if DimensionSIE.FindFirst() then begin
                DimensionSIE.ShortCutDimNo := 0;
                DimensionSIE.Modify();
            end;
        end;
        if NewDimensionCode <> '' then begin
            DimensionSIE.SetRange("Dimension Code", NewDimensionCode);
            if DimensionSIE.FindFirst() then begin
                DimensionSIE.ShortCutDimNo := ShortCutDimNo;
                DimensionSIE.Modify();
            end;
        end;
    end;

    procedure SIEFormatSetupExists(): Boolean
    var
        AuditFileExportFormatSetup: Record "Audit File Export Format Setup";
    begin
        exit(AuditFileExportFormatSetup.Get(Enum::"Audit File Export Format"::SIE));
    end;

#if not CLEAN22
#pragma warning disable AS0072
    [Obsolete('Feature will be enabled by default.', '22.0')]
    procedure IsFeatureEnabled() IsEnabled: Boolean
    var
        FeatureMgtFacade: Codeunit "Feature Management Facade";
    begin
        IsEnabled := FeatureMgtFacade.IsEnabled(GetSIEAuditFileExportFeatureKeyId());
        OnAfterCheckFeatureEnabled(IsEnabled);
    end;

    [Obsolete('Feature will be enabled by default.', '22.0')]
    procedure GetSIEAuditFileExportFeatureKeyId(): Text[50]
    begin
        exit('SIEAuditFileExport');
    end;

    [Obsolete('Feature will be enabled by default.', '22.0')]
    procedure ShowNotEnabledMessage(PageCaption: Text)
    begin
        Message(FeatureNotEnabledMsg, PageCaption);
    end;

    [Obsolete('Feature will be enabled by default.', '22.0')]
    local procedure UpgradeDimensionSIE()
    var
        Company: Record Company;
        SIEDimensionOld: Record "SIE Dimension";
        DimensionSIENew: Record "Dimension SIE";
    begin
        if Company.FindSet() then
            repeat
                SIEDimensionOld.ChangeCompany(Company.Name);
                DimensionSIENew.ChangeCompany(Company.Name);

                DimensionSIENew.DeleteAll();
                if SIEDimensionOld.FindSet() then
                    repeat
                        DimensionSIENew.TransferFields(SIEDimensionOld);
                        DimensionSIENew.Insert();
                    until SIEDimensionOld.Next() = 0;
            until Company.Next() = 0;
    end;

    [Obsolete('Feature will be enabled by default.', '22.0')]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnAfterFeatureEnableConfirmed', '', true, true)]
    local procedure OnAfterFeatureEnableConfirmed(var FeatureKey: Record "Feature Key")
    var
        SIESetupWizard: Page "SIE Setup Wizard";
    begin
        if FeatureKey.ID = GetSIEAuditFileExportFeatureKeyId() then begin
            UpgradeDimensionSIE();
            Commit();
            SIESetupWizard.SetRunFromFeatureMgt();
            if SIESetupWizard.RunModal() = Action::OK then
                if not SIESetupWizard.IsSetupCompleted() then
                    Error('');
        end;
    end;

    [Obsolete('Feature will be enabled by default.', '22.0')]
    [IntegrationEvent(true, false)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
    end;
#pragma warning restore AS0072
#endif

    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnAfterUpdateDimValueGlobalDimNo', '', true, true)]
    local procedure UpdateSIEDimensionOnAfterUpdateDimValueGlobalDimNo(ShortCutDimNo: Integer; OldDimensionCode: Code[20]; NewDimensionCode: Code[20])
    begin
        UpdateDimensionSIE(ShortcutDimNo, OldDimensionCode, NewDimensionCode);
    end;
}
