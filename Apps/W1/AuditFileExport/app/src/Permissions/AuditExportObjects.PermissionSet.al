// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

permissionset 5262 "Audit Export - Objects"
{
    Access = Public;
    Assignable = false;

    Permissions = table "Audit Export Data Type Setup" = X,
                  table "Audit File" = X,
                  table "Audit File Export Header" = X,
                  table "Audit File Export Line" = X,
                  table "Audit File Export Format Setup" = X,
                  table "Audit File Export Setup" = X,
                  table "G/L Account Mapping Header" = X,
                  table "G/L Account Mapping Line" = X,
                  table "Standard Account" = X,
                  table "Standard Account Category" = X,
                  page "Audit Export Data Type Setup" = X,
                  page "Audit File Export Doc. Card" = X,
                  page "Audit File Export Documents" = X,
                  page "Audit File Export Format Setup" = X,
                  page "Audit File Export Setup" = X,
                  page "Audit File Export Subpage" = X,
                  page "Audit Files" = X,
                  page "G/L Account Mapping" = X,
#if not CLEAN24
                  page "G/L Account Mapping Card" = X,
#endif
                  page "G/L Acc. Mapping Card" = X,
                  page "G/L Account Mapping Subpage" = X,
                  page "Standard Account Categories" = X,
                  page "Standard Accounts" = X,
                  report "Copy G/L Account Mapping" = X,
                  codeunit "Audit File Export Error Handl." = X,
                  codeunit "Audit File Export Mgt." = X,
                  codeunit "Audit Line Export Runner" = X,
                  codeunit "Audit Mapping Helper" = X,
                  codeunit "Import Audit Data Mgt." = X,
                  codeunit "Install Audit File Export" = X;
}
