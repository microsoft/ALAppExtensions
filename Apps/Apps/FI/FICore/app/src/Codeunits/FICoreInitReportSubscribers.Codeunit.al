// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.FinancialReports;

using Microsoft.Foundation.Company;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;

codeunit 13411 "FICore InitReport Subscribers"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Company Information" = r;

    [EventSubscriber(ObjectType::Report, Report::"Standard Purchase - Order", 'OnInitReportForGlobalVariable', '', false, false)]
    local procedure OnInitReportForGlobalVariableInStandardPurchaseOrder(var IsHandled: Boolean; var LegalOfficeTxt: Text; var LegalOfficeLbl: Text)
    begin
        if IsHandled then
            exit;

        AssignLegalOfficeTexts(LegalOfficeTxt, LegalOfficeLbl);

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Credit Memo", 'OnInitReportForGlobalVariable', '', false, false)]
    local procedure OnInitReportForGlobalVariableInStandardSalesCreditMemo(var IsHandled: Boolean; var LegalOfficeTxt: Text; var LegalOfficeLbl: Text)
    begin
        if IsHandled then
            exit;

        AssignLegalOfficeTexts(LegalOfficeTxt, LegalOfficeLbl);

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Draft Invoice", 'OnInitReportForGlobalVariable', '', false, false)]
    local procedure OnInitReportForGlobalVariableInStandardSalesDraftInvoice(var IsHandled: Boolean; var LegalOfficeTxt: Text; var LegalOfficeLbl: Text)
    begin
        if IsHandled then
            exit;

        AssignLegalOfficeTexts(LegalOfficeTxt, LegalOfficeLbl);

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Invoice", 'OnInitReportForGlobalVariable', '', false, false)]
    local procedure OnInitReportForGlobalVariableInStandardSalesInvoice(var IsHandled: Boolean; var LegalOfficeTxt: Text; var LegalOfficeLbl: Text)
    begin
        if IsHandled then
            exit;

        AssignLegalOfficeTexts(LegalOfficeTxt, LegalOfficeLbl);

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Order Conf.", 'OnInitReportForGlobalVariable', '', false, false)]
    local procedure OnInitReportForGlobalVariableInStandardSalesOrderConf(var IsHandled: Boolean; var LegalOfficeTxt: Text; var LegalOfficeLbl: Text)
    begin
        if IsHandled then
            exit;

        AssignLegalOfficeTexts(LegalOfficeTxt, LegalOfficeLbl);

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Pro Forma Inv", 'OnInitReportForGlobalVariable', '', false, false)]
    local procedure OnInitReportForGlobalVariableInStandardSalesProFormaInv(var IsHandled: Boolean; var LegalOfficeTxt: Text; var LegalOfficeLbl: Text)
    begin
        if IsHandled then
            exit;

        AssignLegalOfficeTexts(LegalOfficeTxt, LegalOfficeLbl);

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Quote", 'OnInitReportForGlobalVariable', '', false, false)]
    local procedure OnInitReportForGlobalVariableInStandardSalesQuote(var IsHandled: Boolean; var LegalOfficeTxt: Text; var LegalOfficeLbl: Text)
    begin
        if IsHandled then
            exit;

        AssignLegalOfficeTexts(LegalOfficeTxt, LegalOfficeLbl);

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Return Rcpt.", 'OnInitReportForGlobalVariable', '', false, false)]
    local procedure OnInitReportForGlobalVariableInStandardSalesReturnRcpt(var IsHandled: Boolean; var LegalOfficeTxt: Text; var LegalOfficeLbl: Text)
    begin
        if IsHandled then
            exit;

        AssignLegalOfficeTexts(LegalOfficeTxt, LegalOfficeLbl);

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Sales - Shipment", 'OnInitReportForGlobalVariable', '', false, false)]
    local procedure OnInitReportForGlobalVariableInStandardSalesShipment(var IsHandled: Boolean; var LegalOfficeTxt: Text; var LegalOfficeLbl: Text)
    begin
        if IsHandled then
            exit;

        AssignLegalOfficeTexts(LegalOfficeTxt, LegalOfficeLbl);

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Standard Statement", 'OnInitReportForGlobalVariable', '', false, false)]
    local procedure OnInitReportForGlobalVariableInStandardStatement(var IsHandled: Boolean; var LegalOfficeTxt: Text; var LegalOfficeLbl: Text)
    begin
        if IsHandled then
            exit;

        AssignLegalOfficeTexts(LegalOfficeTxt, LegalOfficeLbl);

        IsHandled := true;
    end;

    local procedure AssignLegalOfficeTexts(var LegalOfficeTxt: Text; var LegalOfficeLbl: Text)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        LegalOfficeTxt := CompanyInformation."Registered Home City";
        LegalOfficeLbl := CompanyInformation.FieldCaption(CompanyInformation."Registered Home City");
    end;
}
