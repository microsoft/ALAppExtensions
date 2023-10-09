// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using Microsoft.Sales.History;

pageextension 4857 "AA Post Sales Cr. Memo Subform" extends "Posted Sales Cr. Memo Subform"
{
    layout
    {
        addafter("Appl.-to Item Entry")
        {

            field("Automatic Account Group"; Rec."Automatic Account Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code of the automatic account group on the sales credit memo line that was posted.';
#if not CLEAN22
                Visible = AutomaticAccountCodesAppEnabled;
                Enabled = AutomaticAccountCodesAppEnabled;
#endif
            }
        }
    }
#if not CLEAN22
    trigger OnOpenPage()
    begin
        AutomaticAccountCodesAppEnabled := AutoAccCodesFeatureMgt.IsEnabled();
    end;

    var
        AutoAccCodesFeatureMgt: Codeunit "Auto. Acc. Codes Feature Mgt.";
        AutomaticAccountCodesAppEnabled: Boolean;
#endif
}
