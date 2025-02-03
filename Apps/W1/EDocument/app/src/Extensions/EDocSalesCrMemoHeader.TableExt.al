// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Sales.History;
using Microsoft.Foundation.Reporting;

tableextension 6103 "E-Doc. Sales Cr. Memo Header" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(6100; "Send E-Document via Email"; Boolean)
        {
            Caption = 'Send E-Document via Email';
            DataClassification = SystemMetadata;
            Editable = false;
            AllowInCustomizations = Never;
            Access = Internal;
        }
    }

    internal procedure CreateEDocument()
    var
        EDocExport: Codeunit "E-Doc. Export";
        SalesCrMemoRecordRef: RecordRef;
    begin
        SalesCrMemoRecordRef.GetTable(Rec);
        EDocExport.CreateEDocumentForPostedDocument(SalesCrMemoRecordRef);
    end;

    internal procedure CreateAndEmailEDocument()
    begin
        Rec."Send E-Document via Email" := true;
        Rec.CreateEDocument();
        Rec.EmailEDocument(true);
    end;

    internal procedure EmailEDocument(ShowDialog: Boolean)
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        SalesCreditMemoHeader: Record "Sales Cr.Memo Header";
        ReportDistributionMgt: Codeunit "Report Distribution Management";
        DocumentTypeTxt: Text[50];
    begin
        DocumentTypeTxt := ReportDistributionMgt.GetFullDocumentTypeText(Rec);

        SalesCreditMemoHeader := Rec;
        SalesCreditMemoHeader.SetRecFilter();

        DocumentSendingProfile.TrySendToEMailWithEDocument(
            Enum::"Report Selection Usage"::"S.Cr.Memo".AsInteger(), Rec, Rec.FieldNo("No."), DocumentTypeTxt,
            Rec.FieldNo("Bill-to Customer No."), ShowDialog);
    end;
}
