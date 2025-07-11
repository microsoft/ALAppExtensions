// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

tableextension 10690 "Elec. VAT Report Header" extends "VAT Report Header"
{
    fields
    {
        field(10680; KID; Code[25])
        {
            Caption = 'KID';
        }
    }
}
