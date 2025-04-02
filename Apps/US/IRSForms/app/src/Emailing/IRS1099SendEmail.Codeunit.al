// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;
using System.EMail;
using System.Telemetry;
using System.Utilities;

codeunit 10051 "IRS 1099 Send Email"
{
    Access = Internal;
    TableNo = "IRS 1099 Email Queue";

    var
        AttachmentFileNameTxt: Label '1099Form%1Subst_%2.pdf', Comment = '%1 - form no like NEC, MISC etc, %2 - report type, B or 2', Locked = true;
        EmailNotSentErr: Label 'The email has not been sent. Error: %1', Comment = '%1 - error message from the email management codeunit';
        VendorNotFoundErr: Label '%1 was not found for the selected 1099 form document.', Comment = '%1 - Vendor No';
        NoConsentErr: Label 'must be enabled on the vendor card.';
        NoConsentAddInfoTxt: Label 'The vendor has not consented to receive 1099 forms electronically.';
        EnableConsentMessageTxt: Label 'You must enable the Receiving 1099 E-Form Consent field on the vendor card to send 1099 forms electronically.';
        EmptyEmailErr: Label 'must be set in the document or vendor card.';
        EmptyEmailAddInfoTxt: Label 'The recipient email is not specified.';
        SetEmailMessageTxt: Label 'Set the email in the document or in the vendor card.';
        EmailSetupMissingErr: Label 'You must set up email in Business Central before you can send 1099 forms.';
        EmailSubjectMissingErr: Label 'You must set up the email subject in the IRS Setup before you send 1099 forms.';
        EmailBodyMissingErr: Label 'You must set up the email body in the IRS Setup before you send 1099 forms.';
        CopyNotFoundErr: Label 'The %1 was not found for the selected 1099 form document.', Comment = '%1 - Report Type, like Copy B or Copy 2';
        ShowVendorCardTxt: Label 'Show Vendor %1', Comment = '%1 - Vendor No';
        ShowIRSFormsSetupTxt: Label 'Show IRS Forms Setup';
        ShowEmailAccountsTxt: Label 'Show Email Accounts';

    trigger OnRun()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099PrintParams: Record "IRS 1099 Print Params";
        IRSFormsFacade: Codeunit "IRS Forms Facade";
    begin
        if IRS1099FormDocHeader.Get(Rec."Document ID") then begin
            CheckCanSendEmail(IRS1099FormDocHeader);

            IRS1099PrintParams."Report Type" := Rec."Report Type";
            IRSFormsFacade.SaveContentForDocument(IRS1099FormDocHeader, IRS1099PrintParams, false);

            SendEmailToVendor(IRS1099FormDocHeader, Rec."Report Type");
        end;
    end;

    procedure SendEmailToVendor(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; ReportType: Enum "IRS 1099 Form Report Type")
    var
        IRS1099FormReport: Record "IRS 1099 Form Report";
        TempEmailItem: Record "Email Item" temporary;
        MailManagement: Codeunit "Mail Management";
        Telemetry: Codeunit Telemetry;
        FileName: Text;
        ReportTypeText: Text;
    begin
        ClearLastError();
        ResetEmailStatus(IRS1099FormDocHeader, ReportType);

        CheckCanSendEmail(IRS1099FormDocHeader);

        IRS1099FormReport.SetRange("Document ID", IRS1099FormDocHeader.ID);
        IRS1099FormReport.SetRange("Report Type", ReportType);
        if not IRS1099FormReport.FindLast() then
            Error(CopyNotFoundErr, ReportType);

        InitTempEmailItem(TempEmailItem, IRS1099FormDocHeader."Vendor E-Mail");
        ReportTypeText := Format(ReportType.Names.Get(ReportType.AsInteger()));
        FileName := StrSubstNo(AttachmentFileNameTxt, IRS1099FormDocHeader."Form No.", ReportTypeText.TrimStart('Copy '));
        AddAttachment(TempEmailItem, IRS1099FormReport, FileName);

        MailManagement.SetHideMailDialog(true);
        MailManagement.SetHideEmailSendingError(true);
        if not MailManagement.Send(TempEmailItem, Enum::"Email Scenario"::Default) then begin
            Telemetry.LogMessage('0000MHW', StrSubstNo(EmailNotSentErr, GetLastErrorText()), Verbosity::Warning, DataClassification::SystemMetadata);
            Error(EmailNotSentErr, GetLastErrorText());
        end;
    end;

    procedure CheckEmailSetup()
    var
        IRSFormsSetup: Record "IRS Forms Setup";
        EmailAccount: Record "Email Account";
        MailManagement: Codeunit "Mail Management";
        DummyRecId: RecordId;
    begin
        if not MailManagement.IsEnabled() then
            if EmailAccount.WritePermission() then
                ThrowShowItError('', EmailSetupMissingErr, ShowEmailAccountsTxt, DummyRecId, 0, Page::"Email Accounts")
            else
                Error(EmailSetupMissingErr);

        IRSFormsSetup.InitSetup();
        if IRSFormsSetup."Email Subject" = '' then
            if IRSFormsSetup.WritePermission() then
                ThrowShowItError('', EmailSubjectMissingErr, ShowIRSFormsSetupTxt, IRSFormsSetup.RecordId, IRSFormsSetup.FieldNo("Email Subject"), Page::"IRS Forms Setup")
            else
                Error(EmailSubjectMissingErr);
        if IRSFormsSetup."Email Body" = '' then
            if IRSFormsSetup.WritePermission() then
                ThrowShowItError('', EmailBodyMissingErr, ShowIRSFormsSetupTxt, IRSFormsSetup.RecordId, IRSFormsSetup.FieldNo("Email Body"), Page::"IRS Forms Setup")
            else
                Error(EmailBodyMissingErr);
    end;

    procedure CheckCanSendEmail(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header")
    var
        Vendor: Record Vendor;
    begin
        if not Vendor.Get(IRS1099FormDocHeader."Vendor No.") then
            Error(VendorNotFoundErr, IRS1099FormDocHeader."Vendor No.");

        if not IRS1099FormDocHeader."Receiving 1099 E-Form Consent" then
            if Vendor.WritePermission() then
                ThrowShowItError(
                    NoConsentAddInfoTxt, EnableConsentMessageTxt, StrSubstNo(ShowVendorCardTxt, Vendor."No."), Vendor.RecordId, 0, Page::"Vendor Card")
            else
                Error(NoConsentAddInfoTxt);

        if IRS1099FormDocHeader."Vendor E-Mail" = '' then
            if Vendor.WritePermission() then
                ThrowShowItError(
                    EmptyEmailAddInfoTxt, SetEmailMessageTxt, StrSubstNo(ShowVendorCardTxt, Vendor."No."), Vendor.RecordId,
                    Vendor.FieldNo("E-Mail For IRS"), Page::"Vendor Card")
            else
                Error(EmptyEmailAddInfoTxt);
    end;

    procedure CheckCanSendMultipleEmails(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header")
    var
        Vendor: Record Vendor;
        ErrorMessageMgt: Codeunit "Error Message Management";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        ErrorContextElement: Codeunit "Error Context Element";
    begin
        if not IRS1099FormDocHeader.FindSet() then
            exit;

        ErrorMessageMgt.Activate(ErrorMessageHandler);

        repeat
            if not Vendor.Get(IRS1099FormDocHeader."Vendor No.") then begin
                ErrorMessageMgt.LogFieldError(IRS1099FormDocHeader, IRS1099FormDocHeader.FieldNo("Vendor No."), VendorNotFoundErr);
                continue;
            end;

            if not IRS1099FormDocHeader."Receiving 1099 E-Form Consent" then begin
                ErrorMessageMgt.PushContext(ErrorContextElement, Vendor, Vendor.FieldNo("Receiving 1099 E-Form Consent"), NoConsentAddInfoTxt);
                ErrorMessageMgt.LogFieldError(IRS1099FormDocHeader, IRS1099FormDocHeader.FieldNo("Receiving 1099 E-Form Consent"), NoConsentErr);
            end;

            if IRS1099FormDocHeader."Vendor E-Mail" = '' then begin
                ErrorMessageMgt.PushContext(ErrorContextElement, Vendor, Vendor.FieldNo("E-Mail"), EmptyEmailAddInfoTxt);
                ErrorMessageMgt.LogFieldError(IRS1099FormDocHeader, IRS1099FormDocHeader.FieldNo("Vendor E-Mail"), EmptyEmailErr);
            end;
        until IRS1099FormDocHeader.Next() = 0;

        if ErrorMessageHandler.HasErrors() then begin
            ErrorMessageHandler.ShowErrors();
            Error('');
        end;
    end;

    local procedure InitTempEmailItem(var TempEmailItem: Record "Email Item" temporary; EmailAddress: Text[250])
    var
        IRSFormsSetup: Record "IRS Forms Setup";
    begin
        IRSFormsSetup.Get();
        TempEmailItem.Initialize();
        TempEmailItem.Subject := IRSFormsSetup."Email Subject";
        TempEmailItem.SetBodyText(IRSFormsSetup."Email Body");
        TempEmailItem."Send to" := EmailAddress;
        TempEmailItem.Insert();
    end;

    local procedure AddAttachment(var TempEmailItem: Record "Email Item" temporary; var IRS1099FormReport: Record "IRS 1099 Form Report"; FileName: Text)
    var
        FileInStream: InStream;
    begin
        IRS1099FormReport.CalcFields("File Content");
        if not IRS1099FormReport."File Content".HasValue() then
            exit;

        IRS1099FormReport."File Content".CreateInStream(FileInStream);
        TempEmailItem.AddAttachment(FileInStream, FileName);
    end;

    local procedure ThrowShowItError(Title: Text; Message: Text; NavigationActionText: Text; RecId: RecordId; FieldNo: Integer; PageNo: Integer)
    var
        ErrorInfo: ErrorInfo;
    begin
        ErrorInfo.Message := Message;
        ErrorInfo.ErrorType := ErrorType::Client;

        if Title <> '' then
            ErrorInfo.Title := Title;
        if NavigationActionText <> '' then
            ErrorInfo.AddNavigationAction(NavigationActionText);
        if RecId.TableNo <> 0 then
            ErrorInfo.RecordId(RecId);
        if FieldNo <> 0 then
            ErrorInfo.FieldNo(FieldNo);
        if PageNo <> 0 then
            ErrorInfo.PageNo(PageNo);

        Error(ErrorInfo);
    end;

    procedure SetEmailStatusSuccess(IRS1099EmailQueue: Record "IRS 1099 Email Queue")
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
    begin
        if not IRS1099FormDocHeader.Get(IRS1099EmailQueue."Document ID") then
            exit;
        SetEmailStatusSuccess(IRS1099FormDocHeader, IRS1099EmailQueue."Report Type");
    end;

    procedure SetEmailStatusSuccess(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; ReportType: Enum "IRS 1099 Form Report Type")
    begin
        case ReportType of
            Enum::"IRS 1099 Form Report Type"::"Copy B":
                IRS1099FormDocHeader."Copy B Sent" := true;
            Enum::"IRS 1099 Form Report Type"::"Copy 2":
                IRS1099FormDocHeader."Copy 2 Sent" := true;
        end;
        IRS1099FormDocHeader."Email Error Log" := '';
        IRS1099FormDocHeader.Modify();
    end;

    procedure SetEmailStatusFail(IRS1099EmailQueue: Record "IRS 1099 Email Queue"; ErrorText: Text)
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
    begin
        if not IRS1099FormDocHeader.Get(IRS1099EmailQueue."Document ID") then
            exit;
        SetEmailStatusFail(IRS1099FormDocHeader, IRS1099EmailQueue."Report Type", ErrorText);
    end;

    procedure SetEmailStatusFail(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; ReportType: Enum "IRS 1099 Form Report Type"; ErrorText: Text)
    begin
        case ReportType of
            Enum::"IRS 1099 Form Report Type"::"Copy B":
                IRS1099FormDocHeader."Copy B Sent" := false;
            Enum::"IRS 1099 Form Report Type"::"Copy 2":
                IRS1099FormDocHeader."Copy 2 Sent" := false;
        end;
        IRS1099FormDocHeader."Email Error Log" := CopyStr(ErrorText, 1, MaxStrLen(IRS1099FormDocHeader."Email Error Log"));
        IRS1099FormDocHeader.Modify();
    end;

    local procedure ResetEmailStatus(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; ReportType: Enum "IRS 1099 Form Report Type")
    begin
        case ReportType of
            Enum::"IRS 1099 Form Report Type"::"Copy B":
                IRS1099FormDocHeader."Copy B Sent" := false;
            Enum::"IRS 1099 Form Report Type"::"Copy 2":
                IRS1099FormDocHeader."Copy 2 Sent" := false;
        end;
        IRS1099FormDocHeader."Email Error Log" := '';
        IRS1099FormDocHeader.Modify();
    end;
}
