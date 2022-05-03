// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8900 "Email Impl"
{
    Access = Internal;
    Permissions = tabledata "Sent Email" = rimd,
                  tabledata "Email Outbox" = rimd,
                  tabledata "Email Related Record" = rid,
                  tabledata "Email Message" = r,
                  tabledata "Email Error" = r,
                  tabledata "Email Recipient" = r,
                  tabledata "Email View Policy" = r;

    var
        EmailMessageDoesNotExistMsg: Label 'The email message has been deleted by another user.';
        EmailMessageCannotBeEditedErr: Label 'The email message has already been sent and cannot be edited.';
        EmailMessageQueuedErr: Label 'The email has already been queued.';
        EmailMessageSentErr: Label 'The email has already been sent.';
        InvalidEmailAccountErr: Label 'The provided email account does not exist.';
        InsufficientPermissionsErr: Label 'You do not have the permissions required to send emails. Ask your administrator to grant you the Read, Insert, Modify and Delete permissions for the Sent Email and Email Outbox tables.';
        SourceRecordErr: Label 'Could not find the source for this email.';
        EmailViewPolicyLbl: Label 'Email View Policy', Locked = true;
        EmailViewPolicyUsedTxt: Label 'Email View Policy is used', Locked = true;
        EmailViewPolicyDefaultTxt: Label 'Falling back to default email view policy: %1', Locked = true;

    #region API

    procedure SaveAsDraft(EmailMessage: Codeunit "Email Message")
    var
        EmailOutbox: Record "Email Outbox";
    begin
        SaveAsDraft(EmailMessage, EmailOutbox);
    end;

    procedure SaveAsDraft(EmailMessage: Codeunit "Email Message"; var EmailOutbox: Record "Email Outbox")
    var
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmptyConnector: Enum "Email Connector";
        EmptyGuid: Guid;
    begin
        if not EmailMessageImpl.Get(EmailMessage.GetId()) then
            Error(EmailMessageDoesNotExistMsg);

        if GetEmailOutbox(EmailMessage.GetId(), EmailOutbox) and IsOutboxEnqueued(EmailOutbox) then
            exit;

        CreateOrUpdateEmailOutbox(EmailMessageImpl, EmptyGuid, EmptyConnector, Enum::"Email Status"::Draft, '', EmailOutbox);
    end;

    procedure SaveAsDraft(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector"; var EmailOutbox: Record "Email Outbox")
    var
        EmailAccountRecord: Record "Email Account";
        EmailMessageImpl: Codeunit "Email Message Impl.";
    begin
        if not EmailMessageImpl.Get(EmailMessage.GetId()) then
            Error(EmailMessageDoesNotExistMsg);

        if GetEmailOutbox(EmailMessage.GetId(), EmailOutbox) and IsOutboxEnqueued(EmailOutbox) then
            exit;

        // Get email account
        GetEmailAccount(EmailAccountId, EmailConnector, EmailAccountRecord);
        CreateOrUpdateEmailOutbox(EmailMessageImpl, EmailAccountId, EmailConnector, Enum::"Email Status"::Draft, EmailAccountRecord."Email Address", EmailOutbox);
    end;

    procedure Enqueue(EmailMessage: Codeunit "Email Message"; EmailScenario: Enum "Email Scenario"; NotBefore: DateTime)
    var
        EmailAccount: Record "Email Account";
        EmailScenarios: Codeunit "Email Scenario";
    begin
        EmailScenarios.GetEmailAccount(EmailScenario, EmailAccount);

        Enqueue(EmailMessage, EmailAccount."Account Id", EmailAccount.Connector, NotBefore);
    end;

    procedure Enqueue(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector"; NotBefore: DateTime)
    var
        EmailOutbox: Record "Email Outbox";
    begin
        Send(EmailMessage, EmailAccountId, EmailConnector, true, NotBefore, EmailOutbox);
    end;

    procedure Send(EmailMessage: Codeunit "Email Message"; EmailScenario: Enum "Email Scenario"): Boolean
    var
        EmailAccount: Record "Email Account";
        EmailScenarios: Codeunit "Email Scenario";
    begin
        EmailScenarios.GetEmailAccount(EmailScenario, EmailAccount);

        exit(Send(EmailMessage, EmailAccount."Account Id", EmailAccount.Connector));
    end;

    procedure Send(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector"): Boolean
    var
        EmailOutbox: Record "Email Outbox";
    begin
        exit(Send(EmailMessage, EmailAccountId, EmailConnector, false, CurrentDateTime(), EmailOutbox));
    end;

    procedure Send(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector"; var EmailOutbox: Record "Email Outbox"): Boolean
    begin
        exit(Send(EmailMessage, EmailAccountId, EmailConnector, false, CurrentDateTime(), EmailOutbox));
    end;

    procedure OpenInEditor(EmailMessage: Codeunit "Email Message"; EmailScenario: Enum "Email Scenario"; IsModal: Boolean): Enum "Email Action"
    var
        EmailAccount: Record "Email Account";
        EmailScenarios: Codeunit "Email Scenario";
    begin
        EmailScenarios.GetEmailAccount(EmailScenario, EmailAccount);

        exit(OpenInEditor(EmailMessage, EmailAccount."Account Id", EmailAccount.Connector, IsModal));
    end;

    procedure OpenInEditor(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector"; IsModal: Boolean): Enum "Email Action"
    var
        EmailOutbox: Record "Email Outbox";
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmailEditor: Codeunit "Email Editor";
        IsNew, IsEnqueued : Boolean;
    begin
        if not EmailMessageImpl.Get(EmailMessage.GetId()) then
            Error(EmailMessageDoesNotExistMsg);

        if EmailMessageImpl.IsRead() then
            Error(EmailMessageCannotBeEditedErr);

        IsNew := not GetEmailOutbox(EmailMessageImpl.GetId(), EmailOutbox);
        IsEnqueued := (not IsNew) and IsOutboxEnqueued(EmailOutbox);

        if not IsEnqueued then begin
            // Modify the outbox only if it hasn't been enqueued yet
            CreateOrUpdateEmailOutbox(EmailMessageImpl, EmailAccountId, EmailConnector, Enum::"Email Status"::Draft, '', EmailOutbox);

            // Set the record as new so that there is a save prompt and no arrows
            EmailEditor.SetAsNew();
        end;

        exit(EmailEditor.Open(EmailOutbox, IsModal));
    end;

    local procedure GetEmailOutbox(EmailMessageId: Guid; var EmailOutbox: Record "Email Outbox"): Boolean
    begin
        EmailOutbox.SetRange("Message Id", EmailMessageId);
        exit(EmailOutbox.FindFirst());
    end;

    local procedure IsOutboxEnqueued(EmailOutbox: Record "Email Outbox"): Boolean
    begin
        exit((EmailOutbox.Status in [Enum::"Email Status"::Queued, Enum::"Email Status"::Processing]));
    end;

    local procedure EmailMessageSent(EmailMessageId: Guid): Boolean
    var
        SentEmail: Record "Sent Email";
    begin
        SentEmail.SetRange("Message Id", EmailMessageId);
        exit(not SentEmail.IsEmpty());
    end;

    local procedure Send(EmailMessage: Codeunit "Email Message"; EmailAccountId: Guid; EmailConnector: Enum "Email Connector"; InBackground: Boolean; NotBefore: DateTime; var EmailOutbox: Record "Email Outbox"): Boolean
    var
        EmailAccountRec: Record "Email Account";
        CurrentUser: Record User;
        Email: Codeunit "Email";
        EmailMessageImpl: Codeunit "Email Message Impl.";
        EmailDispatcher: Codeunit "Email Dispatcher";
        TaskId: Guid;
    begin
        CheckRequiredPermissions();

        if not EmailMessageImpl.Get(EmailMessage.GetId()) then
            Error(EmailMessageDoesNotExistMsg);

        if EmailMessageSent(EmailMessage.GetId()) then
            Error(EmailMessageSentErr);

        EmailMessageImpl.ValidateRecipients();

        if GetEmailOutbox(EmailMessage.GetId(), EmailOutbox) and IsOutboxEnqueued(EmailOutbox) then
            Error(EmailMessageQueuedErr);

        // Get email account
        GetEmailAccount(EmailAccountId, EmailConnector, EmailAccountRec);

        // Add user as an related entity on email
        if CurrentUser.Get(UserSecurityId()) then
            Email.AddRelation(EmailMessage, Database::User, CurrentUser.SystemId, Enum::"Email Relation Type"::"Related Entity", Enum::"Email Relation Origin"::"Compose Context");

        CreateOrUpdateEmailOutbox(EmailMessageImpl, EmailAccountId, EmailConnector, Enum::"Email Status"::Queued, EmailAccountRec."Email Address", EmailOutbox);
        Email.OnEnqueuedInOutbox(EmailMessage.GetId());

        if InBackground then begin
            TaskId := TaskScheduler.CreateTask(Codeunit::"Email Dispatcher", Codeunit::"Email Error Handler", true, CompanyName(), NotBefore, EmailOutbox.RecordId());
            EmailOutbox."Task Scheduler Id" := TaskId;
            EmailOutbox."Date Sending" := NotBefore;
            EmailOutbox.Modify();
        end else begin // Send the email in foreground
            Commit();

            if EmailDispatcher.Run(EmailOutbox) then;
            exit(EmailDispatcher.GetSuccess());
        end;
    end;

    local procedure GetEmailAccount(EmailAccountIdGuid: Guid; EmailConnectorEnum: Enum "Email Connector"; var EmailAccountRecord: Record "Email Account")
    var
        EmailAccount: Codeunit "Email Account";
    begin
        EmailAccount.GetAllAccounts(false, EmailAccountRecord);
        if not EmailAccountRecord.Get(EmailAccountIdGuid, EmailConnectorEnum) then
            Error(InvalidEmailAccountErr);
    end;

    local procedure CreateOrUpdateEmailOutbox(EmailMessageImpl: Codeunit "Email Message Impl."; AccountId: Guid; EmailConnector: Enum "Email Connector"; Status: Enum "Email Status"; SentFrom: Text; var EmailOutbox: Record "Email Outbox")
    begin
        if not GetEmailOutbox(EmailMessageImpl.GetId(), EmailOutbox) then begin
            EmailOutbox."Message Id" := EmailMessageImpl.GetId();
            EmailOutbox.Insert();
        end;

        EmailOutbox.Connector := EmailConnector;
        EmailOutbox."Account Id" := AccountId;
        EmailOutbox.Description := CopyStr(EmailMessageImpl.GetSubject(), 1, MaxStrLen(EmailOutbox.Description));
        EmailOutbox."User Security Id" := UserSecurityId();
        EmailOutbox."Send From" := CopyStr(SentFrom, 1, MaxStrLen(EmailOutbox."Send From"));
        EmailOutbox.Status := Status;
        if Status = Enum::"Email Status"::Queued then begin
            EmailOutbox."Date Queued" := CurrentDateTime();
            EmailOutbox."Date Sending" := CurrentDateTime();
        end;
        EmailOutbox.Modify();
    end;

    #endregion

    procedure FindLastErrorCallStack(EmailOutboxId: BigInteger): Text
    var
        EmailError: Record "Email Error";
        ErrorInstream: InStream;
        ErrorText: Text;
    begin
        EmailError.SetRange("Outbox Id", EmailOutboxId);
        EmailError.FindLast();
        EmailError.CalcFields(EmailError."Error Callstack");
        EmailError."Error Callstack".CreateInStream(ErrorInstream, TextEncoding::UTF8);
        ErrorInstream.ReadText(ErrorText);
        exit(ErrorText);
    end;

    procedure ShowSourceRecord(EmailMessageId: Guid);
    var
        EmailRelatedRecord: Record "Email Related Record";
        Email: Codeunit Email;
        EmailRelationPicker: Page "Email Relation Picker";
        IsHandled: Boolean;
    begin
        EmailRelatedRecord.SetRange("Email Message Id", EmailMessageId);

        if not EmailRelatedRecord.FindFirst() then
            Error(SourceRecordErr);

        if EmailRelatedRecord.Count() > 1 then begin
            FilterRemovedSourceRecords(EmailRelatedRecord);
            EmailRelationPicker.SetTableView(EmailRelatedRecord);
            EmailRelationPicker.LookupMode(true);
            if EmailRelationPicker.RunModal() <> Action::LookupOK then
                exit;
            EmailRelationPicker.GetRecord(EmailRelatedRecord);
        end;

        Email.OnShowSource(EmailRelatedRecord."Table Id", EmailRelatedRecord."System Id", IsHandled);

        if not IsHandled then
            Error(SourceRecordErr);
    end;

    procedure HasSourceRecord(EmailMessageId: Guid): Boolean;
    var
        EmailRelatedRecord: Record "Email Related Record";
    begin
        EmailRelatedRecord.SetRange("Email Message Id", EmailMessageId);
        exit(not EmailRelatedRecord.IsEmpty());
    end;

    procedure FilterRemovedSourceRecords(var EmailRelatedRecord: Record "Email Related Record")
    var
        AllObj: Record AllObj;
        SourceRecordRef: RecordRef;
    begin
        repeat
            if AllObj.Get(AllObj."Object Type"::Table, EmailRelatedRecord."Table Id") then begin
                SourceRecordRef.Open(EmailRelatedRecord."Table Id");
                if SourceRecordRef.ReadPermission() then
                    if SourceRecordRef.GetBySystemId(EmailRelatedRecord."System Id") then
                        EmailRelatedRecord.Mark(true);
                SourceRecordRef.Close();
            end;
        until EmailRelatedRecord.Next() = 0;
        EmailRelatedRecord.MarkedOnly(true);
    end;

    procedure GetSentEmailsForRecord(RecordVariant: Variant; var ResultSentEmails: Record "Sent Email" temporary)
    var
        RecordRef: RecordRef;
    begin
        if GetRecordRef(RecordVariant, RecordRef) then
            GetSentEmailsForRecord(RecordRef.Number, RecordRef.Field(RecordRef.SystemIdNo).Value, ResultSentEmails);
    end;

    procedure GetSentEmailsForRecord(TableId: Integer; SystemId: Guid; var ResultSentEmails: Record "Sent Email" temporary)
    var
        NullGuid: Guid;
        NullDate: DateTime;
    begin
        GetSentEmails(NullGuid, NullDate, TableId, SystemId, ResultSentEmails);
    end;

    procedure GetSentEmails(AccountId: Guid; NewerThan: DateTime; var SentEmails: Record "Sent Email" temporary)
    var
        NullGuid: Guid;
    begin
        GetSentEmails(AccountId, NewerThan, 0, NullGuid, SentEmails);
    end;

    procedure GetSentEmails(AccountId: Guid; NewerThan: DateTime; SourceTableID: Integer; SourceSystemID: Guid; var SentEmails: Record "Sent Email" temporary)
    var
        EmailViewPolicy: Interface "Email View Policy";
    begin
        if not SentEmails.IsEmpty() then
            SentEmails.DeleteAll();

        if not IsNullGuid(AccountId) then
            SentEmails.SetRange("Account Id", AccountId);

        if NewerThan <> 0DT then
            SentEmails.SetRange("Date Time Sent", NewerThan, System.CurrentDateTime());

        EmailViewPolicy := GetUserEmailViewPolicy();

        if SourceTableID <> 0 then
            if IsNullGuid(SourceSystemID) then
                EmailViewPolicy.GetSentEmails(SourceTableID, SentEmails)
            else
                EmailViewPolicy.GetSentEmails(SourceTableID, SourceSystemID, SentEmails)
        else
            EmailViewPolicy.GetSentEmails(SentEmails);
    end;

    procedure RefreshEmailOutboxForUser(EmailAccountId: Guid; EmailStatus: Enum "Email Status"; var EmailOutboxForUser: Record "Email Outbox" temporary)
    begin
        GetOutboxEmails(EmailAccountId, EmailStatus, EmailOutboxForUser);
    end;

    procedure GetOutboxEmails(AccountId: Guid; EmailStatus: Enum "Email Status"; var EmailOutboxForUser: Record "Email Outbox" temporary)
    var
        NullGuid: Guid;
    begin
        GetOutboxEmails(AccountId, EmailStatus, 0, NullGuid, EmailOutboxForUser);
    end;

    procedure GetOutboxEmails(AccountId: Guid; EmailStatus: Enum "Email Status"; SourceTableID: Integer; SourceSystemID: Guid; var EmailOutboxForUser: Record "Email Outbox" temporary)
    var
        EmailViewPolicy: Interface "Email View Policy";
    begin
        if not EmailOutboxForUser.IsEmpty() then
            EmailOutboxForUser.DeleteAll();

        if not IsNullGuid(AccountId) then
            EmailOutboxForUser.SetRange("Account Id", AccountId);

        if EmailStatus.AsInteger() <> 0 then
            EmailOutboxForUser.SetRange(Status, EmailStatus);

        EmailViewPolicy := GetUserEmailViewPolicy();

        if SourceTableID <> 0 then
            if IsNullGuid(SourceSystemID) then
                EmailViewPolicy.GetOutboxEmails(SourceTableID, EmailOutboxForUser)
            else
                EmailViewPolicy.GetOutboxEmails(SourceTableID, SourceSystemID, EmailOutboxForUser)
        else
            EmailViewPolicy.GetOutboxEmails(EmailOutboxForUser);
    end;

    procedure GetEmailOutboxForRecord(RecordVariant: Variant; var ResultEmailOutbox: Record "Email Outbox" temporary)
    var
        RecordRef: RecordRef;
    begin
        if GetRecordRef(RecordVariant, RecordRef) then
            GetEmailOutboxForRecord(RecordRef.Number, RecordRef.Field(RecordRef.SystemIdNo).Value, ResultEmailOutbox);
    end;

    procedure GetEmailOutboxForRecord(TableId: Integer; SystemId: Guid; var ResultEmailOutbox: Record "Email Outbox" temporary)
    var
        NullGuid: Guid;
    begin
        GetOutboxEmails(NullGuid, Enum::"Email Status"::" ", TableId, SystemId, ResultEmailOutbox);
    end;

    procedure GetOutboxEmailRecordStatus(MessageId: Guid) ResultStatus: Enum "Email Status"
    var
        TempEmailOutboxRecord: Record "Email Outbox" temporary;
        NullGuid: Guid;
    begin
        GetOutboxEmails(NullGuid, Enum::"Email Status"::" ", TempEmailOutboxRecord);
        TempEmailOutboxRecord.SetRange("Message Id", MessageId);
        TempEmailOutboxRecord.FindFirst();
        exit(TempEmailOutboxRecord.Status);
    end;

    internal procedure GetUserEmailViewPolicy() Result: Enum "Email View Policy"
    var
        EmailViewPolicy: Record "Email View Policy";
        Telemetry: Codeunit Telemetry;
        NullGuid: Guid;
    begin
        //Try get the user's view policy
        if EmailViewPolicy.Get(UserSecurityId()) then begin
            EmitUsedTelemetry(EmailViewPolicy);
            exit(EmailViewPolicy."Email View Policy");
        end;

        // Try get the default view policy
        if EmailViewPolicy.Get(NullGuid) then begin
            EmitUsedTelemetry(EmailViewPolicy);
            exit(EmailViewPolicy."Email View Policy");
        end;

        // Fallback to "Own emails" if email view policy has not been configured
        Result := Enum::"Email View Policy"::OwnEmails;

        Telemetry.LogMessage('0000GPE', StrSubstNo(EmailViewPolicyDefaultTxt, Result.AsInteger()), Verbosity::Normal, DataClassification::SystemMetadata);
        exit(Result);
    end;

    internal procedure CountEmailsInOutbox(EmailStatus: Enum "Email Status"; IsAdmin: Boolean): Integer
    var
        TempEmailOutboxRecord: Record "Email Outbox" temporary;
        NullGuid: Guid;
    begin
        GetOutboxEmails(NullGuid, EmailStatus, TempEmailOutboxRecord);
        exit(TempEmailOutboxRecord.Count());
    end;

    internal procedure CountSentEmails(NewerThan: DateTime; IsAdmin: Boolean): Integer
    var
        TempSentEmailsRecord: Record "Sent Email" temporary;
        NullGuid: Guid;
    begin
        GetSentEmails(NullGuid, NewerThan, TempSentEmailsRecord);
        exit(TempSentEmailsRecord.Count());
    end;

    procedure AddRelation(EmailMessage: Codeunit "Email Message"; TableId: Integer; SystemId: Guid; RelationType: Enum "Email Relation Type"; Origin: Enum "Email Relation Origin")
    var
        Email: Codeunit Email;
        RelatedRecord: Dictionary of [Integer, List of [Guid]];
        RelatedRecordTableIds: List of [Integer];
        RelatedRecordSystemIds: List of [Guid];
        RelatedRecordTableId: Integer;
        TableIdCount, SystemIdCount : Integer;
    begin
        AddRelation(EmailMessage.GetId(), TableId, SystemId, RelationType, Origin);
        Email.OnAfterAddRelation(EmailMessage.GetId(), TableId, SystemId, RelatedRecord);

        RelatedRecordTableIds := RelatedRecord.Keys();
        for TableIdCount := 1 to RelatedRecordTableIds.Count() do begin
            RelatedRecordTableId := RelatedRecordTableIds.Get(TableIdCount);
            RelatedRecordSystemIds := RelatedRecord.Get(RelatedRecordTableId);
            for SystemIdCount := 1 to RelatedRecordSystemIds.Count() do
                AddRelation(EmailMessage.GetId(), RelatedRecordTableId, RelatedRecordSystemIds.Get(SystemIdCount), Enum::"Email Relation Type"::"Related Entity", Origin);
        end;
    end;

    procedure AddRelation(EmailMessageId: Guid; TableId: Integer; SystemId: Guid; RelationType: Enum "Email Relation Type"; Origin: Enum "Email Relation Origin")
    var
        EmailRelatedRecord: Record "Email Related Record";
    begin
        if EmailRelatedRecord.Get(TableId, SystemId, EmailMessageId) then
            exit;

        EmailRelatedRecord."Email Message Id" := EmailMessageId;
        EmailRelatedRecord."Table Id" := TableId;
        EmailRelatedRecord."System Id" := SystemId;
        EmailRelatedRecord."Relation Type" := RelationType;
        EmailRelatedRecord."Relation Origin" := Origin;
        EmailRelatedRecord.Insert();
    end;

    procedure RemoveRelation(EmailMessage: Codeunit "Email Message"; TableId: Integer; SystemId: Guid): Boolean
    var
        EmailRelatedRecord: Record "Email Related Record";
        Email: Codeunit Email;
    begin
        if EmailRelatedRecord.Get(EmailMessage.GetId(), TableId, SystemId) then
            if EmailRelatedRecord.Delete() then begin
                Email.OnAfterRemoveRelation(EmailMessage.GetId(), TableId, SystemId);
                exit(true);
            end;
        exit(false);
    end;

    procedure OpenSentEmails(RecordVariant: Variant)
    var
        RecordRef: RecordRef;
    begin
        if GetRecordRef(RecordVariant, RecordRef) then
            OpenSentEmails(RecordRef.Number, RecordRef.Field(RecordRef.SystemIdNo).Value);
    end;

    procedure OpenSentEmails(TableId: Integer; SystemId: Guid)
    var
        SentEmails: Page "Sent Emails";
    begin
        SentEmails.SetRelatedRecord(TableId, SystemId);
        SentEmails.Run();
    end;

    internal procedure GetRecordRef(RecRelatedVariant: Variant; var ResultRecordRef: RecordRef): Boolean
    var
        RecID: RecordID;
    begin
        case true of
            RecRelatedVariant.IsRecord:
                ResultRecordRef.GetTable(RecRelatedVariant);
            RecRelatedVariant.IsRecordRef:
                ResultRecordRef := RecRelatedVariant;
            RecRelatedVariant.IsRecordId:
                begin
                    RecID := RecRelatedVariant;
                    if RecID.TableNo = 0 then
                        exit(false);
                    if not ResultRecordRef.Get(RecID) then
                        ResultRecordRef.Open(RecID.TableNo);
                end;
            else
                exit(false);
        end;
        exit(true);
    end;

    local procedure CheckRequiredPermissions()
    var
        SentEmail: Record "Sent Email";
        EmailOutBox: Record "Email Outbox";
    begin
        if not SentEmail.ReadPermission() or
                not SentEmail.WritePermission() or
                not EmailOutBox.ReadPermission() or
                not EmailOutBox.WritePermission() then
            Error(InsufficientPermissionsErr);
    end;

    #region Telemetry
    local procedure EmitUsedTelemetry(EmailViewPolicy: Record "Email View Policy")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GO9', EmailViewPolicyLbl, Enum::"Feature Uptake Status"::Used, false, GetTelemetryDimensions(EmailViewPolicy));

        FeatureTelemetry.LogUsage('0000GPD', EmailViewPolicyLbl, EmailViewPolicyUsedTxt, GetTelemetryDimensions(EmailViewPolicy));
    end;

    [EventSubscriber(ObjectType::Page, Page::"Email View Policy List", 'OnOpenPageEvent', '', false, false)]
    local procedure EmitDiscoveredTelemetryOnListPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GOA', EmailViewPolicyLbl, Enum::"Feature Uptake Status"::Discovered);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Email View Policy", 'OnAfterInsertEvent', '', false, false)]
    local procedure EmitSetupTelemetry(var Rec: Record "Email View Policy")
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000GOB', EmailViewPolicyLbl, Enum::"Feature Uptake Status"::"Set up", false, GetTelemetryDimensions(Rec));
    end;

    local procedure GetTelemetryDimensions(EmailViewPolicy: Record "Email View Policy") TelemetryDimensions: Dictionary of [Text, Text]
    var
        Language: Codeunit Language;
        CurrentLanguage: Integer;
    begin
        CurrentLanguage := GlobalLanguage();
        GlobalLanguage(Language.GetDefaultApplicationLanguageId());

        TelemetryDimensions.Add('IsDefault', Format(IsNullGuid(EmailViewPolicy."User Security ID")));
        TelemetryDimensions.Add('ViewPolicy', Format(EmailViewPolicy."Email View Policy"));

        GlobalLanguage(CurrentLanguage);
    end;
    #endregion
}
