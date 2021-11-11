// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9065 "Az. Storage S. Auth. - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Cryptography Mgt. - Objects",
                             "URI - Objects";

    Permissions = Codeunit "Auth. Format Helper" = X,
                  Codeunit "Stor. Serv. Auth. Impl." = X,
                  Codeunit "Stor. Serv. Auth. SAS" = X,
                  Codeunit "Stor. Serv. Auth. Shared Key" = X,
                  Codeunit "Storage Service Authorization" = X,
                  Table "SAS Parameters" = X;
}
