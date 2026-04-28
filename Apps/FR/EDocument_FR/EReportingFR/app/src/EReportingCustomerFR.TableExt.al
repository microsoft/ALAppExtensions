// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.Sales.Customer;

tableextension 10972 "E-Reporting Customer FR" extends Customer
{
    fields
    {
        field(10972; "FR E-Reporting Trans. Type"; Enum "FR E-Reporting Trans. Type")
        {
            Caption = 'E-Reporting Transaction Type';
            DataClassification = CustomerContent;
        }
    }
}
