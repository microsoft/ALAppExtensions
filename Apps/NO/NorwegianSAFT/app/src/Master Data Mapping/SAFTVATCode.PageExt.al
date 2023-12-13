// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN23
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.VAT.Setup;

pageextension 10676 "SAF-T VAT Code" extends "VAT Codes"
{
    layout
    {
        addlast(Control1080000)
        {
            field(Compensation; Compensation)
            {
                Caption = 'Compensation';
                ApplicationArea = Basic, Suite;
                Tooltip = 'Specifies if the tax code is used for compensation.';
            }
        }
    }
}
#endif
