// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Upgrade email attachments to be of type Media instead of BLOB.
/// </summary>
codeunit 8910 "Email Attachment Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpdateEmailAttachment()
    end;

    local procedure UpdateEmailAttachment();
    var
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetEmailAttachmentUpgradeTag()) then
            exit;

        UpgradeEmailAttachments();

        UpgradeTag.SetUpgradeTag(GetEmailAttachmentUpgradeTag());
    end;

    local procedure UpgradeEmailAttachments()
    var
        EmailMessageAttachment: Record "Email Message Attachment";
    begin
        EmailMessageAttachment.SetAutoCalcFields(Attachment);
        if not EmailMessageAttachment.FindSet() then
            exit;

        repeat
            MoveBlobToMedia(EmailMessageAttachment);
        until EmailMessageAttachment.Next() = 0;
    end;

    local procedure MoveBlobToMedia(EmailMessageAttachment: Record "Email Message Attachment")
    var
        AttachmentInstream: InStream;
    begin
        if not EmailMessageAttachment.Attachment.HasValue() then
            exit;

        EmailMessageAttachment.Attachment.CreateInStream(AttachmentInstream);
        if not IsNullGuid(EmailMessageAttachment.Data.ImportStream(AttachmentInstream, '')) then begin
            Clear(EmailMessageAttachment.Attachment);
            EmailMessageAttachment.Modify();
        end else
            Session.LogMessage('0000CTY', StrSubstNo(MediaConversionMsg, EmailMessageAttachment.Length, EmailMessageAttachment."Content Type"), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetEmailAttachmentUpgradeTag());
    end;

    internal procedure GetEmailAttachmentUpgradeTag(): Code[250]
    begin
        exit('MS-385494-EmailAttachmentToMedia-20210103');
    end;

    var
        EmailCategoryLbl: Label 'Email', Locked = true;
        MediaConversionMsg: Label 'Attachment with length: %1 and Content type: %2 Failed', Comment = '%1 - Attachment length, %2 - Content type', Locked = true;
}
