// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

using System.Telemetry;
using System.Globalization;

/// <summary>
/// Table to keep track of each Copilot Capability settings.
/// </summary>
table 7775 "Copilot Settings"
{
    Access = Internal;
    DataPerCompany = false;
    InherentEntitlements = rimdX;
    InherentPermissions = rimdX;
    ReplicateData = false;

    fields
    {
        field(1; Capability; Enum "Copilot Capability")
        {
            DataClassification = SystemMetadata;
        }
        field(2; "App Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(3; Availability; Enum "Copilot Availability")
        {
            DataClassification = SystemMetadata;
        }
        field(4; Publisher; Text[2048])
        {
            DataClassification = SystemMetadata;
        }
        field(5; Status; Enum "Copilot Status")
        {
            DataClassification = SystemMetadata;
            InitValue = Active;
        }
        field(6; "Learn More Url"; Text[2048])
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Capability, "App Id")
        {
            Clustered = true;
        }
    }

    trigger OnModify()
    var
        CopilotCapabilityImpl: Codeunit "Copilot Capability Impl";
        Language: Codeunit Language;
        SavedGlobalLanguageId: Integer;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        SavedGlobalLanguageId := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());

        CustomDimensions.Add('Category', CopilotCapabilityImpl.GetCopilotCategory());
        CustomDimensions.Add('Capability', Format(Rec.Capability));
        CustomDimensions.Add('AppId', Format(Rec."App Id"));
        CustomDimensions.Add('Enabled', Format(Rec.Status));
        FeatureTelemetry.LogUsage('0000LE0', CopilotCapabilityImpl.GetCopilotCategory(), CopilotCapabilityModifiedLbl, CustomDimensions);

        GlobalLanguage(SavedGlobalLanguageId);
    end;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CopilotCapabilityModifiedLbl: Label 'Copilot capability has been modified.', Locked = true;

}