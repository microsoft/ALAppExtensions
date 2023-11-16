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
                  Table "Entity Text" = X,
#if not CLEAN24
#pragma warning disable AL0432
                  Table "Azure OpenAi Settings" = X,
                  Page "Azure OpenAi Settings" = X,
                  Page "Copilot Information" = X,
                  Page "Entity Text Part" = X,
                  Page "Entity Text" = X,
#pragma warning restore AL0432
#endif
                  Page "Entity Text Factbox Part" = X;
}