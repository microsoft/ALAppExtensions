// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 3906 "Retention Policy - Objects"
{
    Access = Internal;
    Assignable = false;

    Permissions = Codeunit "Apply Retention Policy" = X,
                  Codeunit "Reten. Pol. Allowed Tables" = X,
                  Codeunit "Retention Policy Log" = X,
                  Codeunit "Retention Policy Setup" = X,
                  Page "Reten. Policy Setup ListPart" = X,
                  Page "Retention Periods" = X,
                  Page "Retention Policy Log Entries" = X,
                  Page "Retention Policy Setup Card" = X,
                  Page "Retention Policy Setup Lines" = X,
                  Page "Retention Policy Setup List" = X,
                  Table "Retention Period" = X,
                  Table "Retention Policy Setup Line" = X,
                  Table "Retention Policy Setup" = X;
}
