// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

using Microsoft.Finance.GeneralLedger.Journal;

pageextension 13618 PaymentJournal extends "Payment Journal"
{
    layout
    {
        addafter("Creditor No.")
        {
            field("Giro Acc. No."; GiroAccNo)
            {
                ToolTip = 'Specifies the vendor''s giro account.';
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
