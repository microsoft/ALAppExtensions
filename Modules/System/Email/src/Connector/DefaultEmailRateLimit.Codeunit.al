// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

codeunit 8896 "Default Email Rate Limit" implements "Default Email Rate Limit"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetDefaultEmailRateLimit(): Integer
    begin
        exit(0);
    end;
}