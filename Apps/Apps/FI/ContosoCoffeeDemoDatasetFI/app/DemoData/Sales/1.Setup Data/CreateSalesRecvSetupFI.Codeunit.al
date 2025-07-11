// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.DemoData.Foundation;
using Microsoft.Sales.Setup;

codeunit 13456 "Create Sales Recv. Setup FI"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        UpdateSalesReceivablesSetup();
    end;

    local procedure UpdateSalesReceivablesSetup()
    var
        CreateJobQueueCategory: Codeunit "Create Job Queue Category";
    begin
        ValidateRecordFields(CreateJobQueueCategory.SalesPurchasePosting(), true, true, true);
    end;

    local procedure ValidateRecordFields(JobQueueCategoryCode: Code[10]; InvoiceNo: Boolean; CustomerNo: Boolean; PrintReferenceNo: Boolean)
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.Validate("Job Queue Category Code", JobQueueCategoryCode);
        SalesReceivablesSetup.Validate("Invoice No.", InvoiceNo);
        SalesReceivablesSetup.Validate("Customer No.", CustomerNo);
        SalesReceivablesSetup.Validate("Print Reference No.", PrintReferenceNo);
        SalesReceivablesSetup.Modify(true);
    end;
}
