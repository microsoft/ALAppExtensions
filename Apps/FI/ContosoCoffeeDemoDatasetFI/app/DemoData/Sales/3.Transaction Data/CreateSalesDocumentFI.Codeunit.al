// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.Sales.Document;
using Microsoft.DemoData.Foundation;

codeunit 13446 "Create Sales Document FI"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        CreateCustomer: Codeunit "Create Customer";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        SalesHeader.SetRange("Sell-to Customer No.", CreateCustomer.DomesticTreyResearch());
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.Validate("Payment Terms Code", CreatePaymentTerms.PaymentTermsDAYS30());
                SalesHeader.Modify(true);
            until SalesHeader.Next() = 0;
    end;
}
