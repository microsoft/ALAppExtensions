// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18010 "Cr Libty Adjustment Type"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Generate)
    {
        Caption = 'Generate';
    }
    value(2; Reverse)
    {
        Caption = 'Reverse';
    }
}
