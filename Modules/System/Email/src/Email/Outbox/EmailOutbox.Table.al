// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>Holds information about draft emails and email that are about to be sent.</summary>
table 8888 "Email Outbox"
{
    Access = Public;
    Extensible = true;
    Description = 'The table is public so that it can also be extensible. The table is one of the modules''s extensibility endpoints.';

    fields
    {
        field(1; Id; BigInteger)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }

        field(2; "Message Id"; Guid)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
            TableRelation = "Email Message".Id;
            Description = 'The field is marked as internal in order to prevent modifying it from code.';
        }

        field(3; "Account Id"; Guid)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
            Description = 'The field is marked as internal in order to prevent modifying it from code.';
        }

        field(4; Connector; Enum "Email Connector")
        {
            Access = Internal;
            DataClassification = SystemMetadata;
            Description = 'The field is marked as internal in order to prevent modifying it from code.';
        }

        field(5; "User Security Id"; Guid)
        {
            Access = Internal;
            DataClassification = EndUserPseudonymousIdentifiers;
            Description = 'The field is marked as internal in order to prevent modifying it from code.';
        }

        field(6; Description; Text[2048])
        {
            Access = Internal;
            DataClassification = CustomerContent;
            Editable = false;
            Description = 'The field is marked as internal in order to prevent modifying it from code.';
        }

        field(8; Status; Enum "Email Status")
        {
            Access = Internal;
            DataClassification = SystemMetadata;
            Description = 'The field is marked as internal in order to prevent modifying it from code.';
        }

        field(9; "Task Scheduler Id"; Guid)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
            Description = 'The field is marked as internal in order to prevent modifying it from code.';
        }

        field(10; Sender; Code[50])
        {
            Access = Internal;
            FieldClass = FlowField;
            CalcFormula = Lookup(User."User Name" where("User Security ID" = field("User Security Id")));
            Description = 'The field is marked as internal in order to prevent modifying it from code.';
        }

        field(11; "Date Queued"; DateTime)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
            Description = 'The field is marked as internal in order to prevent modifying it from code.';
        }

        field(12; "Date Failed"; DateTime)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
            Description = 'The field is marked as internal in order to prevent modifying it from code.';
        }

        field(13; "Send From"; Text[250])
        {
            Access = Internal;
            DataClassification = EndUserIdentifiableInformation;
            Description = 'The field is marked as internal in order to prevent modifying it from code.';
        }

        field(14; "Error Message"; Text[2048])
        {
            Access = Internal;
            DataClassification = CustomerContent;
            Description = 'The field is marked as internal in order to prevent modifying it from code.';
        }

        field(15; "Date Sending"; DateTime)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
            Description = 'The field is marked as internal in order to prevent modifying it from code.';
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(MessageId; "Message Id")
        {
        }
        key(UserSecurityId; "User Security Id")
        {
        }
        key(Status; Status)
        {
        }
        key(StatusMessageId; "Message Id", Status)
        {
        }
    }

    /// <summary>
    /// Get the message id of the outbox email.
    /// </summary>
    /// <returns>Message id.</returns>
    procedure GetMessageId(): Guid
    begin
        exit(Rec."Message Id");
    end;

    /// <summary>
    /// Get the account id of the outbox email.
    /// </summary>
    /// <returns>Account id.</returns>
    procedure GetAccountId(): Guid
    begin
        exit(Rec."Account Id");
    end;

    /// <summary>
    /// The email connector of the outbox email.
    /// </summary>
    /// <returns>Email connector</returns>
    procedure GetConnector(): Enum "Email Connector"
    begin
        exit(Rec.Connector);
    end;
}