// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

enum 5262 "Audit File Export Format" implements "Audit File Export Data Handling", "Audit File Export Data Check"
{
    Extensible = true;

    value(0; None)
    {
        Implementation = "Audit File Export Data Handling" = "Audit File Data Handling",
                         "Audit File Export Data Check" = "Audit File Data Check";
    }
}
