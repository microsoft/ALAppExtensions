// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18001 "Adjustment Type"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Lost/Destroyed")
    {
        Caption = 'Lost/Destroyed';
    }
    value(2; Consumed)
    {
        Caption = 'Consumed';
    }
}
