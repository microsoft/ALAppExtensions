// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine;

using Microsoft.Finance.TaxEngine.Core;
using Microsoft.Finance.TaxEngine.JsonExchange;
using Microsoft.Finance.TaxEngine.PostingHandler;
using Microsoft.Finance.TaxEngine.ScriptHandler;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.TaxEngine.UseCaseBuilder;

permissionset 20130 "Adv Objects - Tax Engine"
{
    Access = Public;
    Assignable = false;
    Caption = 'Advance Objects - Tax Engine';

    Permissions = codeunit "App Object Helper" = X,
                  codeunit "RecRef Handler" = X,
                  codeunit "Script Data Type Mgmt." = X,
                  codeunit "Script Symbols Mgmt." = X,
                  codeunit "Script Symbol Store" = X,
                  codeunit "Symbol Data Senstivity Mgmt." = X,
                  codeunit "Lookup Dialog Mgmt." = X,
                  codeunit "Lookup Entity Mgmt." = X,
                  codeunit "Lookup Mgmt." = X,
                  codeunit "Lookup Serialization" = X,
                  codeunit "Archival Single Instance" = X,
                  codeunit "Tax Type Archival Mgmt." = X,
                  codeunit "Use Case Archival Mgmt." = X,
                  codeunit "Tax Engine Assisted Setup" = X,
                  codeunit "Json Entity Mgmt." = X,
                  codeunit "Tax Json Deserialization" = X,
                  codeunit "Tax Json Serialization" = X,
                  codeunit "Tax Json Single Instance" = X,
                  codeunit "Posting Data Senstivity Mgmt." = X,
                  codeunit "Tax Document GL Posting" = X,
                  codeunit "Tax Document Subledger Posting" = X,
                  codeunit "Tax Posting Buffer Mgmt." = X,
                  codeunit "Tax Posting Execution" = X,
                  codeunit "Tax Posting Handler" = X,
                  codeunit "Tax Posting Helper" = X,
                  codeunit "Tax Subledger Posting Handler" = X,
                  codeunit "Fin Charge Posting Handler" = X,
                  codeunit "Gen. Jnl.-Post Handler" = X,
                  codeunit "Purch.-Post Handler" = X,
                  codeunit "Sales Posting Subscribers" = X,
                  codeunit "Service Posting Subscribers" = X,
                  codeunit "Transfer Rcpt. Posting Handler" = X,
                  codeunit "Transfer Shpt Posting Handler" = X,
                  codeunit "Action Dialog Mgmt." = X,
                  codeunit "Script Action Execution" = X,
                  codeunit "Script Action Helper" = X,
                  codeunit "Condition Mgmt." = X,
                  codeunit "Script Data Senstivity Mgmt." = X,
                  codeunit "Script Editor Mgmt." = X,
                  codeunit "Script Entity Mgmt." = X,
                  codeunit "Script Serialization" = X,
                  codeunit "Script Symbol Handler" = X,
                  codeunit "Tax Type Entity Mgmt." = X,
                  codeunit "Tax Type Object Helper" = X,
                  codeunit "Transaction Value Helper" = X,
                  codeunit "Switch Statement Execution" = X,
                  codeunit "Switch Statement Helper" = X,
                  codeunit "Use Case Data Senstivity Mgmt." = X,
                  codeunit "Use Case Event Handling" = X,
                  codeunit "Use Case Event Library" = X,
                  codeunit "Use Case Tree-Indent" = X,
                  codeunit "Tax Document Stats Mgmt." = X,
                  codeunit "Tax Rate Computation" = X,
                  codeunit "Use Case Entity Mgmt." = X,
                  codeunit "Use Case Execution" = X,
                  codeunit "Use Case Mgmt." = X,
                  codeunit "Use Case Object Helper" = X,
                  codeunit "Use Case Serialization" = X,
                  codeunit "Use Case Symbols Handler" = X,
                  codeunit "Use Case Variables Mgmt." = X;
}
