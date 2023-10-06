// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Currency;

tableextension 13648 "OIOUBL-Currency" extends Currency
{
    fields
    {
        field(13630; "OIOUBL-Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
        }
    }
    keys
    {
    }
}
