// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

tableextension 27032 "DIOT Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        field(27030; "DIOT Type of Operation"; Enum "DIOT Type of Operation")
        {
            Caption = 'DIOT Type of Operation';
            DataClassification = CustomerContent;
        }
    }
}
