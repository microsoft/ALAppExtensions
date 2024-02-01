// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

enumextension 20370 "First Party Signals" extends "Onboarding Signal Type"
{
#pragma warning disable PTE0023 // The IDs should have been in the range [20370..20379]
    value(0; "Purchase Invoice")
    {
        Implementation = "Onboarding Signal" = "Purchase Invoice Signal";
    }

    value(1; "Sales Invoice")
    {
        Implementation = "Onboarding Signal" = "Sales Invoice Signal";
    }

    value(2; "Vendor Payments")
    {
        Implementation = "Onboarding Signal" = "Vendor Payment Signal";
    }

    value(3; "Customer Payments")
    {
        Implementation = "Onboarding Signal" = "Customer Payment Signal";
    }
#pragma warning restore PTE0023 // The IDs should have been in the range [20370..20379]
}