// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.EU3PartyTrade;

using Microsoft.Finance.VAT.Reporting;

pageextension 4882 "EU3 VAT Stat. Prev. Line" extends "VAT Statement Preview Line"
{
    layout
    {
        addlast(Control1)
        {
            field("EU 3 Party Trade"; Rec."EU 3 Party Trade")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies whether or not totals for transactions involving EU 3-party trades are displayed in the VAT Statement.';
                Visible = EU3AppEnabled;
                Enabled = EU3AppEnabled;
            }
        }
    }

    trigger OnOpenPage()
    begin
        EU3AppEnabled := EU3PartyTradeFeatureMgt.IsEnabled();
    end;

    var
        EU3PartyTradeFeatureMgt: Codeunit "EU3 Party Trade Feature Mgt.";
        EU3AppEnabled: Boolean;
}