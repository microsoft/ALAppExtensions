// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 132585 "System Application Test Tables"
{
    Access = Public;
    Assignable = false;

    Permissions = tabledata "Cues And KPIs Test 1 Cue" = RIMD,
                  tabledata "Cues And KPIs Test 2 Cue" = RIMD,
                  tabledata "Test Email Account" = RIMD,
                  tabledata "Test Email Connector Setup" = RIMD,
                  tabledata "Test Table A" = RIMD,
                  tabledata "Test Table B" = RIMD,
                  tabledata "Page Provider Summary Test" = RIMD,
                  tabledata "Page Provider Summary Test2" = RIMD,
                  tabledata "Record Link Record Test" = RIMD,
                  tabledata "Retention Policy Test Data" = RIMD,
                  tabledata "Retention Policy Test Data Two" = RIMD,
                  tabledata "Retention Policy Test Data 3" = RIMD,
                  tabledata "Retention Policy Test Data 4" = RIMD,
                  tabledata "Translation Test Table" = RIMD,
                  tabledata "My Video Source" = RIMD;
}