// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Currency;

using Microsoft.Finance.GeneralLedger.Journal;

tableextension 11784 "Adj. Exchange Rate Buffer CZL" extends "Adjust Exchange Rate Buffer"
{
    fields
    {
        field(11765; "Document Type CZL"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            DataClassification = SystemMetadata;
        }
        field(11766; "Document No. CZL"; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
        }
    }
}
