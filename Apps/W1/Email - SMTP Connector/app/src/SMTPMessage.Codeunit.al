// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4514 "SMTP Message"
{
    Access = Internal;

    var
        Email: DotNet MimeMessage;
        FromEmailParseFailureErr: Label 'The From address %1 could not be parsed correctly.', Comment = '%1=The email address';
        RecipientErr: Label 'Could not add recipient %1.', Comment = '%1 = email address';
        FailedToAddLinkResourceMsg: Label 'Failed to add linked resource. Content Type: %1', Comment = '%1 - The Content Type of the resource.';
        EmailParseFailureErr: Label 'The address %1 could not be parsed correctly.', Comment = '%1=The email address';
        SmtpCategoryLbl: Label 'Email SMTP', Locked = true;

    procedure Initialize()
    var
        MimeMessage: DotNet MimeMessage;
    begin
        Email := MimeMessage.MimeMessage();
    end;

    procedure GetMessage(var Message: DotNet MimeMessage)
    begin
        Message := Email;
    end;

    /// <summary>
    /// Adds the mailbox that this email is being sent from.
    /// </summary>
    /// <param name="FromName">The name of the email sender</param>
    /// <param name="FromAddress">The address of the default sender or, when using the Send As or Send on Behalf functionality, the address of the substitute sender</param>
    /// <remarks>
    /// See https://aka.ms/EmailSetupHelp to learn about the Send As functionality.
    /// </remarks>
    [TryFunction]
    procedure AddFrom(FromName: Text; FromAddress: Text)
    var
        EmailAccount: Codeunit "Email Account";
        InternetAddress: DotNet InternetAddress;
    begin
        if EmailAccount.ValidateEmailAddress(FromAddress, false) and InternetAddress.TryParse(FromAddress, InternetAddress) then begin
            InternetAddress.Name(FromName);
            Email.From().Add(InternetAddress);
        end else
            Error(FromEmailParseFailureErr, FromAddress);
    end;

    /// <summary>
    /// Adds the recipients that this email is being sent to.
    /// </summary>
    /// <param name="Recipients">The recipient(s)</param>
    local procedure AddRecipients(Recipients: List of [Text])
    begin
        AddToInternetAddressList(Email."To", Recipients);
    end;

    /// <summary>
    /// Adds the cc recipients that this email is being sent to.
    /// </summary>
    /// <param name="Recipients">The cc recipient(s)</param>
    local procedure AddCC(Recipients: List of [Text])
    begin
        AddToInternetAddressList(Email.Cc, Recipients);
    end;

    /// <summary>
    /// Adds the bcc recipients that this email is being sent to.
    /// </summary>
    /// <param name="Recipients">The bcc recipient(s)</param>
    local procedure AddBCC(Recipients: List of [Text])
    begin
        AddToInternetAddressList(Email.Bcc, Recipients);
    end;

    /// <summary>
    /// Adds the subject of this email.
    /// </summary>
    /// <param name="Subject">The subject</param>
    local procedure AddSubject(Subject: Text)
    begin
        Email.Subject := Subject;
    end;

    procedure BuildMessage(Message: Codeunit "Email Message"; SMTPAccount: Record "SMTP Account")
    var
        BodyBuilder: Dotnet MimeBodyBuilder;
        EmailRecipientType: Enum "Email Recipient Type";
        AttachmentInStream: InStream;
        Body: Text;
        Recipients: List of [Text];
    begin
        // Add From
        AddFrom(SMTPAccount."Sender Name", SMTPAccount."Email Address");

        // Add "To" recipients
#pragma warning disable AA0205
        Message.GetRecipients(EmailRecipientType::"To", Recipients);
#pragma warning restore AA0205
        AddRecipients(Recipients);

        // Add "Cc" recipients
        Clear(Recipients);
        Message.GetRecipients(EmailRecipientType::"Cc", Recipients);
        AddCC(Recipients);

        // Add Bcc recipients
        Clear(Recipients);
        Message.GetRecipients(EmailRecipientType::"Bcc", Recipients);
        AddBCC(Recipients);

        // Add Subject
        AddSubject(Message.GetSubject());

        // Add Body and attachements
        Body := Message.GetBody();
        BodyBuilder := BodyBuilder.BodyBuilder();

        if Message.IsBodyHTMLFormatted() then
            BodyBuilder.HtmlBody := Body
        else
            BodyBuilder.TextBody := Body;

        // Add Attachments
        if Message.Attachments_First() then
            repeat
                Message.Attachments_GetContent(AttachmentInStream);
                if not Message.Attachments_IsInline() then
                    AddAttachmentStream(AttachmentInStream, Message.Attachments_GetName(), BodyBuilder)
                else
                    if TryAddLinkedResources(Message.Attachments_GetName(), AttachmentInStream, Message.Attachments_GetContentType(), Message.Attachments_GetContentId(), BodyBuilder) then
                        Session.LogMessage('0000CTG', StrSubstNo(FailedToAddLinkResourceMsg, Message.Attachments_GetContentType()), Verbosity::Error, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);
            until Message.Attachments_Next() = 0;
        Email.Body := BodyBuilder.ToMessageBody();
    end;

    /// <summary>
    /// Adds an attachment to the email through an InStream with a name.
    /// </summary>
    /// <param name="AttachmentStream">The stream of the attachment to attach</param>
    /// <param name="AttachmentName">The name of the attachment</param>
    /// <returns>True if successfully added.</returns>
    local procedure AddAttachmentStream(AttachmentStream: InStream; AttachmentName: Text; var BodyBuilder: Dotnet MimeBodyBuilder): Boolean
    begin
        AttachmentName := StripNotsupportChrInFileName(AttachmentName);

        exit(TryAddAttachment(AttachmentName, AttachmentStream, BodyBuilder));
    end;

    /// <summary>
    /// Try function for adding an attachment
    /// </summary>
    /// <remarks>
    /// Possible exceptions are ArgumentNullException and ArgumentException.
    /// For more information, see the Mimekit documentation.
    /// </remarks>
    [TryFunction]
    local procedure TryAddAttachment(FileName: Text; AttachmentStream: InStream; var BodyBuilder: Dotnet MimeBodyBuilder)
    begin
        BodyBuilder.Attachments.Add(FileName, AttachmentStream)
    end;

    local procedure AddToInternetAddressList(InternetAddressList: DotNet InternetAddressList; Recipients: List of [Text])
    begin
        if not TryParseInternetAddressList(InternetAddressList, Recipients) then begin
            Session.LogMessage('0000B5M', StrSubstNo(RecipientErr, FormatListToString(Recipients)), Verbosity::Error, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);
            Error(RecipientErr, FormatListToString(Recipients));
        end;
    end;

    /// <summary>
    /// Tries to add the base64 image to linked resources.
    /// </summary>
    /// <returns>True if there is no error.</returns>
    [TryFunction]
    local procedure TryAddLinkedResources(Filename: Text; AttachmentStream: InStream; ContentType: Text; ContentId: Text; var BodyBuilder: Dotnet MimeBodyBuilder)
    var
        MemoryStream: DotNet MemoryStream;
        MimeContentType: DotNet MimeContentType;
        MimeEntity: DotNet MimeEntity;
        MediaType: Text;
        MediaSubType: Text;
    begin
        MemoryStream := MemoryStream.MemoryStream();
        CopyStream(MemoryStream, AttachmentStream);
        MediaSubType := ContentType.Split('/').Get(2);
        MediaType := MediaType.Split('/').Get(1);
        MimeContentType := MimeContentType.ContentType(MediaType, MediaSubtype);
        MimeEntity := BodyBuilder.LinkedResources.Add(Filename, MemoryStream.GetBuffer(), MimeContentType);
        MimeEntity.ContentId := ContentId;
    end;

    /// <summary>
    /// Tries to parse the given addresses into InternetAddressList.
    /// </summary>
    /// <param name="InternetAddressList">The list of addresses output</param>
    /// <param name="Addresses">The list of addresses to parse</param>
    /// <returns>True if no errors occurred during parsing.</returns>
    [TryFunction]
    local procedure TryParseInternetAddressList(InternetAddressList: DotNet InternetAddressList; Addresses: List of [Text])
    var
        EmailAccount: Codeunit "Email Account";
        InternetAddress: DotNet InternetAddress;
        Address: Text;
    begin
        foreach Address in Addresses do
            if EmailAccount.ValidateEmailAddress(Address, false) and InternetAddress.TryParse(Address, InternetAddress) then
                InternetAddressList.Add(InternetAddress)
            else
                Error(EmailParseFailureErr, Address);
    end;

    local procedure StripNotsupportChrInFileName(InText: Text): Text
    var
        InvalidWindowsChrStringTxt: Label '"#%&*:<>?\/{|}~', Locked = true; //TODO are these all illegal chars?
    begin
        exit(DelChr(InText, '=', InvalidWindowsChrStringTxt));
    end;

    /// <summary>
    /// Formats a list into a semicolon separated string.
    /// </summary>
    /// <returns>Semicolon separated string of list of texts.</returns>
    procedure FormatListToString(List: List of [Text]) String: Text
    var
        Address: Text;
        Counter: Integer;
        ConcateLbl: Label '; %2', Locked = true;
    begin
        if List.Count() = 0 then
            exit;
        String += List.Get(1);

        for Counter := 2 to List.Count() do begin
            Address := List.Get(Counter);
            String += StrSubstNo(ConcateLbl, Address);
        end;
    end;
}