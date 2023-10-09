// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

permissionset 685 "Paym. Prac. Objects"
{
    Access = Public;
    Assignable = false;

    Permissions =
        table "Payment Period" = X,
        table "Payment Practice Data" = X,
        table "Payment Practice Line" = X,
        table "Payment Practice Header" = X,
        report "Payment Practice" = X,
        page "Payment Periods" = X,
        page "Payment Practice Data List" = X,
        page "Payment Practice Card" = X,
        page "Payment Practice Lines" = X,
        page "Payment Practice List" = X,
        codeunit "Paym. Prac. Cust. Generator" = X,
        codeunit "Paym. Prac. CV Generator" = X,
        codeunit "Paym. Prac. Period Aggregator" = X,
        codeunit "Paym. Prac. Size Aggregator" = X,
        codeunit "Paym. Prac. Vendor Generator" = X,
        codeunit "Install Payment Practices" = X,
        codeunit "Payment Practice Builders" = X,
        codeunit "Payment Practice Math" = X,
        codeunit "Payment Practices" = X;
}
