// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Finance.GeneralLedger.Setup;

tableextension 10549 "General Ledger Setup" extends "General Ledger Setup"
{
    fields
    {
        field(10507; "Threshold applies GB"; Boolean)
        {
            Caption = 'Threshold applies';
            DataClassification = CustomerContent;
        }
        field(10508; "Threshold Amount GB"; Decimal)
        {
            Caption = 'Threshold Amount';
            MinValue = 0;
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
        }
    }
}