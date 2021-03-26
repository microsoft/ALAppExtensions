tableextension 11709 "Item Journal Line CZL" extends "Item Journal Line"
{
    fields
    {
        field(31050; "Tariff No. CZL"; Code[20])
        {
            Caption = 'Tariff No.';
            TableRelation = "Tariff Number";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Tariff No. CZL" <> xRec."Tariff No. CZL" then
                    "Statistic Indication CZL" := '';
            end;
        }
        field(31051; "Physical Transfer CZL"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;
        }
        field(31052; "Incl. in Intrastat Amount CZL"; Boolean)
        {
            Caption = 'Incl. in Intrastat Amount';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Item Charge No.");
            end;
        }
        field(31053; "Incl. in Intrastat S.Value CZL"; Boolean)
        {
            Caption = 'Incl. in Intrastat Stat. Value';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Item Charge No.");
            end;
        }
        field(31054; "Net Weight CZL"; Decimal)
        {
            Caption = 'Net Weight';
            DecimalPlaces = 0 : 5;
            DataClassification = CustomerContent;
        }
        field(31057; "Country/Reg. of Orig. Code CZL"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(31058; "Statistic Indication CZL"; Code[10])
        {
            Caption = 'Statistic Indication';
            TableRelation = "Statistic Indication CZL".Code where("Tariff No." = field("Tariff No. CZL"));
            DataClassification = CustomerContent;
        }
        field(31059; "Intrastat Transaction CZL"; Boolean)
        {
            Caption = 'Intrastat Transaction';
            DataClassification = CustomerContent;
        }
        field(31079; "Invt. Movement Template CZL"; Code[10])
        {
            Caption = 'Inventory Movement Template';
            TableRelation = "Invt. Movement Template CZL";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                InvtMovementTemplateCZL: Record "Invt. Movement Template CZL";
                ItemJournalTemplate: Record "Item Journal Template";
            begin
                if InvtMovementTemplateCZL.Get("Invt. Movement Template CZL") then begin
                    ItemJournalTemplate.Get("Journal Template Name");
                    case ItemJournalTemplate.Type of
                        ItemJournalTemplate.Type::Transfer:
                            InvtMovementTemplateCZL.TestField("Entry Type", InvtMovementTemplateCZL."Entry Type"::Transfer);
                        ItemJournalTemplate.Type::"Phys. Inventory":
                            if CurrFieldNo = FieldNo("Invt. Movement Template CZL") then
                                InvtMovementTemplateCZL.TestField("Entry Type", "Entry Type");
                    end;
                    if ItemJournalTemplate.Type <> ItemJournalTemplate.Type::"Phys. Inventory" then
                        Validate("Entry Type", InvtMovementTemplateCZL."Entry Type");
                    Validate("Gen. Bus. Posting Group", InvtMovementTemplateCZL."Gen. Bus. Posting Group");
                end;
            end;
        }
        field(11764; "G/L Correction CZL"; Boolean)
        {
            Caption = 'G/L Correction';
            DataClassification = CustomerContent;
        }
    }

    procedure CheckIntrastatCZL()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        Item: Record Item;
        MandatoryFieldErr: Label '%1 is required for Item %2.', Comment = '%1 = fieldcaption, %2 = No. of inventoriable item';
    begin
        Item.Get("Item No.");
        if "Intrastat Transaction CZL" and Item.IsInventoriableType() then begin
            StatutoryReportingSetupCZL.Get();
            if StatutoryReportingSetupCZL."Transaction Type Mandatory" and ("Transaction Type" = '') then
                Error(MandatoryFieldErr, FieldCaption("Transaction Type"), "Item No.");
            if StatutoryReportingSetupCZL."Transaction Spec. Mandatory" and ("Transaction Specification" = '') then
                Error(MandatoryFieldErr, FieldCaption("Transaction Specification"), "Item No.");
            if StatutoryReportingSetupCZL."Transport Method Mandatory" and ("Transport Method" = '') then
                Error(MandatoryFieldErr, FieldCaption("Transport Method"), "Item No.");
            if StatutoryReportingSetupCZL."Shipment Method Mandatory" and ("Shpt. Method Code" = '') then
                Error(MandatoryFieldErr, FieldCaption("Shpt. Method Code"), "Item No.");
            if StatutoryReportingSetupCZL."Tariff No. Mandatory" and ("Tariff No. CZL" = '') then
                Error(MandatoryFieldErr, FieldCaption("Tariff No. CZL"), "Item No.");
            if StatutoryReportingSetupCZL."Net Weight Mandatory" and ("Net Weight CZL" = 0) then
                Error(MandatoryFieldErr, FieldCaption("Net Weight CZL"), "Item No.");
            if StatutoryReportingSetupCZL."Country/Region of Origin Mand." and
               ("Country/Reg. of Orig. Code CZL" = '') and ("Entry Type" <> "Entry Type"::Sale)
            then
                Error(MandatoryFieldErr, FieldCaption("Country/Reg. of Orig. Code CZL"), "Item No.");
        end;
    end;

    procedure CopyFromTransferLineCZL(TransferLine: Record "Transfer Line")
    var
        TransferHeader: Record "Transfer Header";
    begin
        "Tariff No. CZL" := TransferLine."Tariff No. CZL";
        "Statistic Indication CZL" := TransferLine."Statistic Indication CZL";
        "Net Weight CZL" := TransferLine."Net Weight";
        // recalc to base UOM
        if "Net Weight CZL" <> 0 then
            if TransferLine."Qty. per Unit of Measure" <> 0 then
                "Net Weight CZL" := Round("Net Weight CZL" / TransferLine."Qty. per Unit of Measure", 0.00001);
        "Country/Reg. of Orig. Code CZL" := TransferLine."Country/Reg. of Orig. Code CZL";
        TransferHeader.Get(TransferLine."Document No.");
        "Intrastat Transaction CZL" := TransferHeader.IsIntrastatTransactionCZL();
    end;

    procedure CopyFromServiceShipmentLineCZL(ServiceShipmentLine: Record "Service Shipment Line")
    begin
        "Tariff No. CZL" := ServiceShipmentLine."Tariff No. CZL";
        "Statistic Indication CZL" := ServiceShipmentLine."Statistic Indication CZL";
        "Net Weight CZL" := ServiceShipmentLine."Net Weight";
        // recalc to base UOM
        if "Net Weight CZL" <> 0 then
            if ServiceShipmentLine."Qty. per Unit of Measure" <> 0 then
                "Net Weight CZL" := Round("Net Weight CZL" / ServiceShipmentLine."Qty. per Unit of Measure", 0.00001);
    end;
}
