namespace Microsoft.API.V1;

using Microsoft.Foundation.UOM;
using Microsoft.Integration.Entity;
using Microsoft.Integration.Graph;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using System.Reflection;

page 20046 "APIV1 - Sales Credit Mem Lines"
{
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Sales Invoice Line Aggregate";
    SourceTableTemporary = true;
    ODataKeyFields = Id;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.Id)
                {
                    ApplicationArea = All;
                    Caption = 'id', Locked = true;
                    ToolTip = 'Specifies the ID.';

                    trigger OnValidate()
                    begin
                        if xRec.Id <> Rec.Id then
                            error(CannotChangeIdNoErr);
                    end;
                }
                field(documentId; Rec."Document Id")
                {
                    ApplicationArea = All;
                    Caption = 'documentId', Locked = true;
                    ToolTip = 'Specifies the Document ID.';

                    trigger OnValidate()
                    begin
                        if (not IsNullGuid(xRec."Document Id")) and (xRec."Document Id" <> Rec."Document Id") then
                            error(CannotChangeDocumentIdNoErr);
                    end;
                }
                field(sequence; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Caption = 'sequence', Locked = true;
                    ToolTip = 'Specifies the sales credit memo lines sequence.';

                    trigger OnValidate()
                    begin
                        if (xRec."Line No." <> Rec."Line No.") and
                           (xRec."Line No." <> 0)
                        then
                            error(CannotChangeLineNoErr);

                        RegisterFieldSet(Rec.FieldNo("Line No."));
                    end;
                }
                field(itemId; Rec."Item Id")
                {
                    ApplicationArea = All;
                    Caption = 'itemId', Locked = true;
                    ToolTip = 'Specifies the Item Id.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Type));
                        RegisterFieldSet(Rec.FieldNo("No."));
                        RegisterFieldSet(Rec.FieldNo("Item Id"));

                        if not Item.GetBySystemId(Rec."Item Id") then begin
                            InsertItem := true;
                            exit;
                        end;

                        Rec."No." := Item."No.";
                    end;
                }
                field(accountId; Rec."Account Id")
                {
                    ApplicationArea = All;
                    Caption = 'accountId', Locked = true;
                    ToolTip = 'Specifies the Account Id.';

                    trigger OnValidate()
                    var
                        EmptyGuid: Guid;
                    begin
                        if Rec."Account Id" <> EmptyGuid then
                            if Item."No." <> '' then
                                error(BothItemIdAndAccountIdAreSpecifiedErr);
                        RegisterFieldSet(Rec.FieldNo(Type));
                        RegisterFieldSet(Rec.FieldNo("Account Id"));
                        RegisterFieldSet(Rec.FieldNo("No."));
                    end;
                }
                field(lineType; Rec."API Type")
                {
                    ApplicationArea = All;
                    Caption = 'lineType', Locked = true;
                    ToolTip = 'Specifies the API Type.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Type));
                    end;
                }
                field(lineDetails; LineObjectDetailsJSON)
                {
                    ApplicationArea = All;
                    Caption = 'lineDetails', Locked = true;
#pragma warning disable AL0667
                    ODataEDMType = 'DOCUMENTLINEOBJECTDETAILS';
#pragma warning restore
                    ToolTip = 'Specifies details about the line.';

                    trigger OnValidate()
                    var
                        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
                    begin
                        if not InsertItem then
                            exit;

                        GraphMgtComplexTypes.ParseDocumentLineObjectDetailsFromJSON(
                          LineObjectDetailsJSON, Item."No.", Item.Description, Item."Description 2");

                        if Item."No." <> '' then
                            RegisterItemFieldSet(Item.FieldNo("No."));

                        RegisterFieldSet(Rec.FieldNo("No."));

                        if Item.Description <> '' then
                            RegisterItemFieldSet(Item.FieldNo(Description));

                        if Rec.Description = '' then begin
                            Rec.Description := Item.Description;
                            RegisterFieldSet(Rec.FieldNo(Description));
                        end;

                        if Item."Description 2" <> '' then begin
                            Rec."Description 2" := Item."Description 2";
                            RegisterItemFieldSet(Item.FieldNo("Description 2"));
                            RegisterFieldSet(Rec.FieldNo("Description 2"));
                        end;
                    end;
                }
                field(description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'description';
                    ToolTip = 'Specifies the description of the sales credit memo line.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Description));
                    end;
                }
                field(unitOfMeasureId; UnitOfMeasureIdGlobal)
                {
                    ApplicationArea = All;
                    Caption = 'UnitOfMeasureId', Locked = true;
                    ToolTip = 'Specifies Unit of Measure.';

                    trigger OnValidate()
                    var
                        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
                        GraphMgtSalesInvLines: Codeunit "Graph Mgt - Sales Inv. Lines";
                        BlankGUID: Guid;
                    begin
                        SalesInvoiceAggregator.VerifyCanUpdateUOM(Rec);

                        if (UnitOfMeasureJSON = 'null') and (Rec."Unit of Measure Id" <> BlankGUID) then
                            exit;

                        if Rec."Unit of Measure Id" = BlankGUID then
                            Rec."Unit of Measure Code" := ''
                        else begin
                            if not UnitOfMeasureGlobal.GetBySystemId(Rec."Unit of Measure Id") then
                                error(UnitOfMeasureIdDoesNotMatchAUnitOfMeasureErr);

                            Rec."Unit of Measure Code" := UnitOfMeasureGlobal.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Unit of Measure Code"));

                        if InsertItem then
                            exit;

                        if Item.GetBySystemId(Rec."Item Id") then
                            SalesInvoiceAggregator.UpdateUnitOfMeasure(Item, GraphMgtSalesInvLines.GetUnitOfMeasureJSON(Rec));
                    end;
                }
                field(unitOfMeasure; UnitOfMeasureJSON)
                {
                    ApplicationArea = All;
                    Caption = 'unitOfMeasure', Locked = true;
#pragma warning disable AL0667
                    ODataEDMType = 'ITEM-UOM';
#pragma warning restore
                    ToolTip = 'Specifies Unit of Measure.';

                    trigger OnValidate()
                    var
                        TempUnitOfMeasure: Record "Unit of Measure" temporary;
                        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
                        GraphCollectionMgtItem: Codeunit "Graph Collection Mgt - Item";
                        GraphMgtSalesInvLines: Codeunit "Graph Mgt - Sales Inv. Lines";
                    begin
                        Rec.Validate("Unit of Measure Id", UnitOfMeasureIdGlobal);
                        SalesInvoiceAggregator.VerifyCanUpdateUOM(Rec);

                        if UnitOfMeasureJSON = 'null' then
                            TempUnitOfMeasure.Code := ''
                        else
                            GraphCollectionMgtItem.ParseJSONToUnitOfMeasure(UnitOfMeasureJSON, TempUnitOfMeasure);

                        if (UnitOfMeasureJSON = 'null') and (UnitOfMeasureGlobal.Code <> '') then
                            exit;
                        if (UnitOfMeasureGlobal.Code <> '') and (UnitOfMeasureGlobal.Code <> TempUnitOfMeasure.Code) then
                            error(UnitOfMeasureValuesDontMatchErr);

                        Rec."Unit of Measure Code" := TempUnitOfMeasure.Code;
                        RegisterFieldSet(Rec.FieldNo("Unit of Measure Code"));

                        if InsertItem then
                            exit;

                        if Item.GetBySystemId(Rec."Item Id") then
                            if UnitOfMeasureJSON = 'null' then
                                SalesInvoiceAggregator.UpdateUnitOfMeasure(Item, GraphMgtSalesInvLines.GetUnitOfMeasureJSON(Rec))
                            else
                                SalesInvoiceAggregator.UpdateUnitOfMeasure(Item, UnitOfMeasureJSON);
                    end;
                }
                field(unitPrice; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    Caption = 'unitPrice', Locked = true;
                    ToolTip = 'Specifies the unit price.';

                    trigger OnValidate()
                    begin
                        if InsertItem then begin
                            Item."Unit Price" := Rec."Unit Price";
                            RegisterItemFieldSet(Item.FieldNo("Unit Price"));
                        end;

                        RegisterFieldSet(Rec.FieldNo("Unit Price"));
                    end;
                }
                field(quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Caption = 'quantity', Locked = true;
                    ToolTip = 'Specifies the quantity.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Quantity));
                    end;
                }
                field(discountAmount; Rec."Line Discount Amount")
                {
                    ApplicationArea = All;
                    Caption = 'discountAmount', Locked = true;
                    ToolTip = 'Specifies the line discount amount.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Line Discount Amount"));
                    end;
                }
                field(discountPercent; Rec."Line Discount %")
                {
                    ApplicationArea = All;
                    Caption = 'discountPercent', Locked = true;
                    ToolTip = 'Specifies the line discount percent.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Line Discount %"));
                    end;
                }
                field(discountAppliedBeforeTax; Rec."Discount Applied Before Tax")
                {
                    ApplicationArea = All;
                    Caption = 'discountAppliedBeforeTax', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the discount applied before tax.';
                }
                field(amountExcludingTax; Rec."Line Amount Excluding Tax")
                {
                    ApplicationArea = All;
                    Caption = 'amountExcludingTax', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the line amount excluding tax.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Amount));
                    end;
                }
                field(taxCode; Rec."Tax Code")
                {
                    ApplicationArea = All;
                    Caption = 'taxCode', Locked = true;
                    ToolTip = 'Specifies the tax code.';

                    trigger OnValidate()
                    var
                        GeneralLedgerSetup: Record "General Ledger Setup";
                    begin
                        if InsertItem then begin
                            if GeneralLedgerSetup.UseVat() then
                                exit;

                            Item."Tax Group Code" := COPYSTR(Rec."Tax Code", 1, MAXSTRLEN(Item."Tax Group Code"));
                            RegisterItemFieldSet(Item.FieldNo("Tax Group Code"));
                        end;

                        if GeneralLedgerSetup.UseVat() then begin
                            Rec.Validate("VAT Prod. Posting Group", COPYSTR(Rec."Tax Code", 1, 20));
                            RegisterFieldSet(Rec.FieldNo("VAT Prod. Posting Group"));
                        end else begin
                            Rec.Validate("Tax Group Code", COPYSTR(Rec."Tax Code", 1, 20));
                            RegisterFieldSet(Rec.FieldNo("Tax Group Code"));
                        end;
                    end;
                }
                field(taxPercent; Rec."VAT %")
                {
                    ApplicationArea = All;
                    Caption = 'taxPercent', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the tax percent.';
                }
                field(totalTaxAmount; Rec."Line Tax Amount")
                {
                    ApplicationArea = All;
                    Caption = 'totalTaxAmount', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the tax amount.';
                }
                field(amountIncludingTax; Rec."Line Amount Including Tax")
                {
                    ApplicationArea = All;
                    Caption = 'amountIncludingTax', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the line amount including tax.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Amount Including VAT"));
                    end;
                }
                field(invoiceDiscountAllocation; Rec."Inv. Discount Amount Excl. VAT")
                {
                    ApplicationArea = All;
                    Caption = 'invoiceDiscountAllocation', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the invoice discount amount excluding tax.';
                }
                field(netAmount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'netAmount', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the net amount.';
                }
                field(netTaxAmount; Rec."Tax Amount")
                {
                    ApplicationArea = All;
                    Caption = 'netTaxAmount', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the net tax amount.';
                }
                field(netAmountIncludingTax; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    Caption = 'netAmountIncludingTax', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the net amount including tax.';
                }
                field(shipmentDate; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                    Caption = 'shipmentDate', Locked = true;
                    ToolTip = 'Specifies the shipment date.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Shipment Date"));
                    end;
                }
                field(itemVariantId; Rec."Variant Id")
                {
                    ApplicationArea = All;
                    Caption = 'itemVariantId', Locked = true;
                    ToolTip = 'Specifies the item variant id.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Variant Code"));
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        GraphMgtSalCrMemoBuf.PropagateDeleteLine(Rec);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        GraphMgtSalesInvLines: Codeunit "Graph Mgt - Sales Inv. Lines";
        DocumentIdFilter: Text;
        IdFilter: Text;
        FilterView: Text;
    begin
        if not LinesLoaded then begin
            FilterView := Rec.GetView();
            IdFilter := Rec.GetFilter(Id);
            DocumentIdFilter := Rec.GetFilter("Document Id");
            if (IdFilter = '') and (DocumentIdFilter = '') then
                error(IDOrDocumentIdShouldBeSpecifiedForLinesErr);
            if IdFilter <> '' then
                DocumentIdFilter := GraphMgtSalesInvLines.GetDocumentIdFilterFromIdFilter(IdFilter)
            else
                DocumentIdFilter := Rec.GetFilter("Document Id");
            GraphMgtSalCrMemoBuf.LoadLines(Rec, DocumentIdFilter);
            Rec.SETVIEW(FilterView);
            if not Rec.FINDFIRST() then
                exit(false);
            LinesLoaded := true;
        end;

        exit(true);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if InsertItem then
            InsertItemOnTheFly();

        GraphMgtSalCrMemoBuf.PropagateInsertLine(Rec, TempFieldBuffer);

        SetCalculatedFields();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if InsertItem then
            InsertItemOnTheFly();

        GraphMgtSalCrMemoBuf.PropagateModifyLine(Rec, TempFieldBuffer);

        SetCalculatedFields();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
        Rec.Validate(Type, Rec.Type::Item);
        RegisterFieldSet(Rec.FieldNo(Type));
    end;

    var
        TempFieldBuffer: Record "Field Buffer" temporary;
        TempItemFieldSet: Record 2000000041 temporary;
        Item: Record "Item";
        UnitOfMeasureGlobal: Record "Unit of Measure";
        GraphMgtSalCrMemoBuf: Codeunit "Graph Mgt - Sal. Cr. Memo Buf.";
        UnitOfMeasureJSON: Text;
        LineObjectDetailsJSON: Text;
        LinesLoaded: Boolean;
        IDOrDocumentIdShouldBeSpecifiedForLinesErr: Label 'You must specify an Id or a Document Id to get the lines.', Locked = true;
        CannotChangeIdNoErr: Label 'The value for id cannot be modified.', Locked = true;
        CannotChangeDocumentIdNoErr: Label 'The value for documentId cannot be modified.', Locked = true;
        CannotChangeLineNoErr: Label 'The value for sequence cannot be modified. Delete and insert the line again.', Locked = true;
        InsertItem: Boolean;
        BothItemIdAndAccountIdAreSpecifiedErr: Label 'Both itemId and accountId are specified. Specify only one of them.';
        UnitOfMeasureValuesDontMatchErr: Label 'The unit of measure values do not match to a specific Unit of Measure.', Locked = true;
        UnitOfMeasureIdDoesNotMatchAUnitOfMeasureErr: Label 'The "unitOfMeasureId" does not match to a Unit of Measure.', Locked = true;
        UnitOfMeasureIdGlobal: Guid;

    local procedure RegisterFieldSet(FieldNo: Integer)
    var
        LastOrderNo: Integer;
    begin
        LastOrderNo := 1;
        if TempFieldBuffer.FINDLAST() then
            LastOrderNo := TempFieldBuffer.Order + 1;

        CLEAR(TempFieldBuffer);
        TempFieldBuffer.Order := LastOrderNo;
        TempFieldBuffer."Table ID" := DATABASE::"Sales Invoice Line Aggregate";
        TempFieldBuffer."Field ID" := FieldNo;
        TempFieldBuffer.insert();
    end;

    local procedure ClearCalculatedFields()
    begin
        TempFieldBuffer.RESET();
        TempFieldBuffer.DELETEALL();
        TempItemFieldSet.RESET();
        TempItemFieldSet.DELETEALL();

        CLEAR(Item);
        CLEAR(UnitOfMeasureJSON);
        CLEAR(InsertItem);
        CLEAR(LineObjectDetailsJSON);
        CLEAR(UnitOfMeasureIdGlobal);
    end;

    local procedure SetCalculatedFields()
    var
        GraphMgtSalesInvLines: Codeunit "Graph Mgt - Sales Inv. Lines";
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
    begin
        LineObjectDetailsJSON := GraphMgtComplexTypes.GetSalesLineDescriptionComplexType(Rec);
        UnitOfMeasureJSON := GraphMgtSalesInvLines.GetUnitOfMeasureJSON(Rec);
        UnitOfMeasureIdGlobal := Rec."Unit of Measure Id";
    end;

    local procedure RegisterItemFieldSet(FieldNo: Integer)
    begin
        if TempItemFieldSet.GET(DATABASE::Item, FieldNo) then
            exit;

        TempItemFieldSet.INIT();
        TempItemFieldSet.TableNo := DATABASE::Item;
        TempItemFieldSet.Validate("No.", FieldNo);
        TempItemFieldSet.insert(true);
    end;

    local procedure InsertItemOnTheFly()
    var
        GraphCollectionMgtItem: Codeunit "Graph Collection Mgt - Item";
    begin
        GraphCollectionMgtItem.InsertItemFromSalesDocument(Item, TempItemFieldSet, UnitOfMeasureJSON);
        Rec.Validate("No.", Item."No.");

        if Rec.Description = '' then
            Rec.Description := Item.Description;
    end;
}
