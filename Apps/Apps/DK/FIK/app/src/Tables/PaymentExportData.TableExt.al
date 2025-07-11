// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

tableextension 13622 PaymentExportData extends "Payment Export Data"
{
    fields
    {
        field(13651; RecipientGiroAccNo; Code[8]) { Caption = 'Recipient Giro Acc No.'; }
    }
}
