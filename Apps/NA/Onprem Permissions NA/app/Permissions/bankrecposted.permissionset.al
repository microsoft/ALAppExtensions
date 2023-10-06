// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 27005 "BANKREC-POSTED"
{
    Access = Public;
    Assignable = true;
    Caption = 'Read Posted Bank Recs';

    Permissions = tabledata "Bank Comment Line" = Ri;
}
