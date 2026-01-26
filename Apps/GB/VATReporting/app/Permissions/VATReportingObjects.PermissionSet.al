// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

permissionset 10544 "VAT Reporting - Objects"
{
    Access = Internal;
    Assignable = false;
    Permissions =
#if not CLEAN27
    codeunit "VAT Audit GB" = X,
#endif
        report "VAT Audit GB" = X,
        report "VAT Entry Exception Report GB" = X;
}