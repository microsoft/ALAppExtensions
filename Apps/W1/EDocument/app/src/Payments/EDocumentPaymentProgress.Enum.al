// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Payments;

enum 6112 "E-Document Payment Progress"
{
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Not Paid")
    {
        Caption = 'Not Paid';
    }
    value(2; "Partially Paid")
    {
        Caption = 'Partially Paid';
    }
    value(3; Paid)
    {
        Caption = 'Paid In Full';
    }
}
