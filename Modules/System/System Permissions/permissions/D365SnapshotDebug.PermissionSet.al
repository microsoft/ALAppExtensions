// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 7209 "D365 SNAPSHOT DEBUG"
{
    Access = Public;
    Assignable = true;
    Caption = 'Snapshot Debug';

    Permissions = system "Snapshot debugging" = X,
                  tabledata "Published Application" = R;
}
