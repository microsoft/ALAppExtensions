// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>Holds information about draft emails and email that are about to be sent.</summary>
table 8888 "Email Outbox"
{
    Access = Public;
    Extensible = true;

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
        }

        field(3; "Account Id"; Guid)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
        }

        field(4; Connector; Enum "Email Connector")
        {
            Access = Internal;
            DataClassification = SystemMetadata;
        }

        field(5; "User Security Id"; Guid)
        {
            Access = Internal;
            DataClassification = EndUserPseudonymousIdentifiers;
        }

        field(6; Description; Text[2048])
        {
            Access = Internal;
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(8; Status; Enum "Email Status")
        {
            Access = Internal;
            DataClassification = SystemMetadata;
        }

        field(9; "Task Scheduler Id"; Guid)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
        }

        field(10; Sender; Code[50])
        {
            Access = Internal;
            FieldClass = FlowField;
            CalcFormula = Lookup(User."User Name" where("User Security ID" = field("User Security Id")));
        }

        field(11; "Date Queued"; DateTime)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
        }

        field(12; "Date Failed"; DateTime)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
        }

        field(13; "Send From"; Text[250])
        {
            Access = Internal;
            DataClassification = EndUserIdentifiableInformation;
        }

        field(14; "Error Message"; Text[2048])
        {
            Access = Internal;
            DataClassification = CustomerContent;
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
    }

    procedure GetMessageId(var MessageId: Guid)
    begin
        MessageId := Rec."Account Id";
    end;

    procedure GetAccountId(var AccountId: Guid)
    begin
        AccountId := Rec."Account Id";
    end;

    procedure GetUserSecurityId(var UserSecurityId: Guid)
    begin
        UserSecurityId := Rec."User Security Id";
    end;

    procedure GetConnector(): Enum "Email Connector"
    begin
        exit(Rec.Connector);
    end;

    procedure GetEmailStatus(): Enum "Email Status"
    begin
        exit(Rec.Status);
    end;

    procedure GetDescription(): Text[2048]
    begin
        exit(Rec.Description);
    end;

    procedure GetErrorMessage(): Text[2048]
    begin
        exit(Rec."Error Message");
    end;

    procedure GetDateQueued(): DateTime
    begin
        exit(Rec."Date Queued");
    end;

    procedure GetDateFailed(): DateTime
    begin
        exit(Rec."Date Failed");
    end;

    procedure GetSendFrom(): Text[250]
    begin
        exit(Rec."Send From");
    end;
}