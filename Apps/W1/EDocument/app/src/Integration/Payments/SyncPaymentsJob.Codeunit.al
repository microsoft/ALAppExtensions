// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Payments;

using System.Threading;
using Microsoft.eServices.EDocument;

codeunit 6119 "Sync Payments Job"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        EDocumentService.Get(Rec."Record ID to Process");
        if EDocumentService."Payment Integration" = EDocumentService."Payment Integration"::"No Integration" then
            exit;

        EDocumentServiceStatus.SetRange("E-Document Service Code", EDocumentService."Code");
        if EDocumentServiceStatus.FindSet() then
            repeat
                EDocument.Get(EDocumentServiceStatus."E-Document Entry No");
                if EDocument."Direction" = EDocument.Direction::Incoming then
                    this.SendPayments(EDocument, EDocumentService)
                else
                    this.ReceivePayments(EDocument, EDocumentService);
            until EDocumentServiceStatus.Next() = 0;
    end;

    local procedure SendPayments(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service")
    var
        PaymentContext: Codeunit PaymentContext;
        PaymentIntegrationManagement: Codeunit "Payment Integration Management";
    begin
        PaymentIntegrationManagement.SendPayments(EDocument, EDocumentService, PaymentContext);
    end;

    local procedure ReceivePayments(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service")
    var
        PaymentContext: Codeunit PaymentContext;
        PaymentIntegrationManagement: Codeunit "Payment Integration Management";
    begin
        PaymentIntegrationManagement.ReceivePayments(EDocument, EDocumentService, PaymentContext);
    end;
}