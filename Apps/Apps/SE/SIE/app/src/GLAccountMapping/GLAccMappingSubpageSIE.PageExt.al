// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

pageextension 5318 "G/L Acc. Mapping Subpage SIE" extends "G/L Account Mapping Subpage"
{
    layout
    {
        modify(CategoryNo)
        {
            Enabled = false;
            Visible = false;
        }
    }
}
