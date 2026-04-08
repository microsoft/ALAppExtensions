// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

enum 4352 "Agent Template Type"
{
    Extensible = true;
    Access = Internal;

    value(0; "All")
    {
        Caption = 'All';
    }
    value(1; "Agent Task Template")
    {
        Caption = 'Agent Task Template';
    }
    value(2; "Agent Message Template")
    {
        Caption = 'Agent Message Template';
    }
}