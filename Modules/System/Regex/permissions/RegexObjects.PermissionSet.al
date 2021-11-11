// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 3960 "Regex - Objects"
{
    Assignable = false;

    Permissions = Codeunit "Regex Impl." = X,
                  Codeunit Regex = X,
                  Table "Regex Options" = X,
                  Table Captures = X,
                  Table Groups = X,
                  Table Matches = X;
}
