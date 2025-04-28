// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Automation;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Foundation.Reporting;

tableextension 6102 "E-Doc. Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        /// <summary>
        /// This field is used to determine if the E-document creation was triggered by action requiring the E-document to be sent via email.
        /// </summary>
        field(6100; "Send E-Document via Email"; Boolean)
        {
            Caption = 'Send E-Document via Email';
            DataClassification = SystemMetadata;
            Editable = false;
            AllowInCustomizations = Never;
            Access = Internal;
        }
    }

    /// <summary>
    /// Creates an E-document for the posted sales invoice.
    /// </summary>
    internal procedure CreateEDocument()
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        Customer: Record Customer;
        Workflow: Record Workflow;
        EDocExport: Codeunit "E-Doc. Export";
        SalesInvoiceRecordRef: RecordRef;
    begin
        SalesInvoiceRecordRef.GetTable(Rec);
        Customer.Get(Rec."Bill-to Customer No.");
        DocumentSendingProfile.Get(Customer."Document Sending Profile");
        Workflow.Get(DocumentSendingProfile."Electronic Service Flow");
        EDocExport.CheckAndCreateEDocument(SalesInvoiceRecordRef, Workflow, "E-Document Type"::"Sales Invoice");
    end;

    /// <summary>
    /// Creates and emails an E-document for the posted sales invoice.
    /// </summary>
    internal procedure CreateAndEmailEDocument()
    begin
        Rec."Send E-Document via Email" := true;
        Rec.CreateEDocument();
        Rec.EmailEDocument(true);
    end;

    /// <summary>
    /// Emails an E-document for the posted sales invoice with existing E-document.
    /// </summary>
    /// <param name="ShowDialog">Determines if the email dialog should be shown.</param>
    internal procedure EmailEDocument(ShowDialog: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        ReportDistributionMgt: Codeunit "Report Distribution Management";
        DocumentTypeTxt: Text[50];
    begin
        DocumentTypeTxt := ReportDistributionMgt.GetFullDocumentTypeText(Rec);

        SalesInvoiceHeader := Rec;
        SalesInvoiceHeader.SetRecFilter();

        Customer.Get(Rec."Bill-to Customer No.");
        DocumentSendingProfile.Get(Customer."Document Sending Profile");

        DocumentSendingProfile.TrySendToEMailWithEDocument(
            Enum::"Report Selection Usage"::"S.Invoice".AsInteger(),
            SalesInvoiceHeader,
            Rec.FieldNo("No."),
            DocumentTypeTxt,
            Rec.FieldNo("Bill-to Customer No."),
            ShowDialog);
    end;
}
