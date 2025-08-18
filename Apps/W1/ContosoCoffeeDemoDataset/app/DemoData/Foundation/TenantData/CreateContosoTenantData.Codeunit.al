// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using System.Environment.Configuration;
using System.Reflection;
using Microsoft.Integration.Graph;
using Microsoft.DemoTool;
using System.Utilities;

codeunit 5691 "Create Contoso Tenant Data"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    EventSubscriberInstance = Manual;
    Description = 'Populate App Database, only run in the gate after generating Contoso Demo Data.';

    trigger OnRun()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        CreateProfiles();
        Codeunit.Run(Codeunit::"Create Contoso Permissions");
        Codeunit.Run(Codeunit::"Create Media Repository");
        Codeunit.Run(Codeunit::"Create Web Services");
        SetupAPIs();
        SetupApplicationArea();
        SetCountry();

        SetDefaultRoleCenter();
        SetExperienceTierToEssential();

        OnAfterCreateTenantData();
        EnableNewFeatures();

        if ApplicationAreaMgmtFacade.IsPremiumExperienceEnabled() then
            ApplicationAreaSetup.DeleteAll(true);
    end;

    local procedure CreateProfiles()
    var
        AllProfile: Record "All Profile";
    begin
        // Set Default Profile
        AllProfile.SetRange("Default Role Center", true);

        // Do not overwrite the default role center ID if one already exists
        // (Since these tables are not company specific)
        if AllProfile.IsEmpty() then begin
            Clear(AllProfile);
            AllProfile.SetRange("Role Center ID", 0);
            if AllProfile.FindFirst() then begin
                AllProfile."Default Role Center" := true;
                AllProfile.Modify();
            end;
        end;
    end;

    local procedure SetupApplicationArea()
    var
        ExperienceTierSetup: Record "Experience Tier Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(ExperienceTierSetup.FieldCaption(Essential));
    end;

    local procedure SetupAPIs()
    var
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
    begin
        BindSubscription(this);
        GraphMgtGeneralTools.ApiSetup();
        UnbindSubscription(this);
    end;

    local procedure SetCountry()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        MediaResourcesMgt: Codeunit "Media Resources Mgt.";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        MediaResourcesMgt.InsertBlobFromText('ApplicationCountry', ContosoCoffeeDemoDataSetup."Country/Region Code");
    end;

    local procedure SetDefaultRoleCenter()
    var
        AllProfile: Record "All Profile";
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        AllProfile.SetFilter("Role Center ID", '=%1', ConfPersonalizationMgt.DefaultRoleCenterID());
        AllProfile.SetRange("Scope", AllProfile.Scope::Tenant);
        AllProfile.FindFirst();
        ConfPersonalizationMgt.ChangeDefaultRoleCenter(AllProfile);
    end;

    local procedure SetExperienceTierToEssential()
    var
        ExperienceTierSetup: Record "Experience Tier Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    begin
        ApplicationAreaMgmtFacade.SaveExperienceTierCurrentCompany(ExperienceTierSetup.FieldCaption(Essential));
    end;

    local procedure EnableNewFeatures()
    var
        FeatureKey: Record "Feature Key";
    begin
        // Virtual table does not support ModifyAll
        FeatureKey.SetRange("Is One Way", false); // only enable features that can be disabled
        if FeatureKey.FindSet(true) then
            repeat
                if not ExcludeNewFeature(FeatureKey) then begin
                    FeatureKey.Enabled := FeatureKey.Enabled::"All Users";
                    FeatureKey.Modify();
                end;
            until FeatureKey.Next() = 0;
    end;

    local procedure ExcludeNewFeature(FeatureKey: Record "Feature Key"): Boolean
    begin
        if FeatureKey.ID in ['PowerAutomateCopilot',
                             'CalcOnlyVisibleFlowFields',
                             'SemanticMetadataSearch',
                             'AdvancedTellMe']
        then
            exit(true);

        exit(false)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Graph Mgt - General Tools", 'OnGetIsAPIEnabled', '', false, false)]
    local procedure GetIsAPIEnabled(var Handled: Boolean; var IsAPIEnabled: Boolean)
    begin
        Handled := true;
        IsAPIEnabled := true;
    end;

    [Scope('OnPrem')]
    [IntegrationEvent(false, false)]
    procedure OnAfterCreateTenantData()
    begin
    end;
}
