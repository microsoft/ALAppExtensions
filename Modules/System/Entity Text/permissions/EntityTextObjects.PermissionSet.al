// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
permissionset 2010 "Entity Text - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = codeunit "Entity Text" = X,
        table "Azure OpenAi Settings" = X,
        table "Entity Text" = X,
        page "Azure OpenAi Settings" = X,
        page "Copilot Information" = X,
        page "Entity Text Factbox Part" = X,
        page "Entity Text Part" = X,
        page "Entity Text" = X;
}