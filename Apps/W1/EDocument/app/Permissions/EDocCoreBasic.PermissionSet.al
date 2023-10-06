﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

permissionset 6103 "E-Doc. Core - Basic"
{
    Access = Public;
    Assignable = true;
    Caption = 'E-Document Core - Basic';

    IncludedPermissionSets = "E-Doc. Core - Read";

    Permissions =
        tabledata "E-Doc. Mapping" = im,
        tabledata "E-Doc. Mapping Log" = im,
        tabledata "E-Doc. Data Storage" = im,
        tabledata "E-Document" = im,
        tabledata "E-Document Log" = im,
        tabledata "E-Document Service" = im,
        tabledata "E-Document Service Status" = im,
        tabledata "E-Document Integration Log" = im;
}
