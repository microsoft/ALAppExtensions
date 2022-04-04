// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8906 "Email Editor"
{
    Access = Internal;
    Permissions = tabledata "Email Outbox" = rimd,
                  tabledata "Tenant Media" = r,
                  tabledata "Email Related Record" = rd,
                  tabledata "Email View Policy" = r;

    procedure Open(EmailOutbox: Record "Email Outbox"; IsModal: Boolean): Enum "Email Action"
    var
        EmailEditor: Page "Email Editor";
    begin
        CheckPermissions(EmailOutbox);

        EmailEditor.SetRecord(EmailOutbox);

        if IsNewOutbox then
            EmailEditor.SetAsNew();

        if IsModal then begin
            EmailEditor.RunModal();
            exit(EmailEditor.GetAction());
        end
        else
            EmailEditor.Run();
    end;

    procedure CheckPermissions(EmailOutbox: Record "Email Outbox")
    var
        EmailImpl: Codeunit "Email Impl";
        EmailViewPolicy: Interface "Email View Policy";
    begin
        EmailViewPolicy := EmailImpl.GetUserEmailViewPolicy();
        if EmailViewPolicy.HasAccess(EmailOutbox) then
            exit;

        Error(EmailMessageOpenPermissionErr);
    end;

    procedure SetAsNew()
    begin
        IsNewOutbox := true;
    end;

    procedure GetEmailAccount(EmailOutbox: Record "Email Outbox"; var EmailAccount: Record "Email Account");
    var
        EmailAccounts: Codeunit "Email Account";
    begin
        EmailAccounts.GetAllAccounts(EmailAccount);

        if not EmailAccount.Get(EmailOutbox."Account Id", EmailOutbox.Connector) then
            Clear(EmailAccount);
    end;

    procedure GetEmailMessage(var EmailOutbox: Record "Email Outbox"; var EmailMessageImpl: Codeunit "Email Message Impl.");
    begin
        if EmailMessageImpl.Get(EmailOutbox."Message Id") then
            exit;

        EmailMessageImpl.Create('', '', '', true);
        EmailOutbox."Message Id" := EmailMessageImpl.GetId();
        EmailOutbox.Modify();
    end;

    procedure CreateOutbox(var EmailOutbox: Record "Email Outbox")
    var
        DefaultEmailAccount: Record "Email Account";
        EmailScenario: Codeunit "Email Scenario";
    begin
        EmailOutbox."User Security Id" := UserSecurityId();
        EmailOutbox.Status := Enum::"Email Status"::Draft;

        if EmailScenario.GetDefaultEmailAccount(DefaultEmailAccount) then begin
            EmailOutbox."Account Id" := DefaultEmailAccount."Account Id";
            EmailOutbox.Connector := DefaultEmailAccount.Connector;
        end;

        EmailOutbox.Insert();
    end;

    procedure ChangeEmailAccount(var EmailOutbox: Record "Email Outbox"; var ChosenEmailAccount: Record "Email Account")
    var
        EmailAccounts: Page "Email Accounts";
    begin
        EmailAccounts.EnableLookupMode();

        if not IsNullGuid(ChosenEmailAccount."Account Id") then
            EmailAccounts.SetAccount(ChosenEmailAccount);

        if EmailAccounts.RunModal() = Action::LookupOK then begin
            EmailAccounts.GetAccount(ChosenEmailAccount);

            EmailOutbox."Account Id" := ChosenEmailAccount."Account Id";
            EmailOutbox.Connector := ChosenEmailAccount.Connector;
            EmailOutbox.Modify();
        end;
    end;

    procedure UploadAttachment(EmailMessageImpl: Codeunit "Email Message Impl.")
    var
        FileName: Text;
        Instream: Instream;
        AttachmentName, ContentType : Text[250];
        AttachamentSize: Integer;
    begin
        if not UploadIntoStream('', '', '', FileName, Instream) then
            exit;

        AttachmentName := CopyStr(FileName, 1, 250);
        ContentType := EmailMessageImpl.GetContentTypeFromFilename(Filename);
        AttachamentSize := EmailMessageImpl.AddAttachmentInternal(AttachmentName, ContentType, Instream);

        Session.LogMessage('0000CTX', StrSubstNo(UploadingAttachmentMsg, AttachamentSize, ContentType), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
    end;

    procedure DownloadAttachment(MediaID: Guid; FileName: Text)
    var
        TenantMedia: Record "Tenant Media";
        EmailMessage: Codeunit "Email Message";
        MediaInstream: InStream;
        Handled: Boolean;
    begin
        TenantMedia.Get(MediaID);
        TenantMedia.CalcFields(Content);

        if TenantMedia.Content.HasValue() then
            TenantMedia.Content.CreateInStream(MediaInstream)
        else begin
            EmailMessage.OnGetAttachmentContent(MediaID, MediaInstream, Handled);
            if not Handled then
                Error(NoAttachmentContentMsg);
        end;
        DownloadFromStream(MediaInstream, '', '', '', Filename);
    end;

    procedure ValidateEmailData(FromEmailAddress: Text; var EmailMessageImpl: Codeunit "Email Message Impl."): Boolean
    begin
        // Validate email account
        if FromEmailAddress = '' then
            Error(NoFromAccountErr);

        // Validate recipients
        EmailMessageImpl.ValidateRecipients();

        // Verify related records against current recipients
        VerifyRelatedRecords(EmailMessageImpl.GetId());

        if EmailMessageImpl.GetSubject() = '' then
            exit(Dialog.Confirm(NoSubjectlineQst, false));

        exit(true);
    end;

    procedure SendOutbox(var EmailOutbox: Record "Email Outbox")
    var
        EmailImpl: Codeunit "Email Impl";
        EmailMessage: Codeunit "Email Message";
    begin
        EmailMessage.Get(EmailOutbox."Message Id");

        if not EmailImpl.Send(EmailMessage, EmailOutbox."Account Id", EmailOutbox.Connector, EmailOutbox) then
            Error(SendingFailedErr, GetLastErrorText());
    end;

    procedure DiscardEmail(var EmailOutbox: Record "Email Outbox"; Confirm: Boolean): Boolean
    begin
        if Confirm then
            if not Confirm(ConfirmDiscardEmailQst, true) then
                exit(false);

        exit(EmailOutbox.Delete(true)); // This should detele the email message, recipients and attachments as well.
    end;

    procedure AttachFromRelatedRecords(EmailMessageID: Guid);
    var
        EmailRelatedAttachment: Record "Email Related Attachment";
        Email: Codeunit "Email";
        EmailRelatedAttachmentsPage: Page "Email Related Attachments";
    begin
        EmailRelatedAttachmentsPage.LookupMode(true);
        EmailRelatedAttachmentsPage.SetMessageID(EmailMessageID);
        if EmailRelatedAttachmentsPage.RunModal() <> Action::LookupOK then
            exit;

        EmailRelatedAttachmentsPage.GetSelectedAttachments(EmailRelatedAttachment);
        if EmailRelatedAttachment.FindSet() then
            repeat
                Email.OnGetAttachment(EmailRelatedAttachment."Attachment Table ID", EmailRelatedAttachment."Attachment System ID", EmailMessageID);
            until EmailRelatedAttachment.Next() = 0;
    end;

    local procedure GetPrimarySourceEntity(var PrimarySource: Integer; EmailMessageID: Guid; Dict: Dictionary of [Integer, Guid]): Boolean
    var
        EmailRelatedRecord: Record "Email Related Record";
        Count: Integer;
    begin
        // If there is only one key in the dict, then there is no need to use DB resources.
        If Dict.Keys.Count = 1 then begin
            PrimarySource := Dict.Keys.Get(1);
            exit(true);
        end;

        EmailRelatedRecord.SetRange("Email Message Id", EmailMessageID);
        for Count := 1 to Dict.Keys.Count() do begin
            EmailRelatedRecord.SetFilter("Table Id", Format(Dict.Keys.Get(Count)));
            EmailRelatedRecord.FindFirst();

            if EmailRelatedRecord."Relation Type" = EmailRelatedRecord."Relation Type"::"Primary Source" then begin
                PrimarySource := Dict.Keys.Get(Count);
                exit(true);
            end;
        end;

        exit(false);
    end;

    local procedure FindEmailSourceEntities(EmailMessageID: Guid; var Dict: Dictionary of [Integer, Guid]): Boolean
    var
        EmailRelatedRecord: Record "Email Related Record";
    begin
        EmailRelatedRecord.SetRange("Email Message Id", EmailMessageID);
        EmailRelatedRecord.FindSet();
        repeat
            Dict.Add(EmailRelatedRecord."Table Id", EmailRelatedRecord."System Id");
        until EmailRelatedRecord.Next() <= 0;

        exit(EmailRelatedRecord.Count() > 0);
    end;

    procedure LoadWordTemplate(EmailMessageImpl: Codeunit "Email Message Impl."; EmailMessageID: Guid)
    var
        WordTemplateRecord: Record "Word Template";
        WordTemplateToTextWizard: Page "Word Template To Text Wizard";
        TemplateSize: Integer;
        Dict: Dictionary of [Integer, Guid];
        PrimarySource: Integer;
    begin
        if FindEmailSourceEntities(EmailMessageID, Dict) then begin
            if not GetPrimarySourceEntity(PrimarySource, EmailMessageID, Dict) then
                Error(NoPrimarySourceOnEmailErr);

            WordTemplateToTextWizard.SetData(Dict, PrimarySource);
            WordTemplateToTextWizard.RunModal();

            if not WordTemplateToTextWizard.WasDialogCompleted() then begin
                Session.LogMessage('0000FL1', LoadingTemplateExitedMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
                exit;
            end;

            WordTemplateToTextWizard.GetRecord(WordTemplateRecord);
            if EmailMessageImpl.GetSubject() = '' then
                EmailMessageImpl.SetSubject(WordTemplateRecord.Name);

            EmailMessageImpl.SetBody(WordTemplateToTextWizard.GetDocumentAsText());
            EmailMessageImpl.Modify();
            TemplateSize := WordTemplateToTextWizard.GetDocumentSize();

            Session.LogMessage('0000FL2', StrSubstNo(LoadingTemplateMsg, TemplateSize), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);

        end;
    end;

    procedure AttachFromWordTemplate(EmailMessageImpl: Codeunit "Email Message Impl."; EmailMessageID: Guid)
    var
        WordTemplateRecord: Record "Word Template";
        WordTemplateSelectionWizard: Page "Word Template Selection Wizard";
        InStream: InStream;
        Filename: Text;
        FileSize: Integer;
        ContentType: Text[250];
        Dict: Dictionary of [Integer, Guid];
    begin
        if FindEmailSourceEntities(EmailMessageID, Dict) then begin
            WordTemplateSelectionWizard.SetData(Dict);
            WordTemplateSelectionWizard.SaveAsDocumentStream();
            WordTemplateSelectionWizard.RunModal();

            if not WordTemplateSelectionWizard.WasDialogCompleted() then begin
                Session.LogMessage('0000FL3', LoadingTemplateExitedMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
                exit;
            end;

            WordTemplateSelectionWizard.GetRecord(WordTemplateRecord);
            WordTemplateSelectionWizard.GetDocumentStream(InStream);

            Filename := WordTemplateRecord.Name + '.' + WordTemplateSelectionWizard.GetDocumentFormat();
            ContentType := EmailMessageImpl.GetContentTypeFromFilename(Filename);
            FileSize := EmailMessageImpl.AddAttachmentInternal(CopyStr(Filename, 1, 250), ContentType, Instream);

            Session.LogMessage('0000FL4', StrSubstNo(UploadingTemplateAttachmentMsg, FileSize, ContentType), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
        end;
    end;


    local procedure InsertRelatedAttachments(TableID: Integer; SystemID: Guid; var EmailRelatedAttachment2: Record "Email Related Attachment"; var EmailRelatedAttachment: Record "Email Related Attachment")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.Open(TableID);
        if not RecordRef.GetBySystemId(SystemID) then begin
            Session.LogMessage('0000CTZ', StrSubstNo(RecordNotFoundMsg, TableID), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', EmailCategoryLbl);
            exit;
        end;

        repeat
            EmailRelatedAttachment.Copy(EmailRelatedAttachment2);
            EmailRelatedAttachment."Attachment Source" := CopyStr(Format(RecordRef.RecordId(), 0, 1), 1, MaxStrLen(EmailRelatedAttachment."Attachment Source"));
            EmailRelatedAttachment.Insert();
        until EmailRelatedAttachment2.Next() = 0;
    end;

    procedure GetRelatedAttachments(EmailMessageId: Guid; var EmailRelatedAttachmentOut: Record "Email Related Attachment")
    var
        EmailRelatedAttachment: Record "Email Related Attachment";
        EmailRelatedRecord: Record "Email Related Record";
        Email: Codeunit "Email";
        EmailImpl: Codeunit "Email Impl";
    begin
        EmailRelatedRecord.SetRange("Email Message Id", EmailMessageId);
        EmailImpl.FilterRemovedSourceRecords(EmailRelatedRecord);
        if EmailRelatedRecord.FindSet() then
            repeat
                Email.OnFindRelatedAttachments(EmailRelatedRecord."Table Id", EmailRelatedRecord."System Id", EmailRelatedAttachment);
                if EmailRelatedAttachment.FindSet() then
                    InsertRelatedAttachments(EmailRelatedRecord."Table Id", EmailRelatedRecord."System Id", EmailRelatedAttachment, EmailRelatedAttachmentOut);
                EmailRelatedAttachment.DeleteAll();
            until EmailRelatedRecord.Next() = 0
        else
            Message(NoRelatedAttachmentsErr);
    end;

    procedure LookupRecipients(MessageID: Guid; var Text: Text): Boolean
    var
        SuggestedEmailAddressLookup: Record "Email Address Lookup";
        EmailRelatedRecord: Record "Email Related Record";
        EmailAddressLookup: Codeunit "Email Address Lookup";
        EmailAddressLookupPage: Page "Email Address Lookup";
        EntityType: Enum "Email Address Entity";
    begin

        // Get Suggested Email Addresses
        EmailRelatedRecord.SetRange("Email Message Id", MessageID);
        if EmailRelatedRecord.FindSet() then
            repeat
                EmailAddressLookup.OnGetSuggestedAddresses(EmailRelatedRecord."Table Id", EmailRelatedRecord."System Id", SuggestedEmailAddressLookup);
            until EmailRelatedRecord.Next() = 0;

        if SuggestedEmailAddressLookup.FindFirst() then
            EntityType := SuggestedEmailAddressLookup."Entity type";
        EmailAddressLookupPage.AddSuggestions(SuggestedEmailAddressLookup);
        SuggestedEmailAddressLookup.DeleteAll();

        EmailAddressLookupPage.LookupMode(true);
        EmailAddressLookupPage.SetEntityType(EntityType);
        if (EmailAddressLookupPage.RunModal() = Action::LookupOK) or (EmailAddressLookupPage.WasFullAddressLookup()) then begin
            EmailAddressLookupPage.GetSelectedSuggestions(SuggestedEmailAddressLookup);

            if SuggestedEmailAddressLookup.FindSet() then begin
                if (Text <> '') and (not Text.EndsWith(';')) then
                    Text += ';';
                Text += EmailAddressLookup.GetSelectedSuggestionsAsText(SuggestedEmailAddressLookup);

                // Added recipients is added as related entities on the email
                AddRelatedRecordsFromEmailAddress(MessageID, SuggestedEmailAddressLookup);
                exit(true);
            end;
        end;
        exit(false);
    end;

    procedure VerifyRelatedRecords(MessageID: Guid)
    var
        EmailRelatedRecord: Record "Email Related Record";
        EmailMessage: Codeunit "Email Message";
        TempCache: Dictionary of [Text, Guid];
        TempGuid: Guid;
        Count: Integer;
    begin
        // Copy values to temporary cache
        for Count := 1 to RelatedRecordsCache.Keys().Count() do begin
            RelatedRecordsCache.Get(RelatedRecordsCache.Keys.Get(Count), TempGuid);
            TempCache.Add(RelatedRecordsCache.Keys.Get(Count), TempGuid);
        end;

        // Remove related records that is To, Cc, Bcc 
        EmailMessage.Get(MessageID);
        RemoveFromCacheIfExists(TempCache, EmailMessage, Enum::"Email Recipient Type"::"To");
        RemoveFromCacheIfExists(TempCache, EmailMessage, Enum::"Email Recipient Type"::Cc);
        RemoveFromCacheIfExists(TempCache, EmailMessage, Enum::"Email Recipient Type"::Bcc);

        // Those left in cache was not found in To, Cc or Bcc, and needs to be removed as related records
        for Count := 1 to TempCache.Values.Count() do
            if EmailRelatedRecord.GetBySystemId(TempCache.Values.Get(Count)) then
                if EmailRelatedRecord."Relation Origin" = Enum::"Email Relation Origin"::"Email Address Lookup" then
                    EmailRelatedRecord.Delete();

        // Update global cache
        for Count := 1 to TempCache.Keys.Count() do
            RelatedRecordsCache.Remove(TempCache.Keys.Get(Count));

    end;

    internal procedure RemoveFromCacheIfExists(var TempCache: Dictionary of [Text, Guid]; var EmailMessage: Codeunit "Email Message"; RecipientType: Enum "Email Recipient Type")
    var
        Recipients: List of [Text];
        Count: Integer;
    begin
        EmailMessage.GetRecipients(RecipientType, Recipients);
        for Count := 1 to Recipients.Count() do
            if TempCache.ContainsKey(Recipients.Get(Count)) then
                TempCache.Remove(Recipients.Get(Count));
    end;

    internal procedure PopulateRelatedRecordCache(MessageID: Guid)
    var
        EmailRelatedRecord: Record "Email Related Record";
        EmailAddressLookupRecord: Record "Email Address Lookup";
        EmailAddressLookup: Codeunit "Email Address Lookup";
    begin
        EmailRelatedRecord.SetFilter("Email Message Id", MessageID);
        if not EmailRelatedRecord.FindSet() then
            exit;

        repeat
            if EmailRelatedRecord."Relation Origin" = Enum::"Email Relation Origin"::"Email Address Lookup" then begin
                EmailAddressLookup.OnGetSuggestedAddresses(EmailRelatedRecord."Table Id", EmailRelatedRecord."System Id", EmailAddressLookupRecord);
                if RelatedRecordsCache.Add(EmailAddressLookupRecord."E-Mail Address", EmailRelatedRecord.SystemId) then;
            end;
        until EmailRelatedRecord.Next() = 0;
    end;

    internal procedure AddRelatedRecordsFromEmailAddress(MessageID: Guid; var EmailAddressLookupSuggestion: Record "Email Address Lookup")
    var
        EmailRelatedRecord: Record "Email Related Record";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailRelationType: Enum "Email Relation Type";
        HasRelations: Boolean;
    begin
        EmailMessage.Get(MessageID);
        HasRelations := Email.HasRelations(EmailMessage);

        if EmailAddressLookupSuggestion.FindSet() then
            repeat
                if not HasRelations then begin
                    EmailRelationType := Enum::"Email Relation Type"::"Primary Source";
                    HasRelations := true;
                end else
                    EmailRelationType := Enum::"Email Relation Type"::"Related Entity";

                Email.AddRelation(EmailMessage, EmailAddressLookupSuggestion."Source Table Number", EmailAddressLookupSuggestion."Source System Id", EmailRelationType, Enum::"Email Relation Origin"::"Email Address Lookup");

                // Add related record to cache
                if EmailRelatedRecord.Get(EmailAddressLookupSuggestion."Source Table Number", EmailAddressLookupSuggestion."Source System Id", EmailMessage.GetId()) then
                    if RelatedRecordsCache.Add(EmailAddressLookupSuggestion."E-Mail Address", EmailRelatedRecord.SystemId) then;

            until EmailAddressLookupSuggestion.Next() = 0;
    end;

    var
        RelatedRecordsCache: Dictionary of [Text, Guid];
        IsNewOutbox: Boolean;
        ConfirmDiscardEmailQst: Label 'Go ahead and discard?';
        EmailMessageOpenPermissionErr: Label 'You do not have permission to open the email message.';
        NoSubjectlineQst: Label 'Do you want to send this message without a subject?';
        NoFromAccountErr: Label 'You must specify a valid email account to send the message to.';
        LoadingTemplateMsg: Label 'Applied word template to email body with size: %1.', Comment = '%1 - File size', Locked = true;
        UploadingAttachmentMsg: Label 'Attached file with size: %1, Content type: %2', Comment = '%1 - File size, %2 - Content type', Locked = true;
        UploadingTemplateAttachmentMsg: Label 'Attached word template with size: %1, Content type: %2', Comment = '%1 - File size, %2 - Content type', Locked = true;
        RecordNotFoundMsg: Label 'Record not found in table: %1', Comment = '%1 - File size, %2 - Content type', Locked = true;
        EmailCategoryLbl: Label 'Email', Locked = true;
        SendingFailedErr: Label 'The email was not sent because of the following error: "%1" \\Depending on the error, you might need to contact your administrator.', Comment = '%1 - the error that occurred.';
        NoRelatedAttachmentsErr: Label 'Did not find any attachments related to this email.';
        LoadingTemplateExitedMsg: Label 'Did not apply word template to email as user exited dialog.';
        NoPrimarySourceOnEmailErr: Label 'Failed to find the primary source entity';
        NoAttachmentContentMsg: Label 'The attachment content is no longer available.';
}