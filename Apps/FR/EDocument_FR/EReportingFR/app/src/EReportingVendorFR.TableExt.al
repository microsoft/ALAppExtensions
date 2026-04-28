// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Purchases.Vendor;

tableextension 10973 "E-Reporting Vendor FR" extends Vendor
{
    fields
    {
        field(10973; "FR E-Reporting Trans. Type"; Enum "FR E-Reporting Trans. Type")
        {
            Caption = 'E-Reporting Transaction Type';
            DataClassification = CustomerContent;
        }
    }
}
