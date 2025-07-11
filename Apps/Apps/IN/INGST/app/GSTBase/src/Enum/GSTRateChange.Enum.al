// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18032 "GST Rate Change"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Before Rate Change")
    {
        Caption = 'Before Rate Change';
    }
    value(2; "After Rate Change")
    {
        Caption = 'After Rate Change';
    }
}
