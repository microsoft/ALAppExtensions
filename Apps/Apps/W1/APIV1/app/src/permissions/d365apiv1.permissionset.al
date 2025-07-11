// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.API.V1;

// This permission set should always be internal
permissionset 2146 "D365 APIV1"
{
    Assignable = false;
    Access = Internal;
    Permissions = codeunit * = X,
                  page * = X,
                  table * = X,
                  query * = X,
                  report * = X,
                  xmlport * = X,
                  tabledata * = RIMD;
}
