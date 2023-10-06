// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Text;

permissionset 2010 "Entity Text - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Entity Text" = X,
                  Table "Azure OpenAi Settings" = X,
                  Table "Entity Text" = X,
                  Page "Azure OpenAi Settings" = X,
                  Page "Copilot Information" = X,
                  Page "Entity Text Factbox Part" = X,
                  Page "Entity Text Part" = X,
                  Page "Entity Text" = X;
}