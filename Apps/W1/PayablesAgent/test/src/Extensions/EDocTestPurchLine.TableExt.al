// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Agents.PayablesAgent;
using Microsoft.Purchases.Document;

tableextension 133702 "EDoc. Test Purch Line" extends "Purchase Line"
{
    fields
    {
        /// <summary>
        /// For the PO-matching test scenarios, we specify which line of the invoice matches with which line of a purchase order. We need to store the index of the order line to be able to reference it in the test scenarios.
        /// </summary>
        field(133700; "Created at Index"; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }
}