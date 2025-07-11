// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.ExcelReports;

using Microsoft.Finance.ExcelReports;
using Microsoft.Sales.ExcelReports;
using Microsoft.Purchases.ExcelReports;

permissionset 4401 "Excel Reports - Objects"
{
    Assignable = false;
    Access = Internal;

    Permissions = table "EXR Aging Report Buffer" = X,
                  table "EXR Top Customer Report Buffer" = X,
                  table "EXR Top Vendor Report Buffer" = X,
                  table "EXR Trial Balance Buffer" = X,
                  report "EXR Aged Acc Payable Excel" = X,
                  report "EXR Aged Accounts Rec Excel" = X,
                  report "EXR Customer Top List" = X,
                  report "EXR Trial Bal by Period Excel" = X,
                  report "EXR Trial Bal. Prev Year Excel" = X,
                  report "EXR Trial Balance Excel" = X,
                  report "EXR Trial BalanceBudgetExcel" = X,
                  report "EXR Vendor Top List" = X,
                  codeunit "EXT Top Cust. Caption Handler" = X,
                  codeunit "EXT Top Vendor Caption Handler" = X,
                  query "EXR Top Customer Balance" = X,
                  query "EXR Top Customer Sales" = X,
                  query "EXR Top Vendor Balance" = X,
                  query "EXR Top Vendor Purchase" = X;
}