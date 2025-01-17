﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.PaymentTerms;

pageextension 13653 "OIOUBL-Payment Terms" extends "Payment Terms"
{
    layout
    {
        addafter(Description)
        {
            field("OIOUBL-Code"; "OIOUBL-Code")
            {
                Tooltip = 'Specifies if the payment term is associated with a contract or specific terms.';
                ApplicationArea = Basic, Suite;
            }
        }
    }
}
