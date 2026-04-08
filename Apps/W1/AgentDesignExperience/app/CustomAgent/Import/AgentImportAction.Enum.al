// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

enum 4350 "Agent Import Action"
{
    Extensible = false;
    Access = Internal;

    value(0; Add)
    {
        Caption = 'Add';
    }
    value(1; Replace)
    {
        Caption = 'Replace';
    }
}