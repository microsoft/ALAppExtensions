// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document.Attachment;

enum 7280 "Column Type"
{
    Extensible = false;
    Access = Internal;

    value(0; Unknown)
    {
        Caption = 'Unknown';
    }

    value(10; Boolean)
    {
        Caption = 'Boolean';
    }

    value(20; Number)
    {
        Caption = 'Number';
    }

    value(30; Text)
    {
        Caption = 'Text';
    }

    value(40; Date)
    {
        Caption = 'Date';
    }
}