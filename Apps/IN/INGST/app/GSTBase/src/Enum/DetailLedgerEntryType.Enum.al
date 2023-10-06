// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

enum 18013 "Detail Ledger Entry Type"
{
    value(0; "Initial Entry")
    {
        Caption = 'Initial Entry';
    }
    value(1; Application)
    {
        Caption = 'Application';
    }
    value(2; "Adjustment Entry")
    {
        Caption = 'Adjustment Entry';
    }
}
