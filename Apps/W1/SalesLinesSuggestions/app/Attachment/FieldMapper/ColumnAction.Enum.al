// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document.Attachment;

enum 7278 "Column Action"
{
    Extensible = false;
    Access = Internal;

    value(0; Ignore)
    {
        Caption = 'Ignore';
    }

    value(10; "Product Info.")
    {
        Caption = 'Use (Product)';
    }

    value(20; "Quantity Info.")
    {
        Caption = 'Use (Quantity)';
    }

    value(30; "UoM Info.")
    {
        Caption = 'Use (Unit of Measure)';
    }
}