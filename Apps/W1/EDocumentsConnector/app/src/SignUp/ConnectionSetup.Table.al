// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

table 6371 SignUpConnectionSetup
{
    DataPerCompany = false;

    fields
    {
        field(1; PK; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Authentication URL"; Text[250])
        {
            Caption = 'Authentication URL';
            DataClassification = CustomerContent;
        }
        field(9; "Company Id"; Text[100])
        {
            Caption = 'Company ID';
            DataClassification = CustomerContent;
        }
        field(10; "Client ID"; Guid)
        {
            Caption = 'Client ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(11; "Client Secret"; Guid)
        {
            Caption = 'Client Secret';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(12; "Send Mode"; Enum SignUpSendMode)
        {
            Caption = 'Send Mode';
            DataClassification = CustomerContent;
        }
        field(13; ServiceURL; Text[250])
        {
            Caption = 'Service URL';
            DataClassification = CustomerContent;
        }
        field(20; "Root App ID"; Guid)
        {
            Caption = 'Root App ID';
            DataClassification = CustomerContent;
        }
        field(21; "Root Secret"; Guid)
        {
            Caption = 'Root App Secret';
            DataClassification = CustomerContent;
        }
        field(22; "Root Tenant"; Guid)
        {
            Caption = 'Root App Tenant';
            DataClassification = CustomerContent;
        }
        field(23; "Root Market URL"; Guid)
        {
            Caption = 'Root Market URL';
            DataClassification = CustomerContent;
        }
        field(24; "Client Tenant"; Guid)
        {
            Caption = 'Client App Tenant';
            DataClassification = CustomerContent;
        } // "Access Token Due DateTime"
        field(30; "Client Token Due DateTime"; DateTime)
        {
            Caption = 'Client Token Timestamp';
            DataClassification = SystemMetadata;
        }
        field(31; "Root Token Due DateTime"; DateTime)
        {
            Caption = 'Root Token Timestamp';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; PK)
        {
            Clustered = true;
        }
    }

    var
        RecordHasBeenRead: Boolean;

    procedure GetRecordOnce(): Boolean
    begin
        if RecordHasBeenRead then
            exit(RecordHasBeenRead);
        Clear(Rec);
        RecordHasBeenRead := Get();
        exit(RecordHasBeenRead);
    end;
}