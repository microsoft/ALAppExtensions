// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Text;

permissionset 2011 "Entity Text - View"
{
    Access = Internal;
    Assignable = false;
    IncludedPermissionSets = "Entity Text - Objects";

    Permissions =
#if not CLEAN24
#pragma warning disable AL0432
                  tabledata "Azure OpenAi Settings" = R,
#pragma warning restore AL0432
#endif
    tabledata "Entity Text" = R;
}