// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

tableextension 31032 "Gen. Journal Template CZL" extends "Gen. Journal Template"
{
    fields
    {
        field(11770; "Not Check Doc. Type CZL"; Boolean)
        {
            Caption = 'Not Check Doc. Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Force Doc. Balance");
            end;
        }
    }
}
