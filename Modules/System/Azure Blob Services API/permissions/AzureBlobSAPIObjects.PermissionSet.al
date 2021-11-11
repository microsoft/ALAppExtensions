// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9042 "Azure Blob S. API - Objects"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Base64 Convert - Objects",
                             "OAuth - Objects",
                             "URI - Objects";

    Permissions = Codeunit "ABS Blob Client" = X,
                  Codeunit "ABS Client Impl." = X,
                  Codeunit "ABS Container Client" = X,
                  Codeunit "ABS Container Content Helper" = X,
                  Codeunit "ABS Container Helper" = X,
                  Codeunit "ABS Format Helper" = X,
                  Codeunit "ABS Helper Library" = X,
                  Codeunit "ABS HttpContent Helper" = X,
                  Codeunit "ABS HttpHeader Helper" = X,
                  Codeunit "ABS Operation Payload" = X,
                  Codeunit "ABS Operation Response" = X,
                  Codeunit "ABS Optional Parameters" = X,
                  Codeunit "ABS URI Helper" = X,
                  Codeunit "ABS Web Request Helper" = X,
                  Table "ABS Container Content" = X,
                  Table "ABS Container" = X;
}
