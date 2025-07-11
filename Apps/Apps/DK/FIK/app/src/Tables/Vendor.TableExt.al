﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

using Microsoft.Purchases.Vendor;

tableextension 13611 Vendor extends Vendor
{
    fields
    {
        field(13651; GiroAccNo; Code[8])
        {
            Caption = 'Giro Acc No.';
            trigger OnValidate();
            begin
                IF GiroAccNo <> '' THEN
                    GiroAccNo := PADSTR('', MAXSTRLEN(GiroAccNo) - STRLEN(GiroAccNo), '0') + GiroAccNo;
            end;
        }
    }
}
