// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using System.Telemetry;
using Microsoft.eServices.EDocument;
using System.Email;
using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Processing.Import;

table 6383 "Outlook Setup"
{
    Caption = 'Outlook Document Import Setup';
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
                EDocumentService: Record "E-Document Service";
                FeatureTelemetry: Codeunit "Feature Telemetry";
                OutlookProcessing: Codeunit "Outlook Processing";
                DriveIntegrationImpl: Codeunit "Drive Integration Impl.";
            begin
                if Rec.Enabled then begin
                    if IsNullGuid(Rec."Email Account ID") then
                        Error(MailboxMustBeSpecifiedErr);

                    "Enabled At" := CurrentDateTime();

                    FeatureTelemetry.LogUptake('0000OGZ', OutlookProcessing.FeatureName(), Enum::"Feature Uptake Status"::Used);
                    FeatureTelemetry.LogUsage('0000OH0', OutlookProcessing.FeatureName(), 'Outlook');
                    Session.LogSecurityAudit(Rec.TableName(), SecurityOperationResult::Success, DriveIntegrationImpl.SecurityAuditLogSetupStatusDescription(Rec.FieldName(Enabled), Rec.TableName()), AuditCategory::CustomerFacing);
                end else
                    Session.LogSecurityAudit(Rec.TableName(), SecurityOperationResult::Success, DriveIntegrationImpl.SecurityAuditLogSetupStatusDescription('Disabled', Rec.TableName()), AuditCategory::CustomerFacing);
                EDocumentService.SetRange("Service Integration V2", "Service Integration"::Outlook);
                EDocumentService.ModifyAll("Import Process", "E-Document Import Process"::"Version 2.0");
            end;
        }
        field(3; "Email Account ID"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Email Connector"; Enum "Email Connector")
        {
            DataClassification = SystemMetadata;
        }
        field(16; "Enabled At"; DateTime)
        {
            Caption = 'Enabled At';
            ToolTip = 'Specifies the date and time the setup was enabled.';
            DataClassification = SystemMetadata;
        }
        field(18; "Last Sync At"; DateTime)
        {
            Caption = 'Last Sync At';
            ToolTip = 'Specifies the date and time the emails were processed last time.';
            DataClassification = SystemMetadata;
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
        MailboxMustBeSpecifiedErr: label 'You must specify the e-mail address of the shared mailbox in which you receive e-mails with document attachments.';
}

