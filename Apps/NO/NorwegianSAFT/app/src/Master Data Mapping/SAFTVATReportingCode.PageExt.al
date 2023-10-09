// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

pageextension 10677 "SAF-T VAT Reporting Code" extends "VAT Reporting Codes"
{
    layout
    {
        addlast(VATCodes)
        {
            field(Compensation; Rec.Compensation)
            {
                ApplicationArea = Basic, Suite;
                Tooltip = 'Specifies if the tax code is used for compensation.';
            }
        }
    }
}
