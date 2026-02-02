// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

enum 10831 "Payment Step Action Type FR"
{
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "None") { Caption = 'None'; }
    value(1; "Ledger") { Caption = 'Ledger'; }
    value(2; "Report") { Caption = 'Report'; }
    value(3; "File") { Caption = 'File'; }
    value(4; "Create New Document") { Caption = 'Create New Document'; }
    value(5; "Cancel File") { Caption = 'Cancel File'; }
}