// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Processing.Import;
using Microsoft.Purchases.History;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.eServices.EDocument;

page 6102 "E-Doc Line Values."
{
    PageType = Card;
    Caption = 'Additional fields';
    SourceTable = "E-Document Purchase Line";
    DataCaptionExpression = DataCaption;
    InsertAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            field(RetrievedFrom; RetrievedFromTxt)
            {
                ApplicationArea = All;
                Caption = 'Source';
                Editable = false;
                ToolTip = 'Specifies the source of the values in this line.';
                Visible = HistoricalSource;

                trigger OnDrillDown()
                begin
                    EDocPurchaseHistMapping.OpenPageWithHistoricMatch(Rec);
                end;
            }
            part(EDocLineHistFields; "E-Doc. Line Additional Fields")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(ConfigureFieldsToCopy)
            {
                ApplicationArea = All;
                Caption = 'Configure additional fields';
                ToolTip = 'Configure the additional fields to consider when importing an E-Document.';
                Image = Setup;

                trigger OnAction()
                var
                    EDocument: Record "E-Document";
                    EDocAdditionalFieldsSetup: Page "EDoc Additional Fields Setup";
                begin
                    EDocument.Get(Rec."E-Document Entry No.");
                    EDocAdditionalFieldsSetup.SetEDocumentService(EDocument.GetEDocumentService());
                    EDocAdditionalFieldsSetup.RunModal();
                end;
            }
        }
    }

    var
        EDocPurchaseLineHistory: Record "E-Doc. Purchase Line History";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        PurchaseInvoiceLine: Record "Purch. Inv. Line";
        EDocPurchaseHistMapping: Codeunit "E-Doc. Purchase Hist. Mapping";
        RetrievedFromTxt, DataCaption : Text;
        HistoricalSource: Boolean;
        PageCaptionLbl: Label 'E-Document %1, line %2', Comment = '%1 - E-Document No.,%2 = Line No.';
        HistoricSourceLbl: Label 'Historical values from invoice %1 - %2', Comment = '%1 = Invoice No., %2 = Line No.';

    trigger OnOpenPage()
    var
    begin
        if EDocPurchaseLineHistory.Get(Rec."E-Doc. Purch. Line History Id") then;
        if PurchaseInvoiceLine.GetBySystemId(EDocPurchaseLineHistory."Purch. Inv. Line SystemId") then;
        if PurchaseInvoiceHeader.Get(PurchaseInvoiceLine."Document No.") then;
        HistoricalSource := PurchaseInvoiceHeader."No." <> '';
        RetrievedFromTxt := StrSubstNo(HistoricSourceLbl, PurchaseInvoiceHeader."No.", PurchaseInvoiceLine."Line No.");
        DataCaption := StrSubstNo(PageCaptionLbl, Rec."E-Document Entry No.", Rec."Line No.");
        CurrPage.EDocLineHistFields.Page.SetEDocumentLine(Rec, PurchaseInvoiceLine);
    end;

}