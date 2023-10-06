// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

pageextension 5317 "G/L Acc. Mapping Card SIE" extends "G/L Account Mapping Card"
{
    layout
    {
        modify(StandardAccountCategoryNo)
        {
            Enabled = false;
            Visible = false;
        }
    }
}
