// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Manufacturing;

using Microsoft.Inventory.Availability;
using Microsoft.Inventory.Requisition;

codeunit 4767 "Create Mfg Order Promising"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Order Promising Setup" = rim,
        tabledata "Req. Wksh. Template" = r,
        tabledata "Requisition Wksh. Name" = r;

    trigger OnRun()
    var
        OrderPromisingSetup: Record "Order Promising Setup";
        ReqWkshTemplate: Record "Req. Wksh. Template";
        RequisitionWkshName: Record "Requisition Wksh. Name";
    begin
        if not OrderPromisingSetup.Get() then
            OrderPromisingSetup.Insert();
        Evaluate(OrderPromisingSetup."Offset (Time)", '<1D>');

        if ReqWkshTemplate.FindFirst() then begin
            OrderPromisingSetup."Order Promising Template" := ReqWkshTemplate.Name;
            RequisitionWkshName.SetRange("Worksheet Template Name", ReqWkshTemplate.Name);
            if RequisitionWkshName.FindFirst() then
                OrderPromisingSetup."Order Promising Worksheet" := RequisitionWkshName.Name;
        end;

        OrderPromisingSetup."Order Promising Nos." := OrderPromisingTok;
        OrderPromisingSetup.Modify();
    end;

    var
        OrderPromisingTok: Label 'O-PROM', MaxLength = 20;
}
