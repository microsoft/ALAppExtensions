// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

tableextension 18661 "Sales Header" extends "Sales Header"
{
    fields
    {
        field(18661; "TDS Certificate Receivable"; Boolean)
        {
            DataClassification = CustomerContent;

        }
    }
}
