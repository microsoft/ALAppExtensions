// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

enum 7276 "Search Confidence"
{
    Access = Internal;
    Extensible = false;

    value(0; "None")
    {
        Caption = 'None';
    }
    value(1; "Low")
    {
        Caption = 'Low';
    }
    value(2; "Medium")
    {
        Caption = 'Medium';
    }
    value(3; "High")
    {
        Caption = 'High';
    }
}