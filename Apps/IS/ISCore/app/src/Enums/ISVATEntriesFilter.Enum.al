// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT;

enum 14601 "IS VAT Entries Filter"
{
    Extensible = false;
    AssignmentCompatibility = true;

    value(0; "All") { Caption = 'All'; }
    value(1; "Open") { Caption = 'Open'; }
    value(2; "Closed") { Caption = 'Closed'; }
}

