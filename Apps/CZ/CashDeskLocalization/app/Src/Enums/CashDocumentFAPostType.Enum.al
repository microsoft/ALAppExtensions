// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

enum 11736 "Cash Document FA Post.Type CZP"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; "Acquisition Cost")
    {
        Caption = 'Acquisition Cost';
    }
    value(6; "Custom 2")
    {
        Caption = 'Custom 2';
    }
    value(8; Maintenance)
    {
        Caption = 'Maintenance';
    }
}
