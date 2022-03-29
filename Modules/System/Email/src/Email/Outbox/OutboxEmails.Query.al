// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Query to get all emails in the email outbox and their related records.
/// The query has an one to many relationship between email and the related records.
/// This file contains logic that is identical to the SendEmails.Query.al. 
/// If changes are made to this file, make sure to update SendEmails to.
/// </summary>
query 8888 "Outbox Emails"
{
    Access = Internal;
    QueryType = Normal;
    OrderBy = ascending(Message_Id);
    Permissions = tabledata "Email Outbox" = r,
                  tabledata "Email Related Record" = r;

    elements
    {
        dataitem(EmailOutbox; "Email Outbox")
        {
            /// <summary>
            /// Email outbox id
            /// </summary>
            column(Id; Id) { }

            /// <summary>
            /// Email message id
            /// </summary>
            column(Message_Id; "Message Id") { }

            /// <summary>
            /// User security id
            /// </summary>
            column(User_Security_Id; "User Security Id") { }

            /// <summary>
            /// Email account id
            /// </summary>
            filter(Account_Id; "Account Id") { }

            /// <summary>
            /// Email outbox status
            /// </summary>
            filter(Status; Status) { }

            dataitem(RelatedRecord; "Email Related Record")
            {
                DataItemLink = "Email Message Id" = EmailOutbox."Message Id";
                SqlJoinType = LeftOuterJoin;

                /// <summary>
                /// Table id for related record
                /// </summary>
                column(Table_Id; "Table Id") { }

                /// <summary>
                /// System id for related record
                /// </summary>
                column(System_Id; "System Id") { }

            }
        }
    }

    internal procedure GetOutboxEmails(var EmailOutbox: Record "Email Outbox" temporary)
    var
        EmailOutboxRecord: Record "Email Outbox";
    begin
        if not EmailOutbox.IsEmpty() then
            EmailOutbox.DeleteAll();

        CopyFiltersFrom(EmailOutbox);
        EmailOutbox.Reset();

        if Open() then;
        while Read() do
            if EmailOutboxRecord.Get(Id) then begin
                EmailOutbox.TransferFields(EmailOutboxRecord);
                // If then silences the error when trying to insert already inserted record! (The left join causes this)
                if EmailOutbox.Insert() then;
            end;
    end;

    internal procedure ReadUntilNextMessageId(CurrentMessageId: Guid) KeepReading: Boolean
    begin
        KeepReading := Read();
        while KeepReading do begin
            if CurrentMessageId <> Message_Id then
                exit;
            KeepReading := Read();
        end;
    end;

    internal procedure InsertRecordInto(var EmailOutbox: Record "Email Outbox" temporary)
    var
        EmailOutboxRecord: Record "Email Outbox";
    begin
        if EmailOutboxRecord.Get(Id) then begin
            EmailOutbox.TransferFields(EmailOutboxRecord);
            if EmailOutbox.Insert() then;
        end;
    end;

    internal procedure InsertRecordIfAnyRelatedRecords(var EmailOutbox: Record "Email Outbox" temporary) KeepReading: Boolean
    var
        EmailOutboxRecord: Record "Email Outbox";
        RecordRef: RecordRef;
        CurrentMessageId: Guid;
    begin
        KeepReading := true;
        CurrentMessageId := Message_Id;

        // First step is to process already loaded record
        if EmailOutboxRecord.Get(Id) then
            EmailOutbox.TransferFields(EmailOutboxRecord);

        // Keep reading until Read is false or we get a new message id
        // Stop as soon as we get a single permission on a related record
        while KeepReading do begin
            if CurrentMessageId <> Message_Id then
                exit;

            if (Table_Id <> 0) then begin
                RecordRef.Open(Table_Id);
                if RecordRef.ReadPermission() then begin
                    RecordRef.Close();
                    if EmailOutbox.Insert() then;
                    exit(ReadUntilNextMessageId(CurrentMessageId));
                end;
                RecordRef.Close();
            end;

            KeepReading := Read();
        end;
    end;

    internal procedure InsertRecordIfAllRelatedRecords(var EmailOutbox: Record "Email Outbox" temporary) KeepReading: Boolean
    var
        EmailOutboxRecord: Record "Email Outbox";
        RecordRef: RecordRef;
        CurrentMessageId: Guid;
        HadRelatedRecord: Boolean;
    begin
        HadRelatedRecord := false;
        KeepReading := true;
        CurrentMessageId := Message_Id;

        // First step is to process already loaded record
        if EmailOutboxRecord.Get(Id) then
            EmailOutbox.TransferFields(EmailOutboxRecord);

        // Keep reading until Read is false or we get a new message id
        while KeepReading do begin
            if (CurrentMessageId <> Message_Id) and HadRelatedRecord then begin
                if EmailOutbox.Insert() then;
                exit;
            end;

            if (Table_Id <> 0) then begin
                HadRelatedRecord := true;
                RecordRef.Open(Table_Id);
                if not RecordRef.ReadPermission() then begin
                    RecordRef.Close();
                    exit(ReadUntilNextMessageId(CurrentMessageId));
                end;
                RecordRef.Close();
            end;

            KeepReading := Read();
        end;

        // Post fence record. 
        // If Read returned false, then CurrentMessageId changed, but while ended 
        // and we therefore did not get the change to insert the record
        if HadRelatedRecord then
            if EmailOutbox.Insert() then;
    end;

    internal procedure GetOutboxEmailsIfAccessToAllRelatedRecords(var EmailOutbox: Record "Email Outbox" temporary)
    var
        KeepReading: Boolean;
        UserSecId: Guid;
    begin
        UserSecId := UserSecurityId();
        KeepReading := true;
        if not EmailOutbox.IsEmpty() then
            EmailOutbox.DeleteAll();
        CopyFiltersFrom(EmailOutbox);
        EmailOutbox.Reset();

        //
        // Each row returned in the SQL statement is read one at the time
        // We need to make sure that all related records to the same message id is accessible to the user
        //
        if Open() then;
        KeepReading := Read();
        while KeepReading do begin

            // If user is the owner of email we simply insert this sent email
            // And read until next message id 
            while User_Security_Id = UserSecId do begin
                InsertRecordInto(EmailOutbox);
                KeepReading := ReadUntilNextMessageId(Message_Id);
                if not KeepReading then
                    exit;
            end;

            // Process message and insert
            KeepReading := InsertRecordIfAllRelatedRecords(EmailOutbox);
        end;
    end;

    internal procedure GetOutboxEmailsIfAccessToAnyRelatedRecords(var EmailOutbox: Record "Email Outbox" temporary)
    var
        KeepReading: Boolean;
        UserSecId: Guid;
    begin
        UserSecId := UserSecurityId();
        KeepReading := true;
        if not EmailOutbox.IsEmpty() then
            EmailOutbox.DeleteAll();
        CopyFiltersFrom(EmailOutbox);
        EmailOutbox.Reset();

        //
        // Each row returned in the SQL statement is read one at the time
        // We need to make sure that any related records to the same message id is accessible to the user
        //
        if Open() then;
        KeepReading := Read();
        while KeepReading do begin

            // If user is the owner of email we simply insert this sent email
            // And read until next message id 
            while User_Security_Id = UserSecId do begin
                InsertRecordInto(EmailOutbox);
                KeepReading := ReadUntilNextMessageId(Message_Id);
                if not KeepReading then
                    exit;
            end;

            // Process message and insert
            KeepReading := InsertRecordIfAnyRelatedRecords(EmailOutbox);
        end;
    end;

    internal procedure CopyFiltersFrom(var EmailOutbox: Record "Email Outbox" temporary)
    begin
        SetFilter(Account_Id, EmailOutbox.GetFilter("Account Id"));
        SetFilter(Status, EmailOutbox.GetFilter(Status));
        SetFilter(User_Security_Id, EmailOutbox.GetFilter("User Security Id"));
    end;
}