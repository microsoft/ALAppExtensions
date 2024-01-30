#if not CLEAN24
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 26000 "PHYSICAL INVENT."
{
    Access = Public;
    Assignable = true;
    Caption = 'Physical Inventory';
    ObsoleteReason = 'Merged to W1';
    ObsoleteState = Pending;
    ObsoleteTag = '24.0';

    Permissions = tabledata "Expect. Phys. Inv. Track. Line" = RIMD,
                  tabledata "Phys. Inventory Comment Line" = RIMD,
                  tabledata "Phys. Inventory Order Header" = RIMD,
                  tabledata "Phys. Inventory Order Line" = RIMD,
                   tabledata "Phys. Invt. Diff. List Buffer" = RIMD,
                  tabledata "Phys. Invt. Recording Header" = RIMD,
                  tabledata "Phys. Invt. Recording Line" = RIMD,
                  tabledata "Phys. Invt. Tracking Buffer" = RIMD,
                  tabledata "Post. Exp. Ph. In. Track. Line" = RIMD,
                  tabledata "Post. Phys. Invt. Order Header" = RIMD,
                  tabledata "Posted Phys. Invt. Order Line" = RIMD,
                  tabledata "Posted Phys. Invt. Rec. Header" = RIMD,
                  tabledata "Posted Phys. Invt. Rec. Line" = RIMD,
                  tabledata "Posted Phys. Invt. Track. Line" = RIMD;
}
#endif