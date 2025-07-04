// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.Reporting;

tableextension 6105 "E-Doc Issued Fin. Ch. Memo Hdr" extends "Issued Fin. Charge Memo Header"
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
    /// Creates an E-document for the issued finance charge memo.
    /// </summary>
    internal procedure CreateEDocument()
    var
        EDocExport: Codeunit "E-Doc. Export";
        IssuedFinChargeMemoRecordRef: RecordRef;
    begin
        IssuedFinChargeMemoRecordRef.GetTable(Rec);
        EDocExport.CheckAndCreateEDocument(IssuedFinChargeMemoRecordRef);
    end;

    /// <summary>
    /// Creates and emails an E-document for the issued finance charge memo.
    /// </summary>
    internal procedure CreateAndEmailEDocument()
    begin
        Rec."Send E-Document via Email" := true;
        Rec.CreateEDocument();
        Rec.EmailEDocument(true);
    end;

    /// <summary>
    /// Emails an E-document for the issued finance charge memo with existing E-document.
    /// </summary>
    /// <param name="ShowDialog">Determines if the email dialog should be shown.</param>
    internal procedure EmailEDocument(ShowDialog: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        Customer: Record Customer;
        ReportDistributionMgt: Codeunit "Report Distribution Management";
        DocumentTypeTxt: Text[50];
    begin
        DocumentTypeTxt := ReportDistributionMgt.GetFullDocumentTypeText(Rec);

        IssuedFinChargeMemoHeader := Rec;
        IssuedFinChargeMemoHeader.SetRecFilter();

        Customer.Get(Rec."Customer No.");
        DocumentSendingProfile.Get(Customer."Document Sending Profile");

        DocumentSendingProfile.TrySendToEMailWithEDocument(
            Enum::"Report Selection Usage"::"Fin.Charge".AsInteger(),
            IssuedFinChargeMemoHeader,
            Rec.FieldNo("No."),
            DocumentTypeTxt,
            Rec.FieldNo("Customer No."),
            ShowDialog);
    end;
}