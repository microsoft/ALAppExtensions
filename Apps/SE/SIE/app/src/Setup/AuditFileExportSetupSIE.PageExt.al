// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

pageextension 5316 "Audit File Export Setup SIE" extends "Audit File Export Setup"
{
    layout
    {
        modify("Data Quality")
        {
            Visible = false;
        }
    }
}
