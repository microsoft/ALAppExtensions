// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

/// <summary>
/// Default implementation of ICustomAgentSampleTaskTemplate that provides no task templates.
/// </summary>
codeunit 4367 "Agent Sample No Task Template" implements ICustomAgentSampleTaskTemplate
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetTaskTemplateCode(): Code[20]
    begin
        exit('');
    end;

    procedure GetTaskTemplateDefinition(var TaskTemplateOutStream: OutStream)
    begin
    end;

    procedure GetTaskTemplatePlaceholdersMap() PlaceholdersMap: Dictionary of [Text, Text]
    begin
    end;
}
