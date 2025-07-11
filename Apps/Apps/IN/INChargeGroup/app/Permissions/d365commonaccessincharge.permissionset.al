// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup;

using Microsoft.Finance.ChargeGroup.ChargeGroupBase;

permissionset 18919 "D365 Common Access - IN Charge"
{
    Access = Public;
    Assignable = false;
    Caption = 'D365 Common Access - IN Charge';

    Permissions = tabledata "Charge Group Header" = RIMD,
                    tabledata "Charge Group Line" = RIMD;
}
