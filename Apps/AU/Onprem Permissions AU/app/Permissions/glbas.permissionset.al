// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11600 "G/L-BAS"
{
    Access = Public;
    Assignable = true;
    Caption = 'Electronic BAS';

    Permissions = tabledata "BAS Business Unit" = RIMD,
                  tabledata "BAS Calc. Sheet Entry" = Rimd,
                  tabledata "BAS Calculation Sheet" = Rimd,
                  tabledata "BAS Comment Line" = RIMD,
                  tabledata "BAS Setup" = RIMD,
                  tabledata "BAS Setup Name" = RIMD,
                  tabledata "BAS XML Field ID" = RIMD,
                  tabledata County = RIMD;
}
