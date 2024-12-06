﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;
using System.Telemetry;

table 6381 "OneDrive Setup"
{
    ReplicateData = false;
    DataClassification = CustomerContent;
    Caption = 'OneDrive Document Import Setup';
    InherentPermissions = X;
    InherentEntitlements = X;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                FeatureTelemetry: Codeunit "Feature Telemetry";
                DriveProcessing: Codeunit "Drive Processing";
            begin
                if Rec.Enabled then begin
                    if (Rec."Imp. Documents Folder" = '') or (Rec."Documents Folder" = '') then
                        Error(URLsMustBeSpecifiedErr);
                    FeatureTelemetry.LogUptake('0000OB9', DriveProcessing.FeatureName(), Enum::"Feature Uptake Status"::Used);
                    FeatureTelemetry.LogUsage('0000OBA', DriveProcessing.FeatureName(), 'OneDrive');
                end;
            end;
        }
        field(3; "Documents Folder"; Text[2048])
        {
            Caption = 'Documents Folder';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                DriveProcessing: Codeunit "Drive Processing";
            begin
                if Rec."Documents Folder" <> '' then
                    Rec.SiteId := CopyStr(DriveProcessing.GetSiteId(Rec."Documents Folder"), 1, MaxStrLen(Rec.SiteId))
                else
                    Rec.SiteId := '';
            end;
        }
        field(4; "Imp. Documents Folder"; Text[2048])
        {
            Caption = 'Imported Documents Folder';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                DriveProcessing: Codeunit "Drive Processing";
            begin
                if Rec."Imp. Documents Folder" <> '' then
                    Rec."Imp. Documents Folder Id" := CopyStr(DriveProcessing.GetId(Rec."Imp. Documents Folder"), 1, MaxStrLen(Rec."Imp. Documents Folder Id"))
                else
                    Rec."Imp. Documents Folder Id" := '';
            end;
        }
        field(5; "SiteId"; Text[2048])
        {
            Caption = 'Site Id';
            DataClassification = CustomerContent;
        }
        field(6; "Imp. Documents Folder Id"; Text[2048])
        {
            Caption = 'Imported Documents Folder Id';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        URLsMustBeSpecifiedErr: label 'You must specify the URL to the folder that contains documents to be imported and the URL to the folder to which the imported documents will be moved.';
}

