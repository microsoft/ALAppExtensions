// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import.Purchase;

using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.Finance.Dimension;

page 6183 "E-Doc. Purchase Draft Subform"
{

    AutoSplitKey = true;
    Caption = 'Lines';
    InsertAllowed = true;
    LinksAllowed = false;
    DeleteAllowed = true;
    ModifyAllowed = true;
    PageType = ListPart;
    SourceTable = "E-Document Purchase Line";

    layout
    {
        area(Content)
        {
            repeater(DocumentLines)
            {
                field("Line Type"; Rec."[BC] Purchase Line Type")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."[BC] Purchase Type No.")
                {
                    ApplicationArea = All;
                    Lookup = true;
                }
                field("Item Reference No."; Rec."[BC] Item Reference No.")
                {
                    ApplicationArea = All;
                    Lookup = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Unit Of Measure"; Rec."[BC] Unit of Measure")
                {
                    ApplicationArea = All;
                    Lookup = true;
                }
                field("Variant Code"; Rec."[BC] Variant Code")
                {
                    ApplicationArea = All;
                    Lookup = true;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Editable = true;
                    trigger OnValidate()
                    begin
                        CalcLineAmount();
                    end;
                }
                field("Direct Unit Cost"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    Editable = true;
                    trigger OnValidate()
                    begin
                        CalcLineAmount();
                    end;
                }
                field("Total Discount"; Rec."Total Discount")
                {
                    Caption = 'Line Discount';
                    ApplicationArea = All;
                    Editable = true;
                    trigger OnValidate()
                    begin
                        CalcLineAmount();
                    end;
                }
                field("Line Amount"; LineAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Line Amount';
                    ToolTip = 'Specifies the line amount.';
                    Editable = false;
                }
                field("Deferral Code"; Rec."[BC] Deferral Code")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."[BC] Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    Visible = DimVisible1;
                }
                field("Shortcut Dimension 2 Code"; Rec."[BC] Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    Visible = DimVisible2;
                }
                field(AdditionalColumns; AdditionalColumns)
                {
                    ApplicationArea = All;
                    Caption = 'Additional columns';
                    ToolTip = 'Specifies the additional columns considered.';
                    Editable = false;
                    Visible = HasAdditionalColumns;
                    trigger OnDrillDown()
                    begin
                        Page.RunModal(Page::"E-Doc Line Values.", Rec);
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(History)
            {
                ApplicationArea = All;
                Caption = 'Values from history';
                Image = History;
                ToolTip = 'The values for this line were retrieved from previously posted invoices. Open the invoice to see the values.';
                Visible = Rec."E-Doc. Purch. Line History Id" <> 0;
                trigger OnAction()
                begin
                    if not EDocPurchaseHistMapping.OpenPageWithHistoricMatch(Rec) then
                        Error(HistoryCantBeRetrievedErr);
                end;
            }
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;

                group("Related Information")
                {
                    Caption = 'Related Information';
                    action(Dimensions)
                    {
                        AccessByPermission = TableData Dimension = R;
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions';
                        Image = Dimensions;
                        ShortCutKey = 'Alt+D';
                        ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                        trigger OnAction()
                        begin
                            Rec.LookupDimensions();
                        end;
                    }
                }
            }
        }
    }

    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocPurchaseHistMapping: Codeunit "E-Doc. Purchase Hist. Mapping";
        AdditionalColumns: Text;
        LineAmount: Decimal;
        DimVisible1, DimVisible2, HasAdditionalColumns : Boolean;
        HistoryCantBeRetrievedErr: Label 'The purchase invoice that matched historically with this line can''t be opened.';

    trigger OnOpenPage()
    begin
        SetDimensionsVisibility();
    end;

    trigger OnAfterGetRecord()
    begin
        if EDocumentPurchaseLine.Get(Rec."E-Document Entry No.", Rec."Line No.") then;
        AdditionalColumns := Rec.AdditionalColumnsDisplayText();

        SetHasAdditionalColumns();
        CalcLineAmount();
    end;

    local procedure SetDimensionsVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
        DimOther: Boolean;
    begin
        DimVisible1 := false;
        DimVisible2 := false;

        DimMgt.UseShortcutDims(
          DimVisible1, DimVisible2, DimOther, DimOther, DimOther, DimOther, DimOther, DimOther);
    end;

    local procedure CalcLineAmount()
    begin
        LineAmount := (Rec.Quantity * Rec."Unit Price") - Rec."Total Discount";
    end;

    local procedure SetHasAdditionalColumns()
    var
        EDocPurchLineFieldSetup: Record "ED Purchase Line Field Setup";
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
    begin
        if EDocPurchLineFieldSetup.IsEmpty() then begin
            HasAdditionalColumns := false;
            exit;
        end;

        EDocumentPurchaseHeader.Get(Rec."E-Document Entry No.");
        if EDocumentPurchaseHeader."[BC] Vendor No." = '' then begin
            HasAdditionalColumns := false;
            exit;
        end;

        if Rec."E-Doc. Purch. Line History Id" = 0 then begin
            HasAdditionalColumns := false;
            exit;
        end;

        HasAdditionalColumns := true;
    end;

}