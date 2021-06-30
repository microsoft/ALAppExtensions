// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11709 "GL-CREDIT,POST"
{
    Access = Public;
    Assignable = true;
    Caption = 'GL - Credit Post';
    
    ObsoleteState = Pending;
    ObsoleteReason = 'Moved to Compensation Localization Pack for Czech.';
    ObsoleteTag = '18.0';

    Permissions = tabledata "Credit Header" = RIMD,
                  tabledata "Credit Line" = RIMD,
                  tabledata "Credit Report Selections" = R,
                  tabledata "Credits Setup" = R,
                  tabledata "Posted Credit Header" = RIm,
                  tabledata "Posted Credit Line" = RIm;
}
