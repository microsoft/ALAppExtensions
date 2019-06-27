// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

enum 2301 "Tenant License State"
{
    value(0; Evaluation) { }
    value(1; Trial) { }
    value(2; Paid) { }
    value(3; Warning) { }
    value(4; Suspended) { }
    value(5; Deleted) { }
    value(6; LockedOut) { }
}