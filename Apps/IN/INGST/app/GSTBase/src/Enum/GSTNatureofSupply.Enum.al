// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18030 "GST Nature of Supply"
{
    value(0; B2B)
    {
        Caption = 'B2B';
    }
    value(1; B2C)
    {
        Caption = 'B2C';
    }
}
