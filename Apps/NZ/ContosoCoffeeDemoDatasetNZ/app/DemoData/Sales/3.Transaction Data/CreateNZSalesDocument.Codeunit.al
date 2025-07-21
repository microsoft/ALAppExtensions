// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.DemoData.Foundation;
using Microsoft.Sales.Document;

codeunit 17140 "Create NZ Sales Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        UpdatePaymentTermsOnSalesHeader(CreatePaymentTerms.PaymentTermsDAYS30());
    end;

    local procedure UpdatePaymentTermsOnSalesHeader(PaymentTermsCode: Code[10]);
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.Validate("Payment Terms Code", PaymentTermsCode);
                SalesHeader.Modify(true);
            until SalesHeader.Next() = 0;
    end;
}
