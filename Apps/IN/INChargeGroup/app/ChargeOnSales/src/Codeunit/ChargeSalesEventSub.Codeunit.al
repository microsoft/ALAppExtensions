// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup.ChargeOnSales;

using Microsoft.Finance.ChargeGroup.ChargeGroupBase;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;

codeunit 18600 "Charge Sales Event Sub"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure CheckChargeGroupOnSalesDocBeforePost(var SalesHeader: Record "Sales Header")
    begin
        CheckChargeGroupOnSalesDoc(SalesHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnValidateNoOnCopyFromTempSalesLine', '', false, false)]
    local procedure CopyFromTempSalesLine(var SalesLine: Record "Sales Line"; var TempSalesLine: Record "Sales Line" temporary; xSalesLine: Record "Sales Line")
    begin
        CopyValuesFromTempSalesLineForChageGroup(SalesLine, xSalesLine);
    end;

    local procedure CheckChargeGroupOnSalesDoc(var SalesHeader: Record "Sales Header")
    var
        ChargeGroupManagement: Codeunit "Charge Group Management";
    begin
        if SalesHeader."Charge Group Code" <> '' then
            ChargeGroupManagement.CheckChargeLinesOnDoc(SalesHeader);
    end;

    local procedure CopyValuesFromTempSalesLineForChageGroup(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line")
    begin
        SalesLine."Charge Group Code" := xSalesLine."Charge Group Code";
        SalesLine."Charge Group Line No." := xSalesLine."Charge Group Line No.";
    end;
}
