// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

permissionset 13687 "SAF-T Objects DK"
{
    Access = Public;
    Assignable = false;

    Permissions = table "Imported SAF-T File DK" = X,
                  page "Imported SAF-T Files DK" = X,
                  codeunit "Create Standard Data SAF-T DK" = X,
                  codeunit "Data Check SAF-T DK" = X,
                  codeunit "Install SAF-T DK" = X,
                  codeunit "Standard Account DK" = X,
                  codeunit "Standard Tax Code DK" = X,
                  codeunit "Xml Data Handling SAF-T DK" = X;
}