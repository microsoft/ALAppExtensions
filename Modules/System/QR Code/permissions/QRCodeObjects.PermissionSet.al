// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 2890 "QR Code - Objects"
{
    Assignable = false;

    Permissions = Codeunit "QR Code Impl." = X,
                  Codeunit "QR Code" = X;
}
