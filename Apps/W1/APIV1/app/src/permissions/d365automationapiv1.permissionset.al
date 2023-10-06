// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.API.V1;

// This permission set should always be internal
permissionset 2148 "D365 Automation APIV1"
{
    Assignable = false;
    Access = Internal;
    Permissions = codeunit * = X,
                  query * = X,
                  page "APIV1 - Aut. Companies" = X,
                  page "APIV1 - Aut. Config. Packages" = X,
                  page "APIV1 - Aut. Extension Depl." = X,
                  page "APIV1 - Aut. Extension Upload" = X,
                  page "APIV1 - Aut. Extensions" = X,
                  page "APIV1 - Aut. Permission Sets" = X,
#if not CLEAN22
#pragma warning disable AL0432
                  page "APIV1 - Aut. User Groups" = X,
#pragma warning restore AL0432
#endif
                  page "APIV1 - Aut. Users" = X;
}