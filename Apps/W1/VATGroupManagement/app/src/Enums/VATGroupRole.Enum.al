// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Group;

enum 4701 "VAT Group Role"
{
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Representative)
    {
        Caption = 'Representative';
    }
    value(2; Member)
    {
        Caption = 'Member';
    }
}