// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

enum 4351 "Agent Import Diag Severity"
{
    Extensible = false;
    Access = Internal;

    value(0; Hidden)
    {
        Caption = 'Hidden';
    }
    value(1; Error)
    {
        Caption = 'Error';
    }
    value(2; Warning)
    {
        Caption = 'Warning';
    }
    value(3; Information)
    {
        Caption = 'Information';
    }
}