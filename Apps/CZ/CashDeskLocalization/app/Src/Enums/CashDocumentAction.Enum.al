// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

enum 11735 "Cash Document Action CZP"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; Create)
    {
        Caption = 'Create';
    }
    value(2; Release)
    {
        Caption = 'Release';
    }
    value(3; Post)
    {
        Caption = 'Post';
    }
    value(4; "Release and Print")
    {
        Caption = 'Release and Print';
    }
    value(5; "Post and Print")
    {
        Caption = 'Post and Print';
    }
}
