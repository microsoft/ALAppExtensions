// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

enum 5314 "File Type SIE"
{
    Extensible = true;

    value(5314; "1. Year - End Balances") { Caption = '1. Year - End Balances'; }
    value(5315; "2. Periodic Balances") { Caption = '2. Periodic Balances'; }
    value(5316; "3. Object Balances") { Caption = '3. Object Balances'; }
    value(5317; "4. Transactions") { Caption = '4. Transactions'; }
}
