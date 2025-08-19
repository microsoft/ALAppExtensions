// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

table 6126 "E-Document Notification"
{
    Access = Internal;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    DataClassification = SystemMetadata;
    ReplicateData = false;

    fields
    {
        field(1; "E-Document Entry No."; Integer)
        {
            Caption = 'E-Document Entry No.';
            ToolTip = 'Specifies the unique identifier for the E-Document.';
        }
        field(2; ID; Guid)
        {
            ToolTip = 'Specifies the unique identifier for the E-Document notification.';
        }
        field(3; "User Id"; Code[50])
        {
            Caption = 'User Id';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            NotBlank = true;
        }
        field(4; Type; Enum "E-Document Notification Type")
        {
            ToolTip = 'Specifies the type of the E-Document notification.';
        }
        field(5; Message; Text[1024])
        {
            Caption = 'Message';
            ToolTip = 'Specifies the message of the E-Document notification.';
        }
    }
    keys
    {
        key(PK; "E-Document Entry No.", ID, "User Id")
        {
            Clustered = true;
        }
    }
}