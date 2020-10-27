// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>Holds information about the sent emails.</summary>
table 8889 "Sent Email"
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
        }

        field(7; "Date Time Sent"; DateTime)
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

        field(13; "Sent From"; Text[250])
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
        key(Message; "Message Id")
        {
        }
        key(UserSecurityId; "User Security Id")
        {
        }
        key(DateTimeSent; "Date Time Sent")
        {
        }
    }



    /// <summary>
    /// Returns the "Message Id" of the Sent Email Entry
    /// </summary>
    procedure GetMessageId(): Guid
    begin
        exit(Rec."Message Id");
    end;

    /// <summary>
    /// Returns the "Account Id" of the Sent Email Entry
    /// </summary>
    procedure GetAccountId(): Guid
    begin
        exit(Rec."Account Id");
    end;

    /// <summary>
    /// Returns the "User Security Id" of the Sent Email Entry
    /// </summary>
    procedure GetUserSecurityId(): Guid
    begin
        exit(Rec."User Security Id");
    end;

    /// <summary>
    /// Returns the "Connector" of the Sent Email Entry
    /// </summary>
    procedure GetConnector(): Enum "Email Connector"
    begin
        exit(Rec.Connector);
    end;

    /// <summary>
    /// Returns the "Description" of the Sent Email Entry
    /// </summary>
    procedure GetDescription(): Text[2048]
    begin
        exit(Rec.Description);
    end;

    /// <summary>
    /// Returns the "Date Time Sent" of the Sent Email Entry
    /// </summary>
    procedure GetDateTimeSent(): DateTime
    begin
        exit(Rec."Date Time Sent");
    end;

    /// <summary>
    /// Returns the "Sent From" of the Sent Email Entry
    /// </summary>
    procedure GetSentFrom(): Text[250]
    begin
        exit(Rec."Sent From");
    end;
}