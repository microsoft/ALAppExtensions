// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

permissionset 10826 "FEC - Objects"
{
    Access = Public;
    Assignable = false;

    Permissions = codeunit "Data Check FEC" = X,
                  codeunit "Data Handling FEC" = X,
                  codeunit "Generate File FEC" = X,
                  codeunit "Install FEC" = X,
                  codeunit "Library - Test FEC" = X;
}
