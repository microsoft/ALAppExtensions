// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.DemoData.Finance;
using Microsoft.Sales.Setup;

codeunit 10719 "Create Sales Rec. Setup NO"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateVatPostingGroupsNO: Codeunit "Create Vat Posting Groups NO";
    begin
        UpdateSaleReceivableSetup(CreateVatPostingGroupsNO.CUSTHIGH());
    end;

    local procedure UpdateSaleReceivableSetup(VATBusPostingGrPrice: Code[20])
    var
        SalesReceivableSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivableSetup.Get();
        SalesReceivableSetup.Validate("VAT Bus. Posting Gr. (Price)", VATBusPostingGrPrice);
        SalesReceivableSetup.Modify(true);
    end;
}
