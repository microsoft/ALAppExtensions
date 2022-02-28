codeunit 1685 "Email Logging Invoke"
{
    trigger OnRun()
    begin
        RunJob();
    end;

    var
        EmailLoggingManagement: Codeunit "Email Logging Management";
        EmailLoggingAPIHelper: Codeunit "Email Logging API Helper";
        ErrorContext: Text;
        InteractionTemplateSetupEmails: Code[10];
        CategoryTok: Label 'Email Logging', Locked = true;
        TextFileExtentionTxt: Label 'TXT', Locked = true;
        EmailLoggingJobStartedTxt: Label 'Email logging job started.', Locked = true;
        EmailLoggingJobFinishedTxt: Label 'Email logging job finished.', Locked = true;
        ContextValidateSetupTxt: Label 'Validate setup';
        ContextGetMessagesTxt: Label 'Get email messages';
        ContextProcessMessageTxt: Label 'Process email message';
        ContextLogInteractionTxt: Label 'Log interaction';
        ContextDeleteMessageTxt: Label 'Deleting email message';
        ContextArchiveMessageTxt: Label 'Archiving email message';
        ProcessMessagesTxt: Label 'Processing messages', Locked = true;
        ProcessMessageTxt: Label 'Processing message', Locked = true;
        MessageForLoggingTxt: Label 'Message is for logging.', Locked = true;
        MessageNotForLoggingTxt: Label 'Message is not for logging.', Locked = true;
        CollectSalespersonRecipientsTxt: Label 'Collecting salesperson recipients.', Locked = true;
        SalespersonRecipientsFoundTxt: Label 'Salesperson recipients are found.', Locked = true;
        SalespersonRecipientsNotFoundTxt: Label 'Salesperson recipients are not found.', Locked = true;
        CollectContactRecipientsTxt: Label 'Collecting contact recipients.', Locked = true;
        ContactRecipientsFoundTxt: Label 'Contact recipients are found.', Locked = true;
        ContactRecipientsNotFoundTxt: Label 'Contact recipients are not found.', Locked = true;
        MessageInOutBoundInteractionTxt: Label 'Message is in- or out-bound interaction.', Locked = true;
        MessageNotInOutBoundInteractionTxt: Label 'Message is not in- or out-bound interaction.', Locked = true;
        LogMessageAsInteractionTxt: Label 'Logging message as interaction.', Locked = true;
        InsertInteractionLogEntryTxt: Label 'Insert interaction log entry.', Locked = true;
        UpdateMessageTxt: Label 'Update message.', Locked = true;
        NotEmptyRecipientTxt: Label 'Message recipient is not empty.', Locked = true;
        EmptyRecipientTxt: Label 'Message recipient is empty.', Locked = true;
        SalesPersonEmailTxt: Label 'The email is a salesperson email.', Locked = true;
        NotSalesPersonEmailTxt: Label 'The email is not a salesperson email.', Locked = true;
        ContactEmailTxt: Label 'The email is a contact email.', Locked = true;
        NotContactEmailTxt: Label 'The email is not a contact email.', Locked = true;
        NoLinkCommentMessageTxt: Label 'There is no link to the email because the email could not be moved.', Comment = 'Max 80 chars';
        NoLinkAttachmentMessageTxt: Label 'There is no link to the email because the email could not be moved to the Archive folder.';
        EmptyEmailMessageUrlTxt: Label 'Email message URL is empty.', Locked = true;
        NotEmptyEmailMessageUrlTxt: Label 'Email message URL is not empty.', Locked = true;
        MessageMovedTxt: Label 'The email message has been moved.', Locked = true;
        MessageDeletedTxt: Label 'The email message has been deleted.', Locked = true;
        CannotArchiveMessageTxt: Label 'Cannot archive the email message.', Locked = true;
        CannotArchiveMessageDetailedTxt: Label 'Cannot archive the email message. %1\\%2', Locked = true;
        CannotDeleteMessageTxt: Label 'Cannot delete the email message.', Locked = true;
        CannotDeleteMessageDetailedTxt: Label 'Cannot delete the email message. %1\\%2', Locked = true;
        MessageNotLoggedErr: Label 'The message has not been logged. %1', Comment = '%1 - exception message';
        CopyMessageFromQueueToStorageFolderTxt: Label 'Copy message from queue to storage folder.', Locked = true;
        UserCreatingInteractionLogEntryBasedOnEmailTxt: Label 'User created an interaction log entry from an email message.', Locked = true;

    local procedure RunJob()
    begin
        Session.LogMessage('0000FYE', EmailLoggingJobStartedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        SetErrorContext(ContextValidateSetupTxt);
        EmailLoggingManagement.CheckEmailLoggingSetup();
        ProcessMessages();

        Session.LogMessage('0000FYF', EmailLoggingJobFinishedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    local procedure ProcessMessages()
    var
        EmailLoggingMessage: Codeunit "Email Logging Message";
        MessageList: List of [JsonObject];
        MessageJsonObject: JsonObject;
    begin
        Session.LogMessage('0000FYG', ProcessMessagesTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        SetErrorContext(ContextGetMessagesTxt);
        EmailLoggingAPIHelper.GetMessages(MessageList);

        foreach MessageJsonObject in MessageList do begin
            EmailLoggingMessage.Initialize(MessageJsonObject);
            ProcessMessage(EmailLoggingMessage);
        end;
    end;

    local procedure ProcessMessage(var SourceEmailLoggingMessage: Codeunit "Email Logging Message")
    var
        TempSegmentLine: Record "Segment Line" temporary;
        Attachment: Record Attachment;
        TargetEmailLoggingMessage: Codeunit "Email Logging Message";
    begin
        Session.LogMessage('0000FYH', ProcessMessageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        SetErrorContext(ContextProcessMessageTxt);

        if not IsMessageForLogging(SourceEmailLoggingMessage, TempSegmentLine) then begin
            DeleteMessage(SourceEmailLoggingMessage);
            exit;
        end;

        LogMessageAsInteraction(SourceEmailLoggingMessage, TargetEmailLoggingMessage, TempSegmentLine, Attachment);
    end;

    local procedure IsMessageForLogging(var EmailLoggingMessage: Codeunit "Email Logging Message"; var SegmentLine: Record "Segment Line"): Boolean
    begin
        if EmailLoggingMessage.GetIsDraft() then begin
            Session.LogMessage('0000FYJ', MessageNotForLoggingTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        if EmailLoggingMessage.GetSender() = '' then begin
            Session.LogMessage('0000FYK', MessageNotForLoggingTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        if EmailLoggingMessage.GetToAndCcRecipients().Count() = 0 then begin
            Session.LogMessage('0000FYL', MessageNotForLoggingTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        if IsMessageAlreadyLogged(EmailLoggingMessage) then begin
            Session.LogMessage('0000FYM', MessageNotForLoggingTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        if not GetInboundOutboundInteraction(EmailLoggingMessage, SegmentLine) then begin
            Session.LogMessage('0000FYN', MessageNotForLoggingTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        if SegmentLine.IsEmpty() then begin
            Session.LogMessage('0000FYO', MessageNotForLoggingTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        Session.LogMessage('0000FYP', MessageForLoggingTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(true);
    end;

    local procedure ArchiveMessage(var SourceEmailLoggingMessage: Codeunit "Email Logging Message"; var TargetEmailLoggingMessage: Codeunit "Email Logging Message"): Boolean
    var
        ErrorMessage: Text;
    begin
        if TryArchiveMessage(SourceEmailLoggingMessage, TargetEmailLoggingMessage) then
            exit(true);

        ErrorMessage := GetLastErrorText();
        EmailLoggingManagement.LogActivityFailed(ContextArchiveMessageTxt, ErrorMessage);
        exit(false);
    end;

    local procedure DeleteMessage(var EmailLoggingMessage: Codeunit "Email Logging Message"): Boolean
    var
        ErrorMessage: Text;
    begin
        if TryDeleteMessage(EmailLoggingMessage) then
            exit(true);

        ErrorMessage := GetLastErrorText();
        EmailLoggingManagement.LogActivityFailed(ContextDeleteMessageTxt, ErrorMessage);
        exit(false);
    end;

    [TryFunction]
    local procedure TryArchiveMessage(var SourceEmailLoggingMessage: Codeunit "Email Logging Message"; var TargetEmailLoggingMessage: Codeunit "Email Logging Message")
    var
        TargetJsonObject: JsonObject;
    begin
        SetErrorContext(ContextArchiveMessageTxt);
        EmailLoggingAPIHelper.ArchiveMesage(SourceEmailLoggingMessage.GetId(), TargetJsonObject);
        TargetEmailLoggingMessage.Initialize(TargetJsonObject);
    end;

    [TryFunction]
    local procedure TryDeleteMessage(var EmailLoggingMessage: Codeunit "Email Logging Message")
    begin
        SetErrorContext(ContextDeleteMessageTxt);
        EmailLoggingAPIHelper.DeleteMesage(EmailLoggingMessage.GetId());
    end;

    internal procedure IsMessageAlreadyLogged(var EmailLoggingMessage: Codeunit "Email Logging Message"): Boolean
    var
        Attachment: Record Attachment;
        InternetMessageId: Text;
        MessageId: Text;
    begin
        InternetMessageId := EmailLoggingMessage.GetInternetMessageId();
        MessageId := EmailLoggingMessage.GetId();
        if InternetMessageId <> '' then
            Attachment.SetRange("Internet Message Checksum", Attachment.Checksum(InternetMessageId))
        else
            Attachment.SetRange("Email Message Checksum", Attachment.Checksum(MessageId));
        if Attachment.FindSet() then
            repeat
                if InternetMessageId <> '' then begin
                    if Attachment.GetInternetMessageID() = InternetMessageId then
                        exit(true);
                end else
                    if Attachment.GetMessageID() = MessageId then
                        exit(true);
            until (Attachment.Next() = 0);
        exit(false);
    end;

    local procedure GetSalespersonRecipients(var EmailLoggingMessage: Codeunit "Email Logging Message"; var SegmentLine: Record "Segment Line"): Boolean
    var
        RecipientList: List of [Text];
        RecipientAddress: Text;
    begin
        Session.LogMessage('0000FYQ', CollectSalespersonRecipientsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        RecipientList := EmailLoggingMessage.GetToAndCcRecipients();
        foreach RecipientAddress in RecipientList do
            if IsSalesperson(RecipientAddress, SegmentLine) then begin
                SegmentLine.Insert();
                SegmentLine."Line No." := SegmentLine."Line No." + 1;
            end;
        if not SegmentLine.IsEmpty() then begin
            Session.LogMessage('0000FYR', SalespersonRecipientsFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(true);
        end;

        Session.LogMessage('0000FYS', SalespersonRecipientsNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(false);
    end;

    local procedure GetContactRecipients(var EmailLoggingMessage: Codeunit "Email Logging Message"; var SegmentLine: Record "Segment Line"): Boolean
    var
        RecipientList: List of [Text];
        RecipientAddress: Text;
    begin
        Session.LogMessage('0000FYT', CollectContactRecipientsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        RecipientList := EmailLoggingMessage.GetToAndCcRecipients();
        foreach RecipientAddress in RecipientList do
            if IsContact(RecipientAddress, SegmentLine) then begin
                SegmentLine.Insert();
                SegmentLine."Line No." := SegmentLine."Line No." + 1;
            end;
        if not SegmentLine.IsEmpty() then begin
            Session.LogMessage('0000FYU', ContactRecipientsFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(true);
        end;

        Session.LogMessage('0000FYV', ContactRecipientsNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(false);
    end;

    internal procedure UpdateSegmentLine(var SegmentLine: Record "Segment Line"; Emails: Code[10]; var EmailLoggingMessage: Codeunit "Email Logging Message"; AttachmentNo: Integer)
    var
        LineDateTime: DateTime;
        InformationFlow: Integer;
    begin
        Session.LogMessage('0000FYW', UpdateMessageTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        InformationFlow := SegmentLine."Information Flow";
        SegmentLine.Validate("Interaction Template Code", Emails);
        SegmentLine."Information Flow" := InformationFlow;
        SegmentLine."Correspondence Type" := SegmentLine."Correspondence Type"::Email;
        SegmentLine.Description := CopyStr(EmailLoggingMessage.GetSubject(), 1, MaxStrLen(SegmentLine.Description));

        if SegmentLine."Information Flow" = SegmentLine."Information Flow"::Outbound then begin
            LineDateTime := EmailLoggingMessage.GetSentDateTime();
            SegmentLine."Initiated By" := SegmentLine."Initiated By"::Us;
        end else begin
            LineDateTime := EmailLoggingMessage.GetReceivedDateTime();
            SegmentLine."Initiated By" := SegmentLine."Initiated By"::Them;
        end;

        SegmentLine.Date := DT2Date(LineDateTime);
        SegmentLine."Time of Interaction" := DT2Time(LineDateTime);
        SegmentLine.Subject := CopyStr(EmailLoggingMessage.GetSubject(), 1, MaxStrLen(SegmentLine.Subject));
        SegmentLine."Attachment No." := AttachmentNo;
        SegmentLine.Modify();
    end;

    local procedure LogMessageAsInteraction(var SourceEmailLoggingMessage: Codeunit "Email Logging Message"; var TargetEmailLoggingMessage: Codeunit "Email Logging Message"; var SegmentLine: Record "Segment Line"; var Attachment: Record Attachment)
    var
        ErrorMessage: Text;
    begin
        if not LogMessageAsInteraction(SourceEmailLoggingMessage, TargetEmailLoggingMessage, SegmentLine, Attachment, ErrorMessage) then begin
            EmailLoggingManagement.LogActivityFailed(GetErrorContext(), StrSubstNo(MessageNotLoggedErr, ErrorMessage));
            Error(MessageNotLoggedErr, ErrorMessage);
        end;
        Commit();
    end;

    local procedure LogMessageAsInteraction(var SourceEmailLoggingMessage: Codeunit "Email Logging Message"; var TargetEmailLoggingMessage: Codeunit "Email Logging Message"; var SegmentLine: Record "Segment Line"; var Attachment: Record Attachment; var ErrorMessage: Text): Boolean
    var
        InteractionLogEntry: Record "Interaction Log Entry";
        EntryNumbers: List of [Integer];
        AttachmentNo: Integer;
        NextInteractionLogEntryNo: Integer;
        EmailArchiveError: Text;
        EmailDeleteError: Text;
    begin
        Session.LogMessage('0000FYX', LogMessageAsInteractionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        SetErrorContext(ContextLogInteractionTxt);

        if not SegmentLine.IsEmpty() then begin
            Session.LogMessage('0000FYY', NotEmptyRecipientTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

            Attachment.Reset();
            Attachment.LockTable();
            if Attachment.FindLast() then
                AttachmentNo := Attachment."No." + 1
            else
                AttachmentNo := 1;

            Attachment.Init();
            Attachment."No." := AttachmentNo;
            Attachment.Insert();

            SegmentLine.Reset();
            SegmentLine.FindSet(true);
            repeat
                UpdateSegmentLine(SegmentLine, GetInteractionTemplateSetupEmails(), SourceEmailLoggingMessage, Attachment."No.");
            until SegmentLine.Next() = 0;

            InteractionLogEntry.LockTable();
            if InteractionLogEntry.FindLast() then
                NextInteractionLogEntryNo := InteractionLogEntry."Entry No.";
            if SegmentLine.FindSet() then
                repeat
                    NextInteractionLogEntryNo := NextInteractionLogEntryNo + 1;
                    InsertInteractionLogEntry(SegmentLine, NextInteractionLogEntryNo);
                    EntryNumbers.Add(NextInteractionLogEntryNo);
                until SegmentLine.Next() = 0;
        end else
            Session.LogMessage('0000FYZ', EmptyRecipientTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        if Attachment."No." <> 0 then begin
            Session.LogMessage('0000FZ0', CopyMessageFromQueueToStorageFolderTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

            if ArchiveMessage(SourceEmailLoggingMessage, TargetEmailLoggingMessage) then begin
                Session.LogMessage('0000FZ1', MessageMovedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                LinkAttachmentToMessage(Attachment, TargetEmailLoggingMessage);
                exit(true);
            end;
            EmailArchiveError := GetLastErrorText();
            Session.LogMessage('0000FZ2', CannotArchiveMessageTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            if EmailArchiveError <> '' then
                Session.LogMessage('0000FZ3', StrSubstNo(CannotArchiveMessageDetailedTxt, GetLastErrorText(), GetLastErrorCallStack()), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

            if DeleteMessage(SourceEmailLoggingMessage) then begin
                Session.LogMessage('0000FZ4', MessageDeletedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                AddNoLinkContent(Attachment);
                AddNoLinkComment(EntryNumbers);
                exit(true);
            end;
            EmailDeleteError := GetLastErrorText();
            Session.LogMessage('0000FZ5', CannotDeleteMessageTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            if EmailDeleteError <> '' then
                Session.LogMessage('0000FZ6', StrSubstNo(CannotDeleteMessageDetailedTxt, GetLastErrorText(), GetLastErrorCallStack()), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

            ErrorMessage := EmailArchiveError;
        end;

        exit(false);
    end;

    local procedure LinkAttachmentToMessage(var Attachment: Record Attachment; var EmailLoggingMessage: Codeunit "Email Logging Message")
    var
        WebLink: Text;
    begin
        Attachment.LinkToMessage(EmailLoggingMessage.GetId(), '', true);
        Attachment.SetInternetMessageID(EmailLoggingMessage.GetInternetMessageId());
        WebLink := EmailLoggingMessage.GetWebLink();
        if WebLink <> '' then begin
            Session.LogMessage('0000FZ7', NotEmptyEmailMessageUrlTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            Attachment.SetEmailMessageUrl(WebLink);
        end else
            Session.LogMessage('0000FZ8', EmptyEmailMessageUrlTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        Attachment.Modify();
    end;

    local procedure AddNoLinkContent(var Attachment: Record Attachment)
    begin
        Attachment."Storage Type" := Attachment."Storage Type"::Embedded;
        Attachment."Read Only" := true;
        Attachment."File Extension" := TextFileExtentionTxt;
        Attachment.Write(NoLinkAttachmentMessageTxt);
        Attachment.Modify();
    end;

    local procedure AddNoLinkComment(var LogEntryNumbers: List of [Integer])
    var
        InterLogEntryCommentLine: Record "Inter. Log Entry Comment Line";
        EntryNo: Integer;
        LineNo: Integer;
    begin
        foreach EntryNo in LogEntryNumbers do begin
            InterLogEntryCommentLine.SetRange("Entry No.", EntryNo);
            if InterLogEntryCommentLine.FindLast() then
                LineNo := InterLogEntryCommentLine."Line No." + 10000
            else
                LineNo := 10000;
            InterLogEntryCommentLine.Init();
            InterLogEntryCommentLine."Entry No." := EntryNo;
            InterLogEntryCommentLine."Line No." := LineNo;
            InterLogEntryCommentLine.Date := WorkDate();
            InterLogEntryCommentLine.Comment := CopyStr(NoLinkCommentMessageTxt, 1, MaxStrLen(InterLogEntryCommentLine.Comment));
            InterLogEntryCommentLine.Insert();
        end;
    end;

    internal procedure InsertInteractionLogEntry(SegmentLine: Record "Segment Line"; EntryNo: Integer)
    var
        InteractionLogEntry: Record "Interaction Log Entry";
    begin
        Session.LogMessage('0000FZ9', InsertInteractionLogEntryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);

        InteractionLogEntry.Init();
        InteractionLogEntry."Entry No." := EntryNo;
        InteractionLogEntry."Correspondence Type" := InteractionLogEntry."Correspondence Type"::Email;
        InteractionLogEntry.CopyFromSegment(SegmentLine);
        InteractionLogEntry."E-Mail Logged" := true;
        InteractionLogEntry.Insert();
        Session.LogMessage('0000FZA', UserCreatingInteractionLogEntryBasedOnEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
    end;

    internal procedure IsSalesperson(Email: Text; var SegmentLine: Record "Segment Line"): Boolean
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        if Email = '' then begin
            Session.LogMessage('0000FZB', NotSalesPersonEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        if StrLen(Email) > MaxStrLen(SalespersonPurchaser."Search E-Mail") then begin
            Session.LogMessage('0000FZC', NotSalesPersonEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        SalespersonPurchaser.SetCurrentKey("Search E-Mail");
        SalespersonPurchaser.SetRange("Search E-Mail", Email);
        if SalespersonPurchaser.FindFirst() then begin
            Session.LogMessage('0000FZD', SalesPersonEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            SegmentLine."Salesperson Code" := SalespersonPurchaser.Code;
            exit(true);
        end;

        Session.LogMessage('0000FZE', NotSalesPersonEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(false);
    end;

    internal procedure IsContact(EMail: Text; var SegmentLine: Record "Segment Line"): Boolean
    var
        Contact: Record Contact;
        ContactAltAddress: Record "Contact Alt. Address";
    begin
        if EMail = '' then begin
            Session.LogMessage('0000FZF', NotContactEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        if StrLen(EMail) > MaxStrLen(Contact."Search E-Mail") then begin
            Session.LogMessage('0000FZG', NotContactEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        Contact.SetCurrentKey("Search E-Mail");
        Contact.SetRange("Search E-Mail", EMail);
        if Contact.FindFirst() then begin
            Session.LogMessage('0000FZH', ContactEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            SegmentLine."Contact No." := Contact."No.";
            SegmentLine."Contact Company No." := Contact."Company No.";
            SegmentLine."Contact Alt. Address Code" := '';
            exit(true);
        end;

        if StrLen(EMail) > MaxStrLen(ContactAltAddress."Search E-Mail") then begin
            Session.LogMessage('0000FZI', NotContactEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            exit(false);
        end;

        ContactAltAddress.SetCurrentKey("Search E-Mail");
        ContactAltAddress.SetRange("Search E-Mail", EMail);
        if ContactAltAddress.FindFirst() then begin
            Session.LogMessage('0000FZJ', ContactEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            SegmentLine."Contact No." := ContactAltAddress."Contact No.";
            Contact.Get(ContactAltAddress."Contact No.");
            SegmentLine."Contact Company No." := Contact."Company No.";
            SegmentLine."Contact Alt. Address Code" := ContactAltAddress.Code;
            exit(true);
        end;

        Session.LogMessage('0000FZK', NotContactEmailTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(false);
    end;

    local procedure GetInboundOutboundInteraction(var EmailLoggingMessage: Codeunit "Email Logging Message"; var SegmentLine: Record "Segment Line"): Boolean
    begin
        // Check if in- or out-bound and store sender and recipients in segment line(s)
        if IsSalesperson(EmailLoggingMessage.GetSender(), SegmentLine) then begin
            SegmentLine."Information Flow" := SegmentLine."Information Flow"::Outbound;
            if not GetContactRecipients(EmailLoggingMessage, SegmentLine) then begin
                Session.LogMessage('0000FZL', MessageNotInOutBoundInteractionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(false);
            end;
        end else
            if IsContact(EmailLoggingMessage.GetSender(), SegmentLine) then begin
                SegmentLine."Information Flow" := SegmentLine."Information Flow"::Inbound;
                if not GetSalespersonRecipients(EmailLoggingMessage, SegmentLine) then begin
                    Session.LogMessage('0000FZM', MessageNotInOutBoundInteractionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                    exit(false);
                end;
            end else begin
                Session.LogMessage('0000FZN', MessageNotInOutBoundInteractionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                exit(false);
            end;

        Session.LogMessage('0000FZO', MessageInOutBoundInteractionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
        exit(true);
    end;

    local procedure GetInteractionTemplateSetupEmails(): Code[10]
    var
        InteractionTemplateSetup: Record "Interaction Template Setup";
    begin
        if InteractionTemplateSetupEmails <> '' then
            exit(InteractionTemplateSetupEmails);
        InteractionTemplateSetup.Get();
        InteractionTemplateSetupEmails := InteractionTemplateSetup."E-Mails";
        exit(InteractionTemplateSetupEmails);
    end;

    internal procedure GetErrorContext(): Text
    begin
        exit(ErrorContext);
    end;

    local procedure SetErrorContext(NewContext: Text)
    begin
        ErrorContext := NewContext;
    end;
}