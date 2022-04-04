page 30043 "APIV2 - Sales Invoice Lines"
{
    DelayedInsert = true;
    APIVersion = 'v2.0';
    EntityCaption = 'Sales Invoice Line';
    EntitySetCaption = 'Sales Invoice Lines';
    PageType = API;
    ODataKeyFields = SystemId;
    EntityName = 'salesInvoiceLine';
    EntitySetName = 'salesInvoiceLines';
    SourceTable = "Sales Invoice Line Aggregate";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(documentId; "Document Id")
                {
                    Caption = 'Document Id';

                    trigger OnValidate()
                    begin
                        if (not IsNullGuid(xRec."Document Id")) and (xRec."Document Id" <> "Document Id") then
                            Error(CannotChangeDocumentIdNoErr);
                    end;
                }
                field(sequence; "Line No.")
                {
                    Caption = 'Sequence';

                    trigger OnValidate()
                    begin
                        if (xRec."Line No." <> "Line No.") and
                           (xRec."Line No." <> 0)
                        then
                            Error(CannotChangeLineNoErr);

                        RegisterFieldSet(FieldNo("Line No."));
                    end;
                }
                field(itemId; "Item Id")
                {
                    Caption = 'Item Id';

                    trigger OnValidate()
                    begin
                        if not Item.GetBySystemId("Item Id") then
                            Error(ItemDoesNotExistErr);

                        RegisterFieldSet(FieldNo(Type));
                        RegisterFieldSet(FieldNo("No."));
                        RegisterFieldSet(FieldNo("Item Id"));

                        "No." := Item."No.";
                    end;
                }
                field(accountId; "Account Id")
                {
                    Caption = 'Account Id';

                    trigger OnValidate()
                    var
                        GLAccount: Record "G/L Account";
                        EmptyGuid: Guid;
                    begin
                        if "Account Id" <> EmptyGuid then
                            if Item."No." <> '' then
                                Error(BothItemIdAndAccountIdAreSpecifiedErr);

                        if not GLAccount.GetBySystemId("Account Id") then
                            Error(AccountDoesNotExistErr);

                        RegisterFieldSet(FieldNo(Type));
                        RegisterFieldSet(FieldNo("Account Id"));
                        RegisterFieldSet(FieldNo("No."));
                    end;
                }
                field(lineType; "API Type")
                {
                    Caption = 'Line Type';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Type));
                    end;
                }
                field(lineObjectNumber; "No.")
                {
                    Caption = 'Line Object No.';

                    trigger OnValidate()
                    var
                        GLAccount: Record "G/L Account";
                    begin
                        if (xRec."No." <> "No.") and (xRec."No." <> '') then
                            Error(CannotChangeLineObjectNoErr);

                        case Rec."API Type" of
                            Rec."API Type"::Item:
                                begin
                                    if not Item.Get("No.") then
                                        Error(ItemDoesNotExistErr);

                                    RegisterFieldSet(FieldNo("Item Id"));
                                    "Item Id" := Item.SystemId;
                                end;
                            Rec."API Type"::Account:
                                begin
                                    if not GLAccount.Get("No.") then
                                        Error(AccountDoesNotExistErr);

                                    RegisterFieldSet(FieldNo("Account Id"));
                                    "Account Id" := GLAccount.SystemId;
                                end;
                        end;
                        RegisterFieldSet(FieldNo("No."));
                    end;
                }
                field(description; Description)
                {
                    Caption = 'Description';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Description));
                    end;
                }
                field(unitOfMeasureId; "Unit of Measure Id")
                {
                    Caption = 'Unit Of Measure Id';

                    trigger OnValidate()
                    var
                        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
                    begin
                        SalesInvoiceAggregator.VerifyCanUpdateUOM(Rec);
                        RegisterFieldSet(FieldNo("Unit of Measure Code"));
                    end;
                }
                field(unitOfMeasureCode; "Unit of Measure Code")
                {
                    Caption = 'Unit Of Measure Code';
                    trigger OnValidate()
                    var
                        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
                    begin
                        SalesInvoiceAggregator.VerifyCanUpdateUOM(Rec);
                        RegisterFieldSet(FieldNo("Unit of Measure Code"));
                    end;
                }
                field(unitPrice; "Unit Price")
                {
                    Caption = 'Unit Price';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Unit Price"));
                    end;
                }
                field(quantity; Quantity)
                {
                    Caption = 'Quantity';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Quantity));
                    end;
                }
                field(discountAmount; "Line Discount Amount")
                {
                    Caption = 'Discount Amount';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Line Discount Amount"));
                    end;
                }
                field(discountPercent; "Line Discount %")
                {
                    Caption = 'Discount Percent';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Line Discount %"));
                    end;
                }
                field(discountAppliedBeforeTax; "Discount Applied Before Tax")
                {
                    Caption = 'Discount Applied Before Tax';
                    Editable = false;
                }
                field(amountExcludingTax; "Line Amount Excluding Tax")
                {
                    Caption = 'Amount Excluding Tax';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Amount));
                    end;
                }
                field(taxCode; "Tax Code")
                {
                    Caption = 'Tax Code';

                    trigger OnValidate()
                    var
                        GeneralLedgerSetup: Record "General Ledger Setup";
                    begin
                        if GeneralLedgerSetup.UseVat() then begin
                            Validate("VAT Prod. Posting Group", COPYSTR("Tax Code", 1, 20));
                            RegisterFieldSet(FieldNo("VAT Prod. Posting Group"));
                        end else begin
                            Validate("Tax Group Code", COPYSTR("Tax Code", 1, 20));
                            RegisterFieldSet(FieldNo("Tax Group Code"));
                        end;
                    end;
                }
                field(taxPercent; "VAT %")
                {
                    Caption = 'Tax Percent';
                    Editable = false;
                }
                field(totalTaxAmount; "Line Tax Amount")
                {
                    Caption = 'Total Tax Amount';
                    Editable = false;
                }
                field(amountIncludingTax; "Line Amount Including Tax")
                {
                    Caption = 'Amount Including Tax';
                    Editable = false;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Amount Including VAT"));
                    end;
                }
                field(invoiceDiscountAllocation; "Inv. Discount Amount Excl. VAT")
                {
                    Caption = 'Invoice Discount Allocation';
                    Editable = false;
                }
                field(netAmount; Amount)
                {
                    Caption = 'Net Amount';
                    Editable = false;
                }
                field(netTaxAmount; "Tax Amount")
                {
                    Caption = 'Net Tax Amount';
                    Editable = false;
                }
                field(netAmountIncludingTax; "Amount Including VAT")
                {
                    Caption = 'Net Amount Including Tax';
                    Editable = false;
                }
                field(shipmentDate; "Shipment Date")
                {
                    Caption = 'Shipment Date';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Shipment Date"));
                    end;
                }
                field(itemVariantId; "Variant Id")
                {
                    Caption = 'Item Variant Id';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Variant Code"));
                    end;
                }
                field(locationId; "Location Id")
                {
                    Caption = 'Location Id';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Location Code"));
                    end;
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = Field(SystemId), "Parent Type" = const("Sales Invoice Line");
                }
                part(location; "APIV2 - Locations")
                {
                    Caption = 'Location';
                    EntityName = 'location';
                    EntitySetName = 'locations';
                    Multiplicity = ZeroOrOne;
                    SubPageLink = SystemId = field("Location Id");
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    var
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        SalesInvoiceAggregator.PropagateDeleteLine(Rec);
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
        GraphMgtSalesInvLines: Codeunit "Graph Mgt - Sales Inv. Lines";
        SysId: Guid;
        DocumentIdFilter: Text;
        IdFilter: Text;
        FilterView: Text;
    begin
        if not LinesLoaded then begin
            FilterView := GetView();
            IdFilter := GetFilter(SystemId);
            DocumentIdFilter := GetFilter("Document Id");
            if (IdFilter = '') and (DocumentIdFilter = '') then
                Error(IDOrDocumentIdShouldBeSpecifiedForLinesErr);
            if IdFilter <> '' then begin
                Evaluate(SysId, IdFilter);
                DocumentIdFilter := GraphMgtSalesInvLines.GetSalesInvoiceDocumentIdFilterFromSystemId(SysId);
            end else
                DocumentIdFilter := GetFilter("Document Id");
            SalesInvoiceAggregator.LoadLines(Rec, DocumentIdFilter);
            SetView(FilterView);
            if not FindFirst() then
                exit(false);
            LinesLoaded := true;
        end;

        exit(true);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        SalesInvoiceAggregator.PropagateInsertLine(Rec, TempFieldBuffer);
    end;

    trigger OnModifyRecord(): Boolean
    var
        SalesInvoiceAggregator: Codeunit "Sales Invoice Aggregator";
    begin
        SalesInvoiceAggregator.PropagateModifyLine(Rec, TempFieldBuffer);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
        RegisterFieldSet(FieldNo(Type));
    end;

    var
        TempFieldBuffer: Record "Field Buffer" temporary;
        TempItemFieldSet: Record 2000000041 temporary;
        Item: Record "Item";
        LinesLoaded: Boolean;
        IDOrDocumentIdShouldBeSpecifiedForLinesErr: Label 'You must specify an Id or a Document Id to get the lines.';
        CannotChangeDocumentIdNoErr: Label 'The value for "documentId" cannot be modified.', Comment = 'documentId is a field name and should not be translated.';
        CannotChangeLineNoErr: Label 'The value for "sequence" cannot be modified. Delete and insert the line again.', Comment = 'sequence is a field name and should not be translated.';
        BothItemIdAndAccountIdAreSpecifiedErr: Label 'Both "itemId" and "accountId" are specified. Specify only one of them.', Comment = 'itemId and accountId are field names and should not be translated.';
        ItemDoesNotExistErr: Label 'Item does not exist.';
        AccountDoesNotExistErr: Label 'Account does not exist.';
        CannotChangeLineObjectNoErr: Label 'The value for "lineObjectNumber" cannot be modified.', Comment = 'lineObjectNumber is a field name and should not be translated.';

    local procedure RegisterFieldSet(FieldNo: Integer)
    var
        LastOrderNo: Integer;
    begin
        LastOrderNo := 1;
        if TempFieldBuffer.FindLast() then
            LastOrderNo := TempFieldBuffer.Order + 1;

        Clear(TempFieldBuffer);
        TempFieldBuffer.Order := LastOrderNo;
        TempFieldBuffer."Table ID" := Database::"Sales Invoice Line Aggregate";
        TempFieldBuffer."Field ID" := FieldNo;
        TempFieldBuffer.Insert();
    end;

    local procedure ClearCalculatedFields()
    begin
        TempFieldBuffer.Reset();
        TempFieldBuffer.DeleteAll();
        TempItemFieldSet.Reset();
        TempItemFieldSet.DeleteAll();

        Clear(Item);
    end;
}