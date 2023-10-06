// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using Microsoft.Finance.GeneralLedger.Journal;

table 18933 "Posted Narration"
{
    DataClassification = EndUserIdentifiableInformation;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Transaction No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Narration"; Text[250])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(5; "Posting Date"; Date)
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "Document Type"; Enum "Gen. Journal Document Type")
        {
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Document No."; Code[20])
        {
            DataClassification = EndUserIdentifiableInformation;
        }
    }
    keys
    {
        key(PK; "Entry No.", "Transaction No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key1; "Transaction No.") { }
        key(Key2; "Document No.") { }
    }
}
