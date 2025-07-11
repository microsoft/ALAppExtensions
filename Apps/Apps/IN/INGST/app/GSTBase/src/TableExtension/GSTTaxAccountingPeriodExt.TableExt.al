// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

tableextension 18014 "GST Tax Accounting Period Ext" extends "Tax Accounting Period"
{
    fields
    {
        field(18000; "Credit Memo Locking Date"; date)
        {
            Caption = 'Credit Memo Locking Date';
            DataClassification = CustomerContent;
        }
        field(18001; "Annual Return Filed Date"; date)
        {
            Caption = 'Annual Return Filed Date';
            DataClassification = CustomerContent;
        }
    }
}
