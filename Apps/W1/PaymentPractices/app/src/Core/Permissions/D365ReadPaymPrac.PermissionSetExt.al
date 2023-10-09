// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

using System.Security.AccessControl;

permissionsetextension 690 "D365 READ - Paym. Prac." extends "D365 READ"
{
    IncludedPermissionSets = "Paym. Prac. Read";
}
