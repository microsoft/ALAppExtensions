// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using System.Upgrade;
using Microsoft.Integration.SyncEngine;
using System.Environment.Configuration;

codeunit 6616 "FS Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        UpgradeConnectionSetup();
        UpgradeIntegrationTableMappings();
        UpgradeAssistedSetup();
    end;

    local procedure UpgradeConnectionSetup()
    var
        FSConnectionSetupOld: Record Microsoft.Integration.FieldService."FS Connection Setup";
        FSConnectionSetupNew: Record "FS Connection Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetConnectionSetupUpgradeTag()) then
            exit;

        if FSConnectionSetupOld.FindFirst() then begin
            FSConnectionSetupNew.Init();
            FSConnectionSetupNew.TransferFields(FSConnectionSetupOld);
            FSConnectionSetupNew.Insert();
            FSConnectionSetupOld."Is Enabled" := false;
            FSConnectionSetupOld.Modify();
        end;

        UpgradeTag.SetUpgradeTag(GetConnectionSetupUpgradeTag());
    end;

    local procedure UpgradeIntegrationTableMappings()
    var
        IntegrationTableMapping: Record "Integration Table Mapping";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetIntegrationTableMappingsUpgradeTag()) then
            exit;

        IntegrationTableMapping.SetRange("Integration Table ID", Database::Microsoft.Integration.FieldService."FS Bookable Resource");
        IntegrationTableMapping.ModifyAll("Integration Table ID", Database::"FS Bookable Resource");

        IntegrationTableMapping.SetRange("Integration Table ID", Database::Microsoft.Integration.FieldService."FS Bookable Resource Booking");
        IntegrationTableMapping.ModifyAll("Integration Table ID", Database::"FS Bookable Resource Booking");

        IntegrationTableMapping.SetRange("Integration Table ID", Database::Microsoft.Integration.FieldService."FS BookableResourceBookingHdr");
        IntegrationTableMapping.ModifyAll("Integration Table ID", Database::"FS BookableResourceBookingHdr");

        IntegrationTableMapping.SetRange("Integration Table ID", Database::Microsoft.Integration.FieldService."FS Customer Asset");
        IntegrationTableMapping.ModifyAll("Integration Table ID", Database::"FS Customer Asset");

        IntegrationTableMapping.SetRange("Integration Table ID", Database::Microsoft.Integration.FieldService."FS Customer Asset Category");
        IntegrationTableMapping.ModifyAll("Integration Table ID", Database::"FS Customer Asset Category");

        IntegrationTableMapping.SetRange("Integration Table ID", Database::Microsoft.Integration.FieldService."FS Project Task");
        IntegrationTableMapping.ModifyAll("Integration Table ID", Database::"FS Project Task");

        IntegrationTableMapping.SetRange("Integration Table ID", Database::Microsoft.Integration.FieldService."FS Resource Pay Type");
        IntegrationTableMapping.ModifyAll("Integration Table ID", Database::"FS Resource Pay Type");

        IntegrationTableMapping.SetRange("Integration Table ID", Database::Microsoft.Integration.FieldService."FS Work Order");
        IntegrationTableMapping.ModifyAll("Integration Table ID", Database::"FS Work Order");

        IntegrationTableMapping.SetRange("Integration Table ID", Database::Microsoft.Integration.FieldService."FS Work Order Incident");
        IntegrationTableMapping.ModifyAll("Integration Table ID", Database::"FS Work Order Incident");

        IntegrationTableMapping.SetRange("Integration Table ID", Database::Microsoft.Integration.FieldService."FS Work Order Product");
        IntegrationTableMapping.ModifyAll("Integration Table ID", Database::"FS Work Order Product");

        IntegrationTableMapping.SetRange("Integration Table ID", Database::Microsoft.Integration.FieldService."FS Work Order Service");
        IntegrationTableMapping.ModifyAll("Integration Table ID", Database::"FS Work Order Service");

        IntegrationTableMapping.SetRange("Integration Table ID", Database::Microsoft.Integration.FieldService."FS Work Order Substatus");
        IntegrationTableMapping.ModifyAll("Integration Table ID", Database::"FS Work Order Substatus");

        IntegrationTableMapping.SetRange("Integration Table ID", Database::Microsoft.Integration.FieldService."FS Work Order Type");
        IntegrationTableMapping.ModifyAll("Integration Table ID", Database::"FS Work Order Type");

        UpgradeTag.SetUpgradeTag(GetIntegrationTableMappingsUpgradeTag());
    end;

    local procedure UpgradeAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetAssistedSetupUpgradeTag()) then
            exit;

#if not CLEAN25
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::Microsoft.Integration.FieldService."FS Connection Setup Wizard");
#else
        GuidedExperience.Remove("Guided Experience Type"::"Assisted Setup", ObjectType::Page, 6421); // 6421 is the ID of the FS Connection Setup Wizard page in Base Application
#endif

        UpgradeTag.SetUpgradeTag(GetAssistedSetupUpgradeTag());
    end;

    local procedure GetConnectionSetupUpgradeTag(): Code[250]
    begin
        exit('MS-527221-ConnectionSetupUpgradeTag-20240510');
    end;

    local procedure GetIntegrationTableMappingsUpgradeTag(): Code[250]
    begin
        exit('MS-527221-IntegrationTableMappingsUpgradeTag-20240510');
    end;

    local procedure GetAssistedSetupUpgradeTag(): Code[250]
    begin
        exit('MS-527221-AssistedSetupUpgradeTag-20240510');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetConnectionSetupUpgradeTag());
        PerCompanyUpgradeTags.Add(GetIntegrationTableMappingsUpgradeTag());
        PerCompanyUpgradeTags.Add(GetAssistedSetupUpgradeTag());
    end;
}