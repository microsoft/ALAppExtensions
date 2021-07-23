// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 17301 "Tax Difference - Post"
{
    Access = Public;
    Assignable = false;
    Caption = 'Tax Difference Posting';

    Permissions = tabledata "Tax Calc. Accumulation" = RIMD,
                  tabledata "Tax Calc. Buffer Entry" = RIMD,
                  tabledata "Tax Calc. Dim. Corr. Filter" = RIMD,
                  tabledata "Tax Calc. Dim. Filter" = RIMD,
                  tabledata "Tax Calc. FA Entry" = RIMD,
                  tabledata "Tax Calc. G/L Corr. Entry" = RIMD,
                  tabledata "Tax Calc. G/L Entry" = RIMD,
                  tabledata "Tax Calc. Header" = RIMD,
                  tabledata "Tax Calc. Item Entry" = RIMD,
                  tabledata "Tax Calc. Line" = RIMD,
                  tabledata "Tax Calc. Section" = RIMD,
                  tabledata "Tax Calc. Selection Setup" = RIMD,
                  tabledata "Tax Calc. Term" = RIMD,
                  tabledata "Tax Calc. Term Formula" = RIMD,
                  tabledata "Tax Diff. Journal Batch" = RIMD,
                  tabledata "Tax Diff. Journal Line" = RIMD,
                  tabledata "Tax Diff. Journal Template" = RIMD,
                  tabledata "Tax Diff. Ledger Entry" = RI,
                  tabledata "Tax Diff. Posting Group" = RIMD,
                  tabledata "Tax Diff. Register" = RIMD,
                  tabledata "Tax Difference" = RIMD;
}
