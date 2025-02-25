// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Foundation.Reporting;

tableextension 6103 "E-Doc. Sales Cr. Memo Header" extends "Sales Cr.Memo Header"
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
    /// Creates an E-document for the posted sales credit memo.
    /// </summary>
    internal procedure CreateEDocument()
    var
        EDocExport: Codeunit "E-Doc. Export";
        SalesCrMemoRecordRef: RecordRef;
    begin
        SalesCrMemoRecordRef.GetTable(Rec);
        EDocExport.CheckAndCreateEDocument(SalesCrMemoRecordRef);
    end;

    /// <summary>
    /// Creates and emails an E-document for the posted sales credit memo.
    /// </summary>
    internal procedure CreateAndEmailEDocument()
    begin
        Rec."Send E-Document via Email" := true;
        Rec.CreateEDocument();
        Rec.EmailEDocument(true);
    end;

    /// <summary>
    /// Emails an E-document for the posted sales credit memo with existing E-document.
    /// </summary>
    /// <param name="ShowDialog">Determines if the email dialog should be shown.</param>
    internal procedure EmailEDocument(ShowDialog: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        SalesCreditMemoHeader: Record "Sales Cr.Memo Header";
        Customer: Record Customer;
        ReportDistributionMgt: Codeunit "Report Distribution Management";
        DocumentTypeTxt: Text[50];
    begin
        DocumentTypeTxt := ReportDistributionMgt.GetFullDocumentTypeText(Rec);

        SalesCreditMemoHeader := Rec;
        SalesCreditMemoHeader.SetRecFilter();

        Customer.Get(Rec."Bill-to Customer No.");
        DocumentSendingProfile.Get(Customer."Document Sending Profile");

        DocumentSendingProfile.TrySendToEMailWithEDocument(
            Enum::"Report Selection Usage"::"S.Cr.Memo".AsInteger(),
            Rec,
            Rec.FieldNo("No."),
            DocumentTypeTxt,
            Rec.FieldNo("Bill-to Customer No."),
            ShowDialog);
    end;
}
