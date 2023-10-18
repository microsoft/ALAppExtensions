// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

tableextension 5284 "Audit File Export Header SAF-T" extends "Audit File Export Header"
{
    fields
    {
        field(5280; "Export Currency Information"; Boolean)
        {
            InitValue = true;
        }
    }
}
