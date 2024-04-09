// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Registration;

#pragma warning disable AL0659
enum 11746 "Reg. Log Detailed Field Status CZL"
#pragma warning restore AL0659
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "Not Valid")
    {
        Caption = 'Not Valid';
    }
    value(1; Accepted)
    {
        Caption = 'Accepted';
    }
    value(2; Applied)
    {
        Caption = 'Applied';
    }
    value(3; Valid)
    {
        Caption = 'Valid';
    }
}
