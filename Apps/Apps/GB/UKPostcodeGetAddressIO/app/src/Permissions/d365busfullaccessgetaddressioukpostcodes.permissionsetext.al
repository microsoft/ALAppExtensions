// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using System.Security.AccessControl;

permissionsetextension 20193 "D365 BUS FULL ACCESS - GetAddress.io UK Postcodes" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "Postcode GetAddress.io Config" = RIMD;
}
