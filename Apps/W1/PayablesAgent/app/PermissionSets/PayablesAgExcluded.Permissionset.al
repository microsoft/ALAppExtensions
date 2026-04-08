// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

using Microsoft.Bank.Check;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Sales.Receivables;


/// <summary>
/// Permissionset that has the permissions to be excluded from the Payables Agent to ensure no unintended access.
/// </summary>
permissionset 3306 "Payables Ag. - Excluded"
{
    Access = Internal;
    Caption = 'Payables Agent - Excluded', Comment = 'Payables Agent is a term, and should not be translated.';
    Permissions =
        tabledata "VAT Entry" = Rm,
        tabledata "Bank Account Ledger Entry" = rm,
        tabledata "Check Ledger Entry" = r,
        tabledata "Cust. Ledger Entry" = r,
        tabledata "G/L Entry" = rm;
}