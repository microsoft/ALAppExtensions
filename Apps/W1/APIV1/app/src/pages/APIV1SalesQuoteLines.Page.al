page 20045 "APIV1 - Sales Quote Lines"
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
                field(id; Id)
                {
                    ApplicationArea = All;
                    Caption = 'id', Locked = true;
                    ToolTip = 'Specifies the ID.';

                    trigger OnValidate()
                    begin
                        IF xRec.Id <> Id THEN
                            ERROR(CannotChangeIdNoErr);
                    end;
                }
                field(documentId; "Document Id")
                {
                    ApplicationArea = All;
                    Caption = 'documentId', Locked = true;
                    ToolTip = 'Specifies the Document ID.';

                    trigger OnValidate()
                    begin
                        IF (not IsNullGuid(xRec."Document Id")) and (xRec."Document Id" <> "Document Id") THEN
                            ERROR(CannotChangeDocumentIdNoErr);
                    end;
                }
                field(sequence; "Line No.")
                {
                    ApplicationArea = All;
                    Caption = 'sequence', Locked = true;
                    ToolTip = 'Specifies the sales quote lines sequence.';

                    trigger OnValidate()
                    begin
                        IF (xRec."Line No." <> "Line No.") AND
                           (xRec."Line No." <> 0)
                        THEN
                            ERROR(CannotChangeLineNoErr);

                        RegisterFieldSet(FIELDNO("Line No."));
                    end;
                }
                field(itemId; "Item Id")
                {
                    ApplicationArea = All;
                    Caption = 'itemId', Locked = true;
                    ToolTip = 'Specifies the Item Id.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Type));
                        RegisterFieldSet(FIELDNO("No."));
                        RegisterFieldSet(FIELDNO("Item Id"));

                        IF NOT Item.GetBySystemId("Item Id") THEN BEGIN
                            InsertItem := TRUE;
                            EXIT;
                        END;

                        "No." := Item."No.";
                    end;
                }
                field(accountId; "Account Id")
                {
                    ApplicationArea = All;
                    Caption = 'accountId', Locked = true;
                    ToolTip = 'Specifies the Account Id.';

                    trigger OnValidate()
                    var
                        EmptyGuid: Guid;
                    begin
                        IF "Account Id" <> EmptyGuid THEN
                            IF Item."No." <> '' THEN
                                ERROR(BothItemIdAndAccountIdAreSpecifiedErr);
                        RegisterFieldSet(FIELDNO(Type));
                        RegisterFieldSet(FIELDNO("Account Id"));
                        RegisterFieldSet(FIELDNO("No."));
                    end;
                }
                field(lineType; "API Type")
                {
                    ApplicationArea = All;
                    Caption = 'lineType', Locked = true;
                    ToolTip = 'Specifies the API Type.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Type));
                    end;
                }
                field(lineDetails; LineObjectDetailsJSON)
                {
                    ApplicationArea = All;
                    Caption = 'lineDetails', Locked = true;
                    ODataEDMType = 'DOCUMENTLINEOBJECTDETAILS';
                    ToolTip = 'Specifies details about the line.';

                    trigger OnValidate()
                    var
                        GraphMgtComplexTypes: Codeunit "Graph Mgt - Complex Types";
                    begin
                        IF NOT InsertItem THEN
                            EXIT;

                        GraphMgtComplexTypes.ParseDocumentLineObjectDetailsFromJSON(
                          LineObjectDetailsJSON, Item."No.", Item.Description, Item."Description 2");

                        IF Item."No." <> '' THEN
                            RegisterItemFieldSet(Item.FIELDNO("No."));

                        RegisterFieldSet(FIELDNO("No."));

                        IF Item.Description <> '' THEN
                            RegisterItemFieldSet(Item.FIELDNO(Description));

                        IF Description = '' THEN BEGIN
                            Description := Item.Description;
                            RegisterFieldSet(FIELDNO(Description));
                        END;

                        IF Item."Description 2" <> '' THEN BEGIN
                            "Description 2" := Item."Description 2";
                            RegisterItemFieldSet(Item.FIELDNO("Description 2"));
                            RegisterFieldSet(FIELDNO("Description 2"));
                        END;
                    end;
                }
                field(description; Description)
                {
                    ApplicationArea = All;
                    Caption = 'description';
                    ToolTip = 'Specifies the description of the sales quote line.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Description));
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
                        VALIDATE("Unit of Measure Id", UnitOfMeasureIdGlobal);
                        SalesInvoiceAggregator.VerifyCanUpdateUOM(Rec);

                        IF (UnitOfMeasureJSON = 'null') AND ("Unit of Measure Id" <> BlankGUID) THEN
                            EXIT;

                        IF "Unit of Measure Id" = BlankGUID THEN
                            "Unit of Measure Code" := ''
                        ELSE BEGIN
                            IF NOT UnitOfMeasureGlobal.GetBySystemId("Unit of Measure Id") THEN
                                ERROR(UnitOfMeasureIdDoesNotMatchAUnitOfMeasureErr);

                            "Unit of Measure Code" := UnitOfMeasureGlobal.Code;
                        END;

                        RegisterFieldSet(FIELDNO("Unit of Measure Code"));

                        IF InsertItem THEN
                            EXIT;

                        IF Item.GetBySystemId("Item Id") THEN
                            SalesInvoiceAggregator.UpdateUnitOfMeasure(Item, GraphMgtSalesInvLines.GetUnitOfMeasureJSON(Rec));
                    end;
                }
                field(unitOfMeasure; UnitOfMeasureJSON)
                {
                    ApplicationArea = All;
                    Caption = 'unitOfMeasure', Locked = true;
                    ODataEDMType = 'ITEM-UOM';
                    ToolTip = 'Specifies Unit of Measure.';

                    trigger OnValidate()
                    var
                        TempUnitOfMeasure: Record "Unit of Measure" temporary;
                        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
                        GraphCollectionMgtItem: Codeunit "Graph Collection Mgt - Item";
                        GraphMgtSalesInvLines: Codeunit "Graph Mgt - Sales Inv. Lines";
                    begin
                        SalesInvoiceAggregator.VerifyCanUpdateUOM(Rec);

                        IF UnitOfMeasureJSON = 'null' THEN
                            TempUnitOfMeasure.Code := ''
                        ELSE
                            GraphCollectionMgtItem.ParseJSONToUnitOfMeasure(UnitOfMeasureJSON, TempUnitOfMeasure);

                        IF (UnitOfMeasureJSON = 'null') AND (UnitOfMeasureGlobal.Code <> '') THEN
                            EXIT;
                        IF (UnitOfMeasureGlobal.Code <> '') AND (UnitOfMeasureGlobal.Code <> TempUnitOfMeasure.Code) THEN
                            ERROR(UnitOfMeasureValuesDontMatchErr);

                        "Unit of Measure Code" := TempUnitOfMeasure.Code;
                        RegisterFieldSet(FIELDNO("Unit of Measure Code"));

                        IF InsertItem THEN
                            EXIT;

                        IF Item.GetBySystemId("Item Id") THEN
                            IF UnitOfMeasureJSON = 'null' THEN
                                SalesInvoiceAggregator.UpdateUnitOfMeasure(Item, GraphMgtSalesInvLines.GetUnitOfMeasureJSON(Rec))
                            ELSE
                                SalesInvoiceAggregator.UpdateUnitOfMeasure(Item, UnitOfMeasureJSON);
                    end;
                }
                field(unitPrice; "Unit Price")
                {
                    ApplicationArea = All;
                    Caption = 'unitPrice', Locked = true;
                    ToolTip = 'Specifies the unit price.';

                    trigger OnValidate()
                    begin
                        IF InsertItem THEN BEGIN
                            Item."Unit Price" := "Unit Price";
                            RegisterItemFieldSet(Item.FIELDNO("Unit Price"));
                        END;

                        RegisterFieldSet(FIELDNO("Unit Price"));
                    end;
                }
                field(quantity; Quantity)
                {
                    ApplicationArea = All;
                    Caption = 'quantity', Locked = true;
                    ToolTip = 'Specifies the quantity.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Quantity));
                    end;
                }
                field(discountAmount; "Line Discount Amount")
                {
                    ApplicationArea = All;
                    Caption = 'discountAmount', Locked = true;
                    ToolTip = 'Specifies the line discount amount.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Line Discount Amount"));
                    end;
                }
                field(discountPercent; "Line Discount %")
                {
                    ApplicationArea = All;
                    Caption = 'discountPercent', Locked = true;
                    ToolTip = 'Specifies the line discount percent.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Line Discount %"));
                    end;
                }
                field(discountAppliedBeforeTax; "Discount Applied Before Tax")
                {
                    ApplicationArea = All;
                    Caption = 'discountAppliedBeforeTax';
                    Editable = false;
                    ToolTip = 'Specifies the discount applied before tax.';
                }
                field(amountExcludingTax; "Line Amount Excluding Tax")
                {
                    ApplicationArea = All;
                    Caption = 'amountExcludingTax', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the line amount excluding tax.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Amount));
                    end;
                }
                field(taxCode; "Tax Code")
                {
                    ApplicationArea = All;
                    Caption = 'taxCode', Locked = true;
                    ToolTip = 'Specifies the tax code.';

                    trigger OnValidate()
                    var
                        GeneralLedgerSetup: Record "General Ledger Setup";
                    begin
                        IF InsertItem THEN BEGIN
                            IF GeneralLedgerSetup.UseVat() THEN
                                EXIT;

                            Item."Tax Group Code" := COPYSTR("Tax Code", 1, MAXSTRLEN(Item."Tax Group Code"));
                            RegisterItemFieldSet(Item.FIELDNO("Tax Group Code"));
                        END;

                        IF GeneralLedgerSetup.UseVat() THEN BEGIN
                            VALIDATE("VAT Prod. Posting Group", COPYSTR("Tax Code", 1, 20));
                            RegisterFieldSet(FIELDNO("VAT Prod. Posting Group"));
                        END ELSE BEGIN
                            VALIDATE("Tax Group Code", COPYSTR("Tax Code", 1, 20));
                            RegisterFieldSet(FIELDNO("Tax Group Code"));
                        END;
                    end;
                }
                field(taxPercent; "VAT %")
                {
                    ApplicationArea = All;
                    Caption = 'taxPercent', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the tax percent.';
                }
                field(totalTaxAmount; "Line Tax Amount")
                {
                    ApplicationArea = All;
                    Caption = 'totalTaxAmount', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the tax amount.';
                }
                field(amountIncludingTax; "Line Amount Including Tax")
                {
                    ApplicationArea = All;
                    Caption = 'amountIncludingTax', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the line amount including tax.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Amount Including VAT"));
                    end;
                }
                field(netAmount; Amount)
                {
                    ApplicationArea = All;
                    Caption = 'netAmount', Locked = true;
                    ToolTip = 'Specifies the net amount.';
                }
                field(netTaxAmount; "Tax Amount")
                {
                    ApplicationArea = All;
                    Caption = 'netTaxAmount', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the net tax amount.';
                }
                field(netAmountIncludingTax; "Amount Including VAT")
                {
                    ApplicationArea = All;
                    Caption = 'netAmountIncludingTax', Locked = true;
                    Editable = false;
                    ToolTip = 'Specifies the net amount including tax.';
                }
                field(itemVariantId; "Variant Id")
                {
                    ApplicationArea = All;
                    Caption = 'itemVariantId', Locked = true;
                    ToolTip = 'Specifies the item variant id.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Variant Code"));
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
        GraphMgtSalesQuoteBuffer: Codeunit "Graph Mgt - Sales Quote Buffer";
    begin
        GraphMgtSalesQuoteBuffer.PropagateDeleteLine(Rec);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        GraphMgtSalesQuoteBuffer: Codeunit "Graph Mgt - Sales Quote Buffer";
        GraphMgtSalesInvLines: Codeunit "Graph Mgt - Sales Inv. Lines";
        DocumentIdFilter: Text;
        IdFilter: Text;
        FilterView: Text;
    begin
        IF NOT LinesLoaded THEN BEGIN
            FilterView := GETVIEW();
            IdFilter := GETFILTER(Id);
            DocumentIdFilter := GETFILTER("Document Id");
            IF (IdFilter = '') AND (DocumentIdFilter = '') THEN
                ERROR(IDOrDocumentIdShouldBeSpecifiedForLinesErr);
            IF IdFilter <> '' THEN
                DocumentIdFilter := GraphMgtSalesInvLines.GetDocumentIdFilterFromIdFilter(IdFilter)
            ELSE
                DocumentIdFilter := GETFILTER("Document Id");
            GraphMgtSalesQuoteBuffer.LoadLines(Rec, DocumentIdFilter);
            SETVIEW(FilterView);
            IF NOT FINDFIRST() THEN
                EXIT(FALSE);
            LinesLoaded := TRUE;
        END;

        EXIT(TRUE);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        GraphMgtSalesQuoteBuffer: Codeunit "Graph Mgt - Sales Quote Buffer";
    begin
        IF InsertItem THEN
            InsertItemOnTheFly();

        GraphMgtSalesQuoteBuffer.PropagateInsertLine(Rec, TempFieldBuffer);

        SetCalculatedFields();
    end;

    trigger OnModifyRecord(): Boolean
    var
        GraphMgtSalesQuoteBuffer: Codeunit "Graph Mgt - Sales Quote Buffer";
    begin
        IF InsertItem THEN
            InsertItemOnTheFly();

        GraphMgtSalesQuoteBuffer.PropagateModifyLine(Rec, TempFieldBuffer);

        SetCalculatedFields();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
        VALIDATE(Type, Type::Item);
        RegisterFieldSet(FIELDNO(Type));
    end;

    var
        TempFieldBuffer: Record "Field Buffer" temporary;
        Item: Record "Item";
        TempItemFieldSet: Record 2000000041 temporary;
        UnitOfMeasureGlobal: Record "Unit of Measure";
        InsertItem: Boolean;
        LinesLoaded: Boolean;
        UnitOfMeasureJSON: Text;
        LineObjectDetailsJSON: Text;
        IDOrDocumentIdShouldBeSpecifiedForLinesErr: Label 'You must specify an Id or a Document Id to get the lines.', Locked = true;
        CannotChangeIdNoErr: Label 'The value for id cannot be modified.', Locked = true;
        CannotChangeDocumentIdNoErr: Label 'The value for documentId cannot be modified.', Locked = true;
        CannotChangeLineNoErr: Label 'The value for sequence cannot be modified. Delete and insert the line again.', Locked = true;
        BothItemIdAndAccountIdAreSpecifiedErr: Label 'Both itemId and accountId are specified. Specify only one of them.';
        UnitOfMeasureValuesDontMatchErr: Label 'The unit of measure values do not match a specific Unit of Measure.', Locked = true;
        UnitOfMeasureIdDoesNotMatchAUnitOfMeasureErr: Label 'The "unitOfMeasureId" does not match a Unit of Measure.', Locked = true;
        UnitOfMeasureIdGlobal: Guid;

    local procedure RegisterFieldSet(FieldNo: Integer)
    var
        LastOrderNo: Integer;
    begin
        LastOrderNo := 1;
        IF TempFieldBuffer.FINDLAST() THEN
            LastOrderNo := TempFieldBuffer.Order + 1;

        CLEAR(TempFieldBuffer);
        TempFieldBuffer.Order := LastOrderNo;
        TempFieldBuffer."Table ID" := DATABASE::"Sales Invoice Line Aggregate";
        TempFieldBuffer."Field ID" := FieldNo;
        TempFieldBuffer.INSERT();
    end;

    local procedure RegisterItemFieldSet(FieldNo: Integer)
    begin
        IF TempItemFieldSet.GET(DATABASE::Item, FieldNo) THEN
            EXIT;

        TempItemFieldSet.INIT();
        TempItemFieldSet.TableNo := DATABASE::Item;
        TempItemFieldSet.VALIDATE("No.", FieldNo);
        TempItemFieldSet.INSERT(TRUE);
    end;

    local procedure InsertItemOnTheFly()
    var
        GraphCollectionMgtItem: Codeunit "Graph Collection Mgt - Item";
    begin
        GraphCollectionMgtItem.InsertItemFromSalesDocument(Item, TempItemFieldSet, UnitOfMeasureJSON);
        VALIDATE("No.", Item."No.");

        IF Description = '' THEN
            Description := Item.Description;
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
        UnitOfMeasureIdGlobal := "Unit of Measure Id";
    end;
}