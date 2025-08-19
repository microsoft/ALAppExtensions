// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Purchases.History;
using Microsoft.Sales.History;

permissionset 10580 "Reports GB - Objects"
{
    Access = Internal;
    Assignable = false;
    Permissions = report "Purchase Credit Memo" = X,
                  report "Purchase Invoice" = X,
                  report "Sales - Credit Memo" = X,
                  report "Sales - Invoice" = X;
}