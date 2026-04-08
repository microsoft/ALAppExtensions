// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.AgentSamples.SalesValidation;

using System.Agents.Designer.CustomAgent;

enumextension 4450 "Sales Validation Agent Sample" extends "Custom Agent Sample"
{
    value(4450; "Sales Validation")
    {
        Caption = 'Sales Validation';
        Implementation =
            ICustomAgentSample = "Sales Validation Agent",
            ICustomAgentSampleTaskTemplate = "Sales Validation Agent";
    }
}
