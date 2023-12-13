// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

enum 31255 "Journal Status CZB"
{
    Extensible = true;

    value(0; " ")
    {
    }
    value(1; Opened)
    {
        Caption = 'Opened';
    }
    value(2; Posted)
    {
        Caption = 'Posted';
    }
}
