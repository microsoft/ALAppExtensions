// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using System.Telemetry;
using System.Utilities;
using System.Email;

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
                FeatureTelemetry: Codeunit "Feature Telemetry";
                OutlookProcessing: Codeunit "Outlook Processing";
                DriveIntegrationImpl: Codeunit "Drive Integration Impl.";
                ConfirmManagement: Codeunit "Confirm Management";
            begin
                if Rec.Enabled then begin
                    if IsNullGuid(Rec."Email Account ID") then
                        Error(MailboxMustBeSpecifiedErr);

                    "Enabled At" := CurrentDateTime();
                    if "Last Sync At" = 0DT then
                        "Last Sync At" := "Enabled At"
                    else
                        if not ConfirmManagement.GetResponseOrDefault(KeepLastSyncAtQst, true) then
                            "Last Sync At" := "Enabled At";

                    FeatureTelemetry.LogUptake('0000OGZ', OutlookProcessing.FeatureName(), Enum::"Feature Uptake Status"::Used);
                    FeatureTelemetry.LogUsage('0000OH0', OutlookProcessing.FeatureName(), 'Outlook');
                    Session.LogSecurityAudit(Rec.TableName(), SecurityOperationResult::Success, DriveIntegrationImpl.SecurityAuditLogSetupStatusDescription(Rec.FieldName(Enabled), Rec.TableName()), AuditCategory::CustomerFacing);
                end else
                    Session.LogSecurityAudit(Rec.TableName(), SecurityOperationResult::Success, DriveIntegrationImpl.SecurityAuditLogSetupStatusDescription('Disabled', Rec.TableName()), AuditCategory::CustomerFacing);
            end;
        }
        field(3; "Email Account ID"; Guid)
        {
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if xRec."Email Account ID" <> Rec."Email Account ID" then
                    "Last Sync At" := 0DT;
            end;
        }
        field(4; "Email Connector"; Enum "Email Connector")
        {
            DataClassification = SystemMetadata;
        }
        field(5; "Consent Received"; Boolean)
        {
            Caption = 'Consent Received';
            ToolTip = 'Specifies whether the customer has given consent to the privacy notice.';
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
        KeepLastSyncAtQst: label 'New e-mails may have arrived during the time while monitoring this mailbox was disabled. Do you want to process those e-mails as well?';
}

