// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using System.Security.AccessControl;

permissionsetextension 11107 "D365 READ - GetAddress.io UK Postcodes" extends "D365 READ"
{
    Permissions = tabledata "Postcode GetAddress.io Config" = R;
}
