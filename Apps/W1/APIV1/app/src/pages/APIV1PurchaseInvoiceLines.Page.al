namespace Microsoft.API.V1;

using Microsoft.Foundation.UOM;
using Microsoft.Integration.Entity;
using Microsoft.Integration.Graph;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using System.Reflection;

page 20047 "APIV1 - Purchase Invoice Lines"
{
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Purch. Inv. Line Aggregate";
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
                    ToolTip = 'Specifies the purchase invoice lines sequence.';

                    trigger OnValidate()
                    begin
                        if (xRec."Line No." <> Rec."Line No.") and (xRec."Line No." <> 0) then
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
                    ToolTip = 'Specifies the description of the purchase invoice line.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Description));
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
                        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
                        GraphCollectionMgtItem: Codeunit "Graph Collection Mgt - Item";
                    begin
                        PurchInvAggregator.VerifyCanUpdateUOM(Rec);
                        GraphCollectionMgtItem.ParseJSONToUnitOfMeasure(UnitOfMeasureJSON, TempUnitOfMeasure);
                        Rec."Unit of Measure Code" := TempUnitOfMeasure.Code;
                        RegisterFieldSet(Rec.FieldNo("Unit of Measure Code"));

                        if InsertItem then
                            exit;

                        PurchInvAggregator.UpdateUnitOfMeasure(Item, UnitOfMeasureJSON);
                    end;
                }
                field(unitCost; Rec."Direct Unit Cost")
                {
                    ApplicationArea = All;
                    Caption = 'directUnitCost', Locked = true;
                    ToolTip = 'Specifies the direct unit cost.';

                    trigger OnValidate()
                    begin
                        if InsertItem then begin
                            Item."Unit Cost" := Rec."Direct Unit Cost";
                            RegisterFieldSet(Item.FieldNo("Unit Cost"));
                        end;

                        RegisterFieldSet(Rec.FieldNo("Direct Unit Cost"));
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
                    Caption = 'discountAppliedBeforeTax';
                    ToolTip = 'Specifies the discount applied before tax.';
                }
                field(amountExcludingTax; Rec."Line Amount Excluding Tax")
                {
                    ApplicationArea = All;
                    Caption = 'amountExcludingTax', Locked = true;
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
                            RegisterFieldSet(Rec.FieldNo("Tax Code"));
                        end;
                    end;
                }
                field(taxPercent; Rec."VAT %")
                {
                    ApplicationArea = All;
                    Caption = 'taxPercent', Locked = true;
                    ToolTip = 'Specifies the tax percent.';
                }
                field(totalTaxAmount; Rec."Line Tax Amount")
                {
                    ApplicationArea = All;
                    Caption = 'totalTaxAmount', Locked = true;
                    ToolTip = 'Specifies the tax amount.';
                }
                field(amountIncludingTax; Rec."Line Amount Including Tax")
                {
                    ApplicationArea = All;
                    Caption = 'amountIncludingTax', Locked = true;
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
                    ToolTip = 'Specifies the invoice discount amount excluding tax.';
                }
                field(netAmount; Rec.Amount)
                {
                    ApplicationArea = All;
                    Caption = 'netAmount', Locked = true;
                    ToolTip = 'Specifies the net amount.';
                }
                field(netTaxAmount; Rec."Tax Amount")
                {
                    ApplicationArea = All;
                    Caption = 'netTaxAmount', Locked = true;
                    ToolTip = 'Specifies the net tax amount.';
                }
                field(netAmountIncludingTax; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    Caption = 'netAmountIncludingTax', Locked = true;
                    ToolTip = 'Specifies the net amount including tax.';
                }
                field(expectedReceiptDate; Rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                    Caption = 'expectedReceiptDate', Locked = true;
                    ToolTip = 'Specifies the expected receipt date.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Expected Receipt Date"));
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
    var
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
    begin
        PurchInvAggregator.PropagateDeleteLine(Rec);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
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
            PurchInvAggregator.LoadLines(Rec, DocumentIdFilter);
            Rec.SETVIEW(FilterView);
            if not Rec.FINDFIRST() then
                exit(false);
            LinesLoaded := true;
        end;

        exit(true);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
    begin
        if InsertItem then
            InsertItemOnTheFly();
        PurchInvAggregator.PropagateInsertLine(Rec, TempFieldBuffer);
    end;

    trigger OnModifyRecord(): Boolean
    var
        PurchInvAggregator: Codeunit "Purch. Inv. Aggregator";
    begin
        if InsertItem then
            InsertItemOnTheFly();
        PurchInvAggregator.PropagateModifyLine(Rec, TempFieldBuffer);
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
        UnitOfMeasureJSON: Text;
        LineObjectDetailsJSON: Text;
        LinesLoaded: Boolean;
        InsertItem: Boolean;
        IDOrDocumentIdShouldBeSpecifiedForLinesErr: Label 'You must specify an Id or a Document Id to get the lines.', Locked = true;
        CannotChangeIdNoErr: Label 'The value for id cannot be modified.', Locked = true;
        CannotChangeDocumentIdNoErr: Label 'The value for documentId cannot be modified.', Locked = true;
        CannotChangeLineNoErr: Label 'The value for sequence cannot be modified. Delete and insert the line again.', Locked = true;
        BothItemIdAndAccountIdAreSpecifiedErr: Label 'Both itemId and accountId are specified. Specify only one of them.';

    local procedure RegisterFieldSet(FieldNo: Integer)
    var
        LastOrderNo: Integer;
    begin
        LastOrderNo := 1;
        if TempFieldBuffer.FINDLAST() then
            LastOrderNo := TempFieldBuffer.Order + 1;

        CLEAR(TempFieldBuffer);
        TempFieldBuffer.Order := LastOrderNo;
        TempFieldBuffer."Table ID" := DATABASE::"Purch. Inv. Line Aggregate";
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
    end;

    local procedure SetCalculatedFields()
    var
        GraphMgtPurchInvLines: Codeunit "Graph Mgt - Purch. Inv. Lines";
        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
    begin
        LineObjectDetailsJSON := GraphMgtComplexTypes.GetPurchaseLineDescriptionComplexType(Rec);
        UnitOfMeasureJSON := GraphMgtPurchInvLines.GetUnitOfMeasureJSON(Rec);
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
