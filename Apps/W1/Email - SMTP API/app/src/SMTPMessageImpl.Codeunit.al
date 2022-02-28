// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 4614 "SMTP Message Impl"
{
    Access = Internal;

    var
        EmailMimeMessage: DotNet MimeMessage;
        MimeBodyBuilder: Dotnet MimeBodyBuilder;
        FromEmailParseFailureErr: Label 'The From address %1 could not be parsed correctly.', Comment = '%1=The email address';
        RecipientErr: Label 'Could not add recipient %1.', Comment = '%1 = email address';
        EmailParseFailureErr: Label 'The address %1 could not be parsed correctly.', Comment = '%1=The email address';
        SmtpCategoryLbl: Label 'Email SMTP', Locked = true;
        ConcateLbl: Label '; %1', Locked = true;
        FromNameOrEmailHasChangedTxt: Label 'The name or address has changed.';
        ObfuscateLbl: Label '%1*%2@%3', Comment = '%1 = First character of username , %2 = Last character of username, %3 = Host', Locked = true;
        ContentIdLbl: Label 'cid:%1', Comment = '%1 = Content id', Locked = true;

    procedure Initialize()
    begin
        if IsNull(EmailMimeMessage) or IsNull(MimeBodyBuilder) then begin
            EmailMimeMessage := EmailMimeMessage.MimeMessage();
            MimeBodyBuilder := MimeBodyBuilder.BodyBuilder();
        end;
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
        SMTPMessage: Codeunit "SMTP Message";
        EmailAccount: Codeunit "Email Account";
        InternetAddress: DotNet InternetAddress;
        OldName, OldAddress : Text;
    begin
        Initialize();

        OldName := FromName;
        OldAddress := FromAddress;
        SMTPMessage.OnBeforeAddFrom(FromName, FromAddress);

        if (OldName <> FromName) or (OldAddress <> FromAddress) then
            Session.LogMessage('0000GC6', FromNameOrEmailHasChangedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', SmtpCategoryLbl);

        if EmailAccount.ValidateEmailAddress(FromAddress, false) and InternetAddress.TryParse(FromAddress, InternetAddress) then begin
            InternetAddress.Name(FromName);
            EmailMimeMessage.From().Add(InternetAddress);
        end else
            Error(FromEmailParseFailureErr, FromAddress);
    end;

    /// <summary>
    /// Adds the recipients that this email is being sent to.
    /// </summary>
    /// <param name="Recipients">The recipient(s)</param>
    procedure SetToRecipients(Recipients: List of [Text])
    begin
        Initialize();
        AddToInternetAddressList(EmailMimeMessage."To", Recipients);
    end;

    /// <summary>
    /// Adds the cc recipients that this email is being sent to.
    /// </summary>
    /// <param name="Recipients">The cc recipient(s)</param>
    procedure SetCCRecipients(Recipients: List of [Text])
    begin
        Initialize();
        AddToInternetAddressList(EmailMimeMessage.Cc, Recipients);
    end;

    /// <summary>
    /// Adds the bcc recipients that this email is being sent to.
    /// </summary>
    /// <param name="Recipients">The bcc recipient(s)</param>
    procedure SetBCCRecipients(Recipients: List of [Text])
    begin
        Initialize();
        AddToInternetAddressList(EmailMimeMessage.Bcc, Recipients);
    end;

    /// <summary>
    /// Adds the subject of this email.
    /// </summary>
    /// <param name="Subject">The subject</param>
    procedure SetSubject(Subject: Text)
    begin
        Initialize();
        EmailMimeMessage.Subject := Subject;
    end;

    procedure SetBody(Body: Text; HtmlFormatted: Boolean)
    begin
        Initialize();
        MimeBodyBuilder := MimeBodyBuilder.BodyBuilder();

        if HtmlFormatted then
            MimeBodyBuilder.HtmlBody := Body
        else
            MimeBodyBuilder.TextBody := Body;

        ConvertBase64ImagesToContentId();
    end;

    procedure AddAttachment(AttachmentInStream: InStream; AttachmentName: Text): Boolean
    begin
        Initialize();
        AttachmentName := StripNotsupportChrInFileName(AttachmentName);

        exit(TryAddAttachment(AttachmentName, AttachmentInStream, MimeBodyBuilder));
    end;

    procedure GetMessage(var MimeMessage: DotNet MimeMessage)
    begin
        Initialize();
        EmailMimeMessage.Body := MimeBodyBuilder.ToMessageBody();
        MimeMessage := EmailMimeMessage;
    end;

    /// <summary>
    /// Try function for adding an attachment
    /// </summary>
    /// <remarks>
    /// Possible exceptions are ArgumentNullException and ArgumentException.
    /// For more information, see the Mimekit documentation.
    /// </remarks>
    [TryFunction]
    local procedure TryAddAttachment(FileName: Text; AttachmentInStream: InStream; var BodyBuilder: Dotnet MimeBodyBuilder)
    begin
        BodyBuilder.Attachments.Add(FileName, AttachmentInStream)
    end;

    local procedure AddToInternetAddressList(InternetAddressList: DotNet InternetAddressList; Recipients: List of [Text])
    begin
        InternetAddressList.Clear();
        if not TryParseInternetAddressList(InternetAddressList, Recipients) then begin
            Session.LogMessage('0000B5N', StrSubstNo(RecipientErr, FormatListToString(Recipients, true)), Verbosity::Error, DataClassification::EndUserPseudonymousIdentifiers, TelemetryScope::ExtensionPublisher, 'Category', SmtpCategoryLbl);
            Error(RecipientErr, FormatListToString(Recipients, false));
        end;
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

    /// <summary>
    /// Searches the body of the email for <c>img</c> elements with a base64-encoded source and transforms these into inline attachments using ContentID. The body will be replaced.
    /// </summary>
    /// <returns>True if all images which look like they are base64-encoded have been successfully coverted, false if one or more fail.</returns>
    local procedure ConvertBase64ImagesToContentId(): Boolean
    var
        Base64ImgPatternRegex: DotNet Regex;
        Document: XmlDocument;
        ReadOptions: XmlReadOptions;
        WriteOptions: XmlWriteOptions;
        ImageElements: XmlNodeList;
        ImageElement: XmlNode;
        ImageElementAttribute: XmlAttribute;
        MemoryStream: DotNet MemoryStream;
        Encoding: DotNet Encoding;
        Base64ImgMatch: DotNet Match;
        String: DotNet String;
        MimeUtils: DotNet MimeUtils;
        MimeContentType: DotNet MimeContentType;
        MimeEntity: DotNet MimeEntity;
        DocumentSource: Text;
        ImageElementValue: Text;
        Base64Img: Text;
        Filename: Text;
        MediaType: Text;
        MediaSubtype: Text;
        ContentId: Text;
    begin
        if MimeBodyBuilder.HtmlBody = '' then
            exit(true);

        ReadOptions.PreserveWhitespace(true);
        MemoryStream := MemoryStream.MemoryStream(Encoding.UTF8().GetBytes(MimeBodyBuilder.HtmlBody));

        if not XmlDocument.ReadFrom(MemoryStream, ReadOptions, Document) then
            exit(false);

        // Get all <img> elements
        ImageElements := Document.GetDescendantElements('img');

        if ImageElements.Count() = 0 then
            exit(true); // No images to convert

        Base64ImgPatternRegex := Base64ImgPatternRegex.Regex('data:(.*);base64,(.*)');
        foreach ImageElement in ImageElements do
            if ImageElement.AsXmlElement().Attributes().Get('src', ImageElementAttribute) then begin
                ImageElementValue := ImageElementAttribute.Value();
                Base64ImgMatch := Base64ImgPatternRegex.Match(ImageElementValue);

                if not String.IsNullOrEmpty(Base64ImgMatch.Value) then begin
                    MediaType := Base64ImgMatch.Groups.Item(1).Value();
                    MediaSubtype := MediaType.Split('/').Get(2);
                    MediaType := MediaType.Split('/').Get(1);
                    Base64Img := Base64ImgMatch.Groups.Item(2).Value();

                    Filename := MimeUtils.GenerateMessageId() + '.jpg';

                    MimeContentType := MimeContentType.ContentType(MediaType, MediaSubtype);
                    MimeContentType.Name := Filename;

                    ContentId := Format(CreateGuid(), 0, 3);

                    if TryAddLinkedResources(Filename, Base64Img, MimeContentType, MimeEntity) then begin
                        MimeEntity.ContentId := ContentId;
                        ImageElementAttribute.Value(StrSubstNo(ContentIdLbl, ContentId));
                    end
                    else
                        exit(false);
                end;
            end;

        WriteOptions.PreserveWhitespace(true);
        Document.WriteTo(WriteOptions, DocumentSource);
        MimeBodyBuilder.HtmlBody := DocumentSource;
        exit(true);
    end;

    /// <summary>
    /// Tries to add the base64 image to linked resources.
    /// </summary>
    /// <returns>True if there is no error.</returns>
    [TryFunction]
    local procedure TryAddLinkedResources(Filename: Text; Base64Img: Text; MimeContentType: DotNet MimeContentType; var MimeEntity: DotNet MimeEntity)
    var
        Convert: DotNet Convert;
    begin
        MimeEntity := MimeBodyBuilder.LinkedResources.Add(Filename, Convert.FromBase64String(Base64Img), MimeContentType);
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
    /// <param name="List">List of email addresses.</param>
    /// <param name="Obfuscate">Obfuscate the email addresses.</param>
    /// <returns>Semicolon separated string of list of texts.</returns>
    local procedure FormatListToString(List: List of [Text]; Obfuscate: Boolean) String: Text
    var
        Address: Text;
        Counter: Integer;
    begin
        if List.Count() = 0 then
            exit;

        String := List.Get(1);
        if Obfuscate then
            String := ObsfuscateEmailAddress(String);

        for Counter := 2 to List.Count() do begin
            Address := List.Get(Counter);
            if Obfuscate then
                Address := ObsfuscateEmailAddress(Address);
            String += StrSubstNo(ConcateLbl, Address);
        end;
    end;

    local procedure ObsfuscateEmailAddress(Email: Text) ObfuscatedEmail: Text
    var
        Username: Text;
        Domain: Text;
        Position: Integer;
    begin
        Position := StrPos(Email, '@');
        if Position > 0 then begin
            Username := DelStr(Email, Position, StrLen(Email) - Position);
            Domain := DelStr(Email, 1, Position);

            ObfuscatedEmail := StrSubstNo(ObfuscateLbl, Username.Substring(1, 1), Username.Substring(Position - 1, 1), Domain);
        end else begin
            if StrLen(Email) > 0 then
                ObfuscatedEmail := Email.Substring(1, 1);

            ObfuscatedEmail += '* (Not a valid email)';
        end;
    end;
}