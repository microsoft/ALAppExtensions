// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Finance.VAT.Reporting;

permissionset 10549 "Reverse Charge VAT - Objects"
{
    Access = Internal;
    Assignable = false;
    Permissions = report "Reverse Charge Sales List GB" = X;
}