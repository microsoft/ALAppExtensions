// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

tableextension 31009 "Copy Gen. Jnl. Parameters CZL" extends "Copy Gen. Journal Parameters"
{
    fields
    {
        field(11700; "Replace VAT Date CZL"; Date)
        {
            Caption = 'Replace VAT Date';
            DataClassification = CustomerContent;
        }
    }
}
