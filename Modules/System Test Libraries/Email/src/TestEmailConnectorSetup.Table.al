// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 134687 "Test Email Connector Setup"
{
    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Primary Key';
        }
        field(2; "Fail On Send"; Boolean)
        {
            Caption = 'Fail On Send';
        }
        field(3; "Fail On Register Account"; Boolean)
        {
            Caption = 'Fail On Register Account';
        }
        field(4; "Unsuccessful Register"; Boolean)
        {
            Caption = 'Unsuccessful Register';
        }
        field(5; "Email Message ID"; Guid)
        {
            Caption = 'Email Message ID';
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
}
