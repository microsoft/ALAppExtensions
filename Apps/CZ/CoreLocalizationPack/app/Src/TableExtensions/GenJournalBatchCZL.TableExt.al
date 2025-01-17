// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

tableextension 31051 "Gen. Journal Batch CZL" extends "Gen. Journal Batch"
{
    fields
    {
        field(11700; "Allow Hybrid Document CZL"; Boolean)
        {
            Caption = 'Allow Hybrid Document';
            DataClassification = CustomerContent;
        }
    }
}
