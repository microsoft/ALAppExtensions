// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

tableextension 20334 "Gen. Journal Line Posting Ext" extends "Gen. Journal Line"
{
    fields
    {
        field(20334; "Tax ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Tax ID';
        }
        field(20335; "Adjust Tax Amount"; Boolean)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Adjust Tax Amount';
        }
        field(20336; "Amount Before Adjustment"; Decimal)
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Amount Before Adjustment';
        }
    }
}
