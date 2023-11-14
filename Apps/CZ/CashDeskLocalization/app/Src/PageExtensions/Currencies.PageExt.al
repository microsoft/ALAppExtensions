// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.Currency;

pageextension 31150 "Currencies CZP" extends Currencies
{
    actions
    {
        addlast(navigation)
        {
            action(NominalValuesCZP)
            {
                Caption = 'Nominal Values';
                ApplicationArea = Basic, Suite;
                Image = Currencies;
                RunObject = Page "Currency Nominal Values CZP";
                RunPageLink = "Currency Code" = field(Code);
                RunPageMode = View;
                Tooltip = 'Define the currency nominal values used in the cash desks.';
            }
        }
    }
}
