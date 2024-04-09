#if not CLEAN24
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

pageextension 5317 "G/L Acc. Mapping Card SIE" extends "G/L Account Mapping Card"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This page was replaced by the G/L Account Mapping Card SIE page';
    ObsoleteTag = '24.0';

    layout
    {
        modify(StandardAccountCategoryNo)
        {
            Enabled = false;
            Visible = false;
        }
    }
}
#endif