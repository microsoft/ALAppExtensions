// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

enum 11786 "Credit Memo Type CZL"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = '';
    }
    value(1; "Corrective Tax Document")
    {
        Caption = 'Corrective Tax Document';
    }
    value(2; "Internal Correction")
    {
        Caption = 'Internal Correction';
    }
    value(3; "Insolvency Tax Document")
    {
        Caption = 'Insolvency Tax Document';
    }
}
