// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

enum 20100 AMCBankWebLogStatus
{
    Extensible = true;

    value(0; Success)
    {
        Caption = 'Success';
    }
    value(1; Failed)
    {
        Caption = 'Failed';
    }
    value(2; Warning)
    {
        Caption = 'Warning';
    }
}
