// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup;

using Microsoft.Finance.ChargeGroup.ChargeGroupBase;

permissionset 18921 "D365 Read Access - IN Charge"
{
    Access = Public;
    Assignable = false;
    Caption = 'D365 Read Access - IN Charge';

    Permissions = tabledata "Charge Group Header" = R,
                    tabledata "Charge Group Line" = R;
}
