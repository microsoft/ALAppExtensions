// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Agents.PayablesAgent;
using Microsoft.Purchases.Document;

tableextension 133701 "EDoc. Test Purch. Head." extends "Purchase Header"
{
    fields
    {
        /// <summary>
        /// For the PO-matching test scenarios, we specify which line of the invoice matches with which line of a purchase order. Since we create several purchase orders, we need to store the index of the invoice header to be able to reference it in the test scenarios.
        /// </summary>
        field(133700; "Created at Index"; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }
}