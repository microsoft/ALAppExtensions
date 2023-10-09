// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

permissionset 5282 "SAF-T Objects"
{
    Access = Public;
    Assignable = false;

    Permissions = table "Source Code SAF-T" = X,
                  table "Missing Field SAF-T" = X,
                  page "Data Check SAF-T" = X,
                  page "SAF-T Wizard" = X,
                  page "Source Codes SAF-T" = X,
                  page "VAT Posting Setup SAF-T" = X,
                  codeunit "Create Standard Data SAF-T" = X,
                  codeunit "Audit Data Handling SAF-T" = X,
                  codeunit "Audit Data Check SAF-T" = X,
                  codeunit "Data Check SAF-T" = X,
                  codeunit "Data Check Mgt. SAF-T" = X,
                  codeunit "Data Upgrade SAF-T" = X,
                  codeunit "Generate File SAF-T" = X,
                  codeunit "Install SAF-T" = X,
                  codeunit "Mapping Helper SAF-T" = X,
                  codeunit "SAF-T Data Mgt." = X,
                  codeunit "Xml Helper SAF-T" = X,
                  codeunit "Xml Helper SAF-T Public" = X,
                  codeunit "Xml Data Handling SAF-T" = X,
                  query "Cust. Ledger Entry SAF-T" = X,
                  query "FA Ledger Entry SAF-T" = X,
                  query "G/L Entry SAF-T" = X,
                  query "Item Ledger Entry SAF-T" = X,
                  query "Qty. Item Ledger Entry SAF-T" = X,
                  query "Vendor Ledger Entry SAF-T" = X;
}
