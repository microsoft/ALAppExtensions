// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.PaymentTerms;

tableextension 13640 "OIOUBL-Payment Terms" extends "Payment Terms"
{
    fields
    {
        field(13630; "OIOUBL-Code"; Option)
        {
            Caption = 'OIOUBL-Code', Comment = 'Leave OIOUBL- as leading eq for in Danish OIOUBL-kode';
            OptionMembers = " ",Contract,Specific;
        }
    }
    keys
    {
    }
}
