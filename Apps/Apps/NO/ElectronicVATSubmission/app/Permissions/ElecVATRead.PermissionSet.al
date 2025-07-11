// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

permissionset 10681 "Elec. VAT - Read"
{
    Access = Public;
    Assignable = true;

    Permissions = tabledata "Elec. VAT Setup" = R;
}
