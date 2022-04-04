// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>Holds information about the sent emails.</summary>
table 8889 "Sent Email"
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
            Description = 'The field is marked as internal in order to prevent modifying it from code.';
        }

        field(7; "Date Time Sent"; DateTime)
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

        field(13; "Sent From"; Text[250])
        {
            Access = Internal;
            DataClassification = CustomerContent;
            Description = 'The field is marked as internal in order to prevent modifying it from code.';
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
        key(FiltersKey; "Account Id", "User Security Id", "Date Time Sent")
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
    /// Get the message id of the sent email.
    /// </summary>
    /// <returns>Message id.</returns>
    procedure GetMessageId(): Guid
    begin
        exit(Rec."Message Id");
    end;

}