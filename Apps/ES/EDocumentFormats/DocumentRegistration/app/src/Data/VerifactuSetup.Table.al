// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu;

using Microsoft.EServices.EDocument;
using System.Privacy;
using System.Security.Encryption;
using System.Utilities;

table 10777 "Verifactu Setup"
{
    Caption = 'Verifactu Setup';
    LookupPageID = "Verifactu Setup";
    DataClassification = CustomerContent;
    InherentPermissions = X;
    AllowInCustomizations = Never;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; Enabled; Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            var
                SIISetup: Record "SII Setup";
                CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
                ConfirmMgt: Codeunit "Confirm Management";
                VerifactuSetupConsentProvidedLbl: Label 'Verifactu Setup - consent provided by UserSecurityId %1.', Locked = true;
            begin
                if Enabled and ("Certificate Code" = '') then
                    Error(CannotEnableWithoutCertificateErr);
                if Enabled then begin
                    if SIISetup.IsEnabled() then
                        if ConfirmMgt.GetResponseOrDefault(DisableSIIQst, false) then begin
                            SIISetup.Enabled := false;
                            SIISetup.Modify(true);
                        end else begin
                            Enabled := false;
                            exit;
                        end;
                    Enabled := CustomerConsentMgt.ConfirmUserConsent();
                end;
                if Enabled then begin
                    Session.LogSecurityAudit(Rec.TableName(), SecurityOperationResult::Success, SecurityAuditLogSetupStatusDescription(Rec.FieldName(Enabled), Rec.TableName()), AuditCategory::CustomerFacing);
                    Session.LogAuditMessage(StrSubstNo(VerifactuSetupConsentProvidedLbl, UserSecurityId()), SecurityOperationResult::Success, AuditCategory::ApplicationManagement, 4, 0);
                end else
                    Session.LogSecurityAudit(Rec.TableName(), SecurityOperationResult::Success, SecurityAuditLogSetupStatusDescription(NotEnabledTxt, Rec.TableName()), AuditCategory::CustomerFacing);
            end;
        }
        field(12; "Show Advanced Actions"; Boolean)
        {
            Caption = 'Show Advanced Actions';
        }
        field(20; "Invoice Amount Threshold"; Decimal)
        {
            Caption = 'Invoice Amount Threshold';
            InitValue = 100000000;
            MinValue = 0;
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
        field(21; "Do Not Export Negative Lines"; Boolean)
        {
            Caption = 'Do Not Export Negative Lines';
        }
        field(30; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
        }
        field(42; "Certificate Code"; Code[20])
        {
            TableRelation = "Isolated Certificate";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Validate(Enabled, "Certificate Code" <> '');
            end;

            trigger OnLookup()
            var
                DocRegistrationCertMgt: Codeunit "Doc. Registration Cert. Mgt.";
            begin
                DocRegistrationCertMgt.LookupCertificate(Rec."Certificate Code");
            end;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Starting Date" := WorkDate();
    end;

    var
        UrlHelper: Codeunit "Url Helper";
        CannotEnableWithoutCertificateErr: Label 'The setup cannot be enabled without a valid certificate.';
        DisableSIIQst: Label 'SII setup will be disabled. Do you want to proceed?';
        DocumentSubmissionEndpointUrlTxt: Label 'https://www1.agenciatributaria.gob.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP', Locked = true;
        QRCodeValidationEndpointUrlTxt: Label 'https://www2.agenciatributaria.gob.es/wlpl/TIKE-CONT/ValidarQR', Locked = true;
        DocumentSubmissionSandboxEndpointUrlTxt: Label 'https://prewww1.aeat.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP', Locked = true;
        QRCodeValidationSandboxEndpointUrlTxt: Label 'https://prewww2.aeat.es/wlpl/TIKE-CONT/ValidarQR', Locked = true;
        NotEnabledTxt: Label 'Not enabled', Locked = true;

    procedure IsEnabled(): Boolean
    begin
        if not Get() then
            exit(false);
        exit(Enabled);
    end;

    internal procedure GetQRCodeValidationEndpointUrl(): Text
    begin
        if UrlHelper.IsPPE() then
            exit(QRCodeValidationSandboxEndpointUrlTxt);

        exit(QRCodeValidationEndpointUrlTxt);
    end;

    internal procedure GetDocumentSubmissionEndpointUrl(): Text
    begin
        if UrlHelper.IsPPE() then
            exit(DocumentSubmissionSandboxEndpointUrlTxt);

        exit(DocumentSubmissionEndpointUrlTxt);
    end;

    local procedure SecurityAuditLogSetupStatusDescription(Action: Text; SetupTableName: Text): Text
    begin
        exit(Action + ' ' + SetupTableName);
    end;

}