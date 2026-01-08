// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using System.Security.AccessControl;

permissionsetextension 10502 "GetAddress.io UK Postcodes Local Read" extends "LOCAL READ"
{
    Permissions = tabledata "Postcode Notif. Memory" = R;
}