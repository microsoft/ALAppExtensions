// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Agent.SalesOrderAgent;

enum 4593 "SOA Input Message Review"
{
    Access = Internal;
    Extensible = false;

    value(0; "All Messages")
    {
        Caption = 'All';
    }
    value(1; "First Message")
    {
        Caption = 'First message in a conversation';
    }
    value(2; "No Review")
    {
        Caption = 'No review (advanced)';
    }
}