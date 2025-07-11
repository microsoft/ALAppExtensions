// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Purchases.Document;
using Microsoft.DemoData.Foundation;

codeunit 13435 "Create Purchase Order FI"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateInvoiceMessage();
    end;

    procedure UpdateInvoiceMessage()
    var
        PurchHeader: Record "Purchase Header";
        CreateVendor: Codeunit "Create Vendor";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        if PurchHeader.FindSet() then
            repeat
                PurchHeader.Validate("Message Type", PurchHeader."Message Type"::Message);
                PurchHeader.Validate("Invoice Message", PurchHeader."No.");

                if PurchHeader."Buy-from Vendor No." = CreateVendor.DomesticFirstUp() then
                    PurchHeader.Validate("Payment Terms Code", CreatePaymentTerms.PaymentTermsDAYS30());

                PurchHeader.Modify(true);
            until PurchHeader.Next() = 0;
    end;
}
