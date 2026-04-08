// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Agents.PayablesAgent;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;

tableextension 133700 "EDoc. Test Draft Line" extends "E-Document Purchase Line"
{
    fields
    {
        /// <summary>
        /// For the PO-matching test scenarios, we specify which line of the invoice matches with which line of a purchase order. We need to store the index of the invoice line to be able to reference it in the test scenarios.
        /// </summary>
        field(133700; "Created at Index"; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }
}