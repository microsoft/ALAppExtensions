// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

tableextension 18602 "Gate Entry Sales Header" extends "Sales Header"
{
    fields
    {
        field(18601; "LR/RR No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(18602; "LR/RR Date"; Date)
        {
            DataClassification = CustomerContent;
        }
    }
}
