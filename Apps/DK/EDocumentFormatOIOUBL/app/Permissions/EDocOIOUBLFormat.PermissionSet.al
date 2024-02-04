// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

permissionset 13910 "EDoc. OIOUBL Format"
{
    Access = Public;
    Assignable = false;

    Permissions = codeunit "EDoc Import OIOUBL" = X,
                  codeunit "OIOUBL Format" = X;
}