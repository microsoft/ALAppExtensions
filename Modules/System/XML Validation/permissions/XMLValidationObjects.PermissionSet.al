// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 6240 "XML Validation - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Xml Validation Impl." = X,
                  Codeunit "Xml Validation" = X;
}
