// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

enum 11741 "EET Status CZL"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "Created")
    {
        Caption = 'Created';
    }
    value(1; "Send Pending")
    {
        Caption = 'Send Pending';
    }
    value(2; Sent)
    {
        Caption = 'Sent';
    }
    value(3; "Failure")
    {
        Caption = 'Failure';
    }
    value(4; "Success")
    {
        Caption = 'Success';
    }
    value(5; "Success with Warnings")
    {
        Caption = 'Success with Warnings';
    }
    value(6; "Sent to Verification")
    {
        Caption = 'Sent to Verification';
    }
    value(7; "Verified")
    {
        Caption = 'Verified';
    }
    value(8; "Verified with Warnings")
    {
        Caption = 'Verified with Warnings';
    }
}
