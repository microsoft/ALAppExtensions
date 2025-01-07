// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;
using Microsoft.Sales.Customer;

tableextension 13914 "XRechnung-Customer" extends Customer
{
    fields
    {
        field(13914; "E-Invoice Routing No."; Text[50])
        {
            Caption = 'E-Invoice Routing No.';
            DataClassification = CustomerContent;
        }
    }
}