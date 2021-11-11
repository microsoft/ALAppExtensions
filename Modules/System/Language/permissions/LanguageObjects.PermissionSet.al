// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 164 "Language - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Language Impl." = X,
                  Codeunit Language = X,
                  Page "Windows Languages" = X,
                  Page Languages = X,
                  Table Language = X;
}
