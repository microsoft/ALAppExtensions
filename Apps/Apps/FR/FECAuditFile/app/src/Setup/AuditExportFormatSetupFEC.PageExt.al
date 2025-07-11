// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

pageextension 10827 "Audit Export Format Setup FEC" extends "Audit File Export Format Setup"
{
    actions
    {
        modify(SelectExportDataTypes)
        {
            Enabled = false;
            Visible = false;
        }
    }
}
