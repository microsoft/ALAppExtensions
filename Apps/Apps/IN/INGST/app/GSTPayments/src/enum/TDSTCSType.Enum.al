// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

enum 18248 "TDSTCS Type"
{
    Extensible = true;
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; TDS)
    {
        Caption = 'TDS';
    }
    value(2; TCS)
    {
        Caption = 'TCS';
    }
}
