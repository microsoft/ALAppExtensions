// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using System.Security.AccessControl;

permissionsetextension 49708 "D365 TEAM MEMBER - GetAddress.io UK Postcodes" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "Postcode GetAddress.io Config" = RIMD;
}
