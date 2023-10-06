// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

tableextension 27037 "DIOT VAT Posting Setup" extends "VAT Posting Setup"
{
    fields
    {
        field(27000; "DIOT WHT %"; Decimal)
        {
            Caption = 'DIOT WHT Percent';
            MinValue = 0;
        }
    }
}
