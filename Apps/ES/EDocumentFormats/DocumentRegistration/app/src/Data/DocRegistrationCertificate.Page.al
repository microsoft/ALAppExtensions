// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu;
using System.Security.Encryption;
using System.Utilities;

page 10778 "Doc. Registration Certificate"
{
    Caption = 'Certificate';
    PageType = Card;
    SourceTable = "Isolated Certificate";
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the name of the certificate.';
                }
                group(Control16)
                {
                    ShowCaption = false;
                    Visible = IsPasswordRequired;
                    field(Password; CertPassword)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the password for the certificate.';
                        Caption = 'Password';

                        trigger OnValidate()
                        begin
                            PasswordNotification.Recall();
                            DocRegistrationCertMgt.SetCertPassword(CertPassword);
                            if DocRegistrationCertMgt.VerifyCert(Rec) then begin
                                if Rec.IsCertificateExpired() then
                                    HandleExpiredCert()
                                else begin
                                    IsShowCertInfo := true;
                                    IsUploadedCertValid := not IsNewRecord;
                                end;

                                CurrPage.Update();
                            end else
                                Error(CertWrongPasswordErr);
                        end;
                    }
                }
                field(Scope; Rec.Scope)
                {
                    ApplicationArea = Basic, Suite;
                    Editable = IsNewRecord;
                    ToolTip = 'Specifies the availability of the certificate. Company gives all users in this specific company access to the certificate. User gives access to a specific user in any company. Company and User gives access to a specific user in the specific company.';
                }
            }
            group("Certificate Information")
            {
                Caption = 'Certificate Information';
                Visible = IsShowCertInfo;
                field("Has Private Key"; Rec."Has Private Key")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the certificate has a private key.';
                }
                field(ThumbPrint; Rec.ThumbPrint)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Thumbprint';
                    ToolTip = 'Specifies the certificate thumbprint.';
                }
                field("Expiry Date"; Rec."Expiry Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which the certificate will expire.';
                }
                field("Issued By"; Rec."Issued By")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the certificate authority that issued the certificate.';
                }
                field("Issued To"; Rec."Issued To")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the person, organization, or domain that the certificate was issued to.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Upload Certificate")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Upload a new certificate file for the certificate. Typically, you use this when a certificate will expire soon.';
                Caption = 'Upload Certificate';
                Image = Import;

                trigger OnAction()
                begin
                    RecallNotifications();
                    IsolatedCertificate := Rec;
                    CertPassword := '';
                    DocRegistrationCertMgt.SetCertPassword(CertPassword);

                    CheckEncryption();

                    if not DocRegistrationCertMgt.UploadAndVerifyCert(Rec) then begin
                        IsShowCertInfo := false;
                        HandleRequirePassword();
                    end else begin
                        IsPasswordRequired := false;
                        IsShowCertInfo := true;
                        if Rec.IsCertificateExpired() then begin
                            HandleExpiredCert();

                            Rec := IsolatedCertificate;
                            if Rec.ThumbPrint = '' then
                                IsShowCertInfo := false;
                        end;
                    end;

                    CurrPage.Update();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Upload Certificate_Promoted"; "Upload Certificate")
                {
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec := IsolatedCertificate;
    end;

    trigger OnOpenPage()
    begin
        if Rec.Code = '' then begin
            IsNewRecord := true;
            CheckEncryption();
            if not DocRegistrationCertMgt.UploadAndVerifyCert(Rec) then
                HandleRequirePassword()
            else begin
                IsShowCertInfo := true;
                if Rec.IsCertificateExpired() then
                    HandleExpiredCert();
            end;

            IsolatedCertificate := Rec;
        end else
            if Rec.ThumbPrint <> '' then begin
                IsShowCertInfo := true;
                if Rec.IsCertificateExpired() then
                    NotfiyExpiredCert(CertHasExpiredMsg);
            end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if Rec.Code <> '' then
            Rec.TestField(Name);

        if IsNewRecord then
            Rec.SetScope();

        if (IsNewRecord or IsUploadedCertValid) and not IsExpired then
            SaveCertToIsolatedStorage();
    end;

    var
        IsolatedCertificate: Record "Isolated Certificate";
        CertificateManagement: Codeunit "Certificate Management";
        DocRegistrationCertMgt: Codeunit "Doc. Registration Cert. Mgt.";
        PasswordNotification: Notification;
        ExpiredNotification: Notification;
        IsNewRecord: Boolean;
        CertWrongPasswordErr: Label 'The password is not correct.';
        PasswordNotificationMsg: Label 'You must enter the password for this certificate.';
        ExpiredNewCertMsg: Label 'You cannot upload the certificate%1 because it is past its expiration date.', Comment = '%1=file name, e.g. Certfile.pfx';
        IsPasswordRequired: Boolean;
        CertHasExpiredMsg: Label 'The certificate has expired. To use the certificate you must upload a new certificate file.';
        IsExpired: Boolean;
        IsUploadedCertValid: Boolean;
        IsShowCertInfo: Boolean;
        [NonDebuggable]
        CertPassword: Text;

    local procedure ClearCertInfoFields()
    begin
        Clear(Rec."Expiry Date");
        Rec.ThumbPrint := '';
        Rec."Issued By" := '';
        Rec."Issued To" := '';
        Rec."Has Private Key" := false;
    end;

    local procedure SaveCertToIsolatedStorage()
    begin
        if IsUploadedCertValid then
            DocRegistrationCertMgt.DeleteCertAndPasswordFromIsolatedStorage(Rec);
        DocRegistrationCertMgt.SaveCertToIsolatedStorage(Rec);

        DocRegistrationCertMgt.SetCertPassword(CertPassword);
        DocRegistrationCertMgt.SavePasswordToIsolatedStorage(Rec);
    end;

    local procedure HandleRequirePassword()
    begin
        IsPasswordRequired := true;
        PasswordNotification.Message(PasswordNotificationMsg);
        PasswordNotification.Send();
    end;

    local procedure HandleExpiredCert()
    begin
        NotfiyExpiredCert(StrSubstNo(ExpiredNewCertMsg, ' ' + CertificateManagement.GetUploadedCertFileName()));
        if IsNewRecord then
            ClearCertInfoFields()
        else
            Rec := IsolatedCertificate;

        IsShowCertInfo := Rec.ThumbPrint <> '';
        IsPasswordRequired := false;
    end;

    local procedure NotfiyExpiredCert(Message: Text)
    begin
        IsExpired := true;
        ExpiredNotification.Message(Message);
        ExpiredNotification.Send();
    end;

    local procedure RecallNotifications()
    begin
        if ExpiredNotification.Recall() then;
        if PasswordNotification.Recall() then;
    end;

    local procedure CheckEncryption()
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        ConfirmMgt: Codeunit "Confirm Management";
    begin
        if not CryptographyManagement.IsEncryptionEnabled() then
            if ConfirmMgt.GetResponseOrDefault(CryptographyManagement.GetEncryptionIsNotActivatedQst(), false) then
                Page.RunModal(Page::"Data Encryption Management");
    end;
}

