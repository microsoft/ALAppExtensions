// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 11790 "CZ Bank Documents - Read CZB"
{
    Access = Internal;
    Assignable = false;
    Caption = 'CZ Bank Documents - Read';

    Permissions = tabledata "Bank Statement Header CZB" = R,
                  tabledata "Bank Statement Line CZB" = R,
                  tabledata "Iss. Bank Statement Header CZB" = R,
                  tabledata "Iss. Bank Statement Line CZB" = R,
                  tabledata "Iss. Payment Order Header CZB" = R,
                  tabledata "Iss. Payment Order Line CZB" = R,
                  tabledata "Payment Order Header CZB" = R,
                  tabledata "Payment Order Line CZB" = R,
                  tabledata "Search Rule CZB" = R,
                  tabledata "Search Rule Line CZB" = R;
}