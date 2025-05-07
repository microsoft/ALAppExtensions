// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AS0031, AS0032
namespace Microsoft.eServices.EDocument.Processing.Import.Purchase;

using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.Finance.Dimension;

page 6183 "E-Doc. Purchase Draft Subform"
{

    AutoSplitKey = true;
    Caption = 'Lines';
    InsertAllowed = false;
    LinksAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    PageType = ListPart;
    SourceTable = "E-Document Line Mapping";

    layout
    {
        area(Content)
        {
            repeater(DocumentLines)
            {
                field("Line Type"; Rec."Purchase Line Type")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("No."; Rec."Purchase Type No.")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Lookup = true;
                }
                field(Description; EDocumentPurchaseLine.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit Of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Lookup = true;
                }
                field(Quantity; EDocumentPurchaseLine.Quantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Direct Unit Cost"; EDocumentPurchaseLine."Unit Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Deferral Code"; Rec."Deferral Code")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    Visible = DimVisible1;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
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
                        Page.Run(Page::"E-Doc Line Values.", Rec);
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
        }
    }

    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocPurchaseHistMapping: Codeunit "E-Doc. Purchase Hist. Mapping";
        AdditionalColumns: Text;
        DimVisible1, DimVisible2, HasAdditionalColumns : Boolean;
        HistoryCantBeRetrievedErr: Label 'The purchase invoice that matched historically with this line can''t be opened.';

    trigger OnOpenPage()
    var
        EDocPurchLineFieldSetup: Record "EDoc. Purch. Line Field Setup";
    begin
        SetDimensionsVisibility();
        HasAdditionalColumns := not EDocPurchLineFieldSetup.IsEmpty();
    end;

    trigger OnAfterGetRecord()
    begin
        if EDocumentPurchaseLine.Get(Rec."E-Document Entry No.", Rec."Line No.") then;
        AdditionalColumns := Rec.AdditionalColumnsDisplayText();
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

}
#pragma warning restore AS0031, AS0032