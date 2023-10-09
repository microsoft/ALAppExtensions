// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using Microsoft.Finance.GeneralLedger.Journal;

pageextension 4854 "AutoAcc General Journal" extends "General Journal"
{
    layout
    {
        addafter("Bal. Gen. Prod. Posting Group")
        {
            field("Automatic Account Group"; Rec."Automatic Account Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the automatic account group code.';
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