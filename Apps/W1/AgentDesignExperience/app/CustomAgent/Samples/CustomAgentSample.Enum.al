// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

enum 4353 "Custom Agent Sample" implements ICustomAgentSample, ICustomAgentSampleTaskTemplate
{
    // TODO(agent) change accessibility when opening up.
    Access = Internal;

    Extensible = true;
    DefaultImplementation = ICustomAgentSampleTaskTemplate = "Agent Sample No Task Template";
}