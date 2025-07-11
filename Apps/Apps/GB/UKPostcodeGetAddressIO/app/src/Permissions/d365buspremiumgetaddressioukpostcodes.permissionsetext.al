// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using System.Security.AccessControl;

permissionsetextension 30556 "D365 BUS PREMIUM - GetAddress.io UK Postcodes" extends "D365 BUS PREMIUM"
{
    Permissions = tabledata "Postcode GetAddress.io Config" = RIMD;
}
