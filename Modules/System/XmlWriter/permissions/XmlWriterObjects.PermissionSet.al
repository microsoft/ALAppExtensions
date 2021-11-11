// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 1483 "XmlWriter - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "XmlWriter Impl." = X,
                  Codeunit "XmlWriter" = X;
}
