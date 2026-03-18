// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address.IdealPostcodes;

using System.Security.AccessControl;

permissionsetextension 9405 "IdealPostcodes Local Read" extends "LOCAL READ"
{
    IncludedPermissionSets = "IdealPostcodes Read";
}