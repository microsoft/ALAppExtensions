// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using System.Telemetry;

table 6382 "Sharepoint Setup"
{
    Caption = 'Sharepoint Document Import Setup';
    ReplicateData = false;
    DataClassification = CustomerContent;
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
                DriveIntegrationImpl: Codeunit "Drive Integration Impl.";
            begin
                if Rec.Enabled then begin
                    if (Rec."Imp. Documents Folder" = '') or (Rec."Documents Folder" = '') then
                        Error(URLsMustBeSpecifiedErr);

                    FeatureTelemetry.LogUptake('0000OBB', DriveProcessing.FeatureName(), Enum::"Feature Uptake Status"::Used);
                    FeatureTelemetry.LogUsage('0000OBC', DriveProcessing.FeatureName(), 'Sharepoint');
                    Session.LogSecurityAudit(Rec.TableName(), SecurityOperationResult::Success, DriveIntegrationImpl.SecurityAuditLogSetupStatusDescription(Rec.FieldName(Enabled), Rec.TableName()), AuditCategory::CustomerFacing);
                end else
                    Session.LogSecurityAudit(Rec.TableName(), SecurityOperationResult::Success, DriveIntegrationImpl.SecurityAuditLogSetupStatusDescription('Disabled', Rec.TableName()), AuditCategory::CustomerFacing);
            end;
        }
        field(3; "Documents Folder"; Text[2048])
        {
            Caption = 'Document Folder';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                DriveProcessing: Codeunit "Drive Processing";
            begin
                if Rec."Documents Folder" <> '' then begin
                    Rec.SiteId := CopyStr(DriveProcessing.GetSiteId(Rec."Documents Folder"), 1, MaxStrLen(Rec.SiteId));
                    Rec."Documents Folder Name" := CopyStr(DriveProcessing.GetName(Rec."Documents Folder"), 1, MaxStrLen(Rec."Documents Folder Name"))
                end else begin
                    Rec.SiteId := '';
                    Rec."Documents Folder Name" := ''
                end;
            end;
        }
        field(4; "Imp. Documents Folder"; Text[2048])
        {
            Caption = 'Archive Folder';
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
        field(7; "Documents Folder Name"; Text[2048])
        {
            Caption = 'Documents Folder Name';
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

