// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Setup;

using Microsoft.Foundation.NoSeries;

tableextension 18811 "General Ledger Setup TCS Ext" extends "General Ledger Setup"
{
    fields
    {
        field(18807; "TCS Debit Note No."; Code[20])
        {
            Caption = 'TCS Debit Note No.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }
}
