// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

permissionset 17302 "Tax Register - Periodic"
{
    Access = Public;
    Assignable = false;
    Caption = 'Calculate Tax Registers';

    Permissions = tabledata "Gen. Template Profile" = RIMD,
                  tabledata "Gen. Term Profile" = RIMD,
                  tabledata "Lookup Buffer" = RIMD,
                  tabledata "Tax Reg. Norm Accumulation" = RIMD,
                  tabledata "Tax Reg. Norm Dim. Filter" = RIMD,
                  tabledata "Tax Reg. Norm Template Line" = RIMD,
                  tabledata "Tax Reg. Norm Term" = RIMD,
                  tabledata "Tax Reg. Norm Term Formula" = RIMD,
                  tabledata "Tax Register" = RIMD,
                  tabledata "Tax Register Accumulation" = RIMD,
                  tabledata "Tax Register Calc. Buffer" = RIMD,
                  tabledata "Tax Register CV Entry" = RIMD,
                  tabledata "Tax Register Dim. Comb." = RIMD,
                  tabledata "Tax Register Dim. Corr. Filter" = RIMD,
                  tabledata "Tax Register Dim. Def. Value" = RIMD,
                  tabledata "Tax Register Dim. Filter" = RIMD,
                  tabledata "Tax Register Dim. Value Comb." = RIMD,
                  tabledata "Tax Register FA Entry" = RIMD,
                  tabledata "Tax Register FE Entry" = RIMD,
                  tabledata "Tax Register G/L Corr. Entry" = RIMD,
                  tabledata "Tax Register G/L Entry" = RIMD,
                  tabledata "Tax Register Item Entry" = RIMD,
                  tabledata "Tax Register Line Setup" = RIMD,
                  tabledata "Tax Register Norm Detail" = RIMD,
                  tabledata "Tax Register Norm Group" = RIMD,
                  tabledata "Tax Register Norm Jurisdiction" = RIMD,
                  tabledata "Tax Register Section" = RIMD,
                  tabledata "Tax Register Setup" = RIMD,
                  tabledata "Tax Register Template" = RIMD,
                  tabledata "Tax Register Term" = RIMD,
                  tabledata "Tax Register Term Formula" = RIMD;
}
