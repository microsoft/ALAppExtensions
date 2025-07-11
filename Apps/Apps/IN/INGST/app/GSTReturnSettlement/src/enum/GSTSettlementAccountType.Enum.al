// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

enum 18321 "GST Settlement Account Type"
{
    Extensible = true;
    value(0; "G/L Account")
    {
        Caption = 'G/L Acoount';
    }
    value(1; "Bank Account")
    {
        Caption = 'Bank Account';
    }
}
