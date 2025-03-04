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
                field("Line No."; Rec."E-Document Line Id")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = false;
                    Visible = false;
                }
                field("Line Type"; Rec."Purchase Line Type")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = true;
                }
                field("No."; Rec."Purchase Type No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
                    Editable = true;
                    Lookup = true;
                }
                field(Description; EDocumentPurchaseLine.Description)
                {
                    ApplicationArea = All;
                    StyleExpr = StyleTxt;
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
            }
        }
    }

    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        StyleTxt: Text;
        DimVisible1, DimVisible2 : Boolean;

    trigger OnOpenPage()
    begin
        SetDimensionsVisibility();
    end;

    trigger OnAfterGetRecord()
    begin
        if EDocumentPurchaseLine.Get(Rec."E-Document Line Id") then;
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