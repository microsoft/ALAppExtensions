// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

enum 18282 "GSTReco Source Type"
{
    value(0; Reconciliation)
    {
        Caption = 'Reconciliation';
    }
    value(1; "Credit - Adjustment")
    {
        Caption = 'Credit - Adjustment';
    }
    value(2; Settlement)
    {
        Caption = 'Settlement';
    }
    value(3; ISD)
    {
        Caption = 'ISD';
    }
}

