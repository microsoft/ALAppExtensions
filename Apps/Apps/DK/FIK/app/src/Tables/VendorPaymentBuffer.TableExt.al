// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

using Microsoft.Purchases.Payables;

tableextension 13624 VendorPaymentBuffer extends "Vendor Payment Buffer"
{
    fields
    {
        field(13651; GiroAccNo; Code[8]) { Caption = 'Giro Acc No.'; }
    }
}
