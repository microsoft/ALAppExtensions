// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The rate limits for email accounts.
/// </summary>
table 8912 "Email Rate Limit"
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;

    fields
    {
        field(1; "Account Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Email Address"; Text[2048])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Rate Limit"; Integer)
        {
            DataClassification = SystemMetadata;
            MinValue = 0;
        }
        field(4; Connector; Enum "Email Connector")
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Account Id", Connector)
        {
            Clustered = true;
        }
        key(Name; "Email Address")
        {
            Description = 'Used for sorting by Email Address.';
        }
    }
}