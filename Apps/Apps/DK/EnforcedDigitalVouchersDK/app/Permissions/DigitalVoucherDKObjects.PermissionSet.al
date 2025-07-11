﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

permissionset 13625 "Digital Voucher DK - Objects"
{
    Access = Public;
    Assignable = false;

    Permissions = codeunit "Digital Voucher DK Impl." = X,
                  codeunit "Digital Voucher DK Install." = X;
}
