// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18034 "GST Transaction Type"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Purchase)
    {
        Caption = 'Purchase';
    }
    value(2; Sale)
    {
        Caption = 'Sale';
    }
}
