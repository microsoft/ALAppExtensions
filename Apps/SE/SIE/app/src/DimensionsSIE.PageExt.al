// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

#if CLEAN22
using Microsoft.Finance.Dimension;

pageextension 5325 "Dimensions SIE" extends Dimensions
{
    actions
    {
        addafter(Translations)
        {
            action("Dimensions SIE")
            {
                ApplicationArea = Suite;
                Caption = 'Dimensions SIE';
                Image = UserInterface;
                RunObject = Page "Dimensions SIE";
                ToolTip = 'View or edit the dimensions to use when importing or exporting general ledger data in the SIE format for your company.';
            }
        }
    }
}
#endif
