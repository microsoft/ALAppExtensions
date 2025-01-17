// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.VAT.Setup;

tableextension 31059 "VAT Setup CZZ" extends "VAT Setup"
{
    fields
    {
        field(31000; "Use For Advances CZZ"; Boolean)
        {
            Caption = 'Use For Advances';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies if the non-deductible VAT will be used in purchase advances.';
        }
    }
}
