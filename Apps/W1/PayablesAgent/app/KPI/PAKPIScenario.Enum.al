// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

enum 3303 "PA KPI Scenario"
{
    value(0; "Agent Tasks Received")
    {
        Caption = 'Agent Tasks Received';
    }
    value(1; "Agent E-Docs Finalized by Agent")
    {
        Caption = 'Agent E-Documents Finalized by Agent';
    }
    value(2; "Agent E-Docs Finalized by User")
    {
        Caption = 'Agent E-Documents Finalized by User';
    }
}