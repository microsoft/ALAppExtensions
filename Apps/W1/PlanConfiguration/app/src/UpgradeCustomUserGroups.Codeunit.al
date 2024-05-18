// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

codeunit 9032 "Upgrade Custom User Groups"
{
    // Obsolete = Removed tables can only be referenced from Upgrade codeunits.
    // Even though this codeunit will not have the OnUpgradePerDatabase trigger,
    // in v25+ the event subscriber will always run in the upgrade context.
    Subtype = Upgrade;
}