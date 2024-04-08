// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

enum 7277 "Search Style"
{
    Access = Internal;
    Extensible = false;

    value(0; "Permissive")
    {
        Caption = 'Permissive';
    }
    value(1; "Balanced")
    {
        Caption = 'Balanced';
    }
    value(2; "Precise")
    {
        Caption = 'Precise';
    }
}