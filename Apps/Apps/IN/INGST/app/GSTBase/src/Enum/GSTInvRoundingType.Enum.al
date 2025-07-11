// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18025 "GST Inv Rounding Type"
{
    value(0; Nearest)
    {
        Caption = 'Nearest';
    }
    value(1; Up)
    {
        Caption = 'Up';
    }
    value(2; Down)
    {
        Caption = 'Down';
    }
}
