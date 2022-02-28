page 30063 "APIV2 - Sales Shipment Lines"
{
    DelayedInsert = true;
    APIVersion = 'v2.0';
    EntityCaption = 'Sales Shipment Line';
    EntitySetCaption = 'Sales Shipment Lines';
    PageType = API;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = SystemId;
    EntityName = 'salesShipmentLine';
    EntitySetName = 'salesShipmentLines';
    SourceTable = "Sales Shipment Line";
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
                    Editable = false;
                }
                field(documentNo; "Document No.")
                {
                    Caption = 'Document No';
                }
                field(sequence; "Line No.")
                {
                    Caption = 'Sequence';
                }
                field(lineType; Type)
                {
                    Caption = 'Line Type';
                }
                field(lineObjectNumber; "No.")
                {
                    Caption = 'Line Object No.';
                }
                field(description; Description)
                {
                    Caption = 'Description';
                }
                field(unitOfMeasureCode; "Unit of Measure Code")
                {
                    Caption = 'Unit Of Measure Code';
                }
                field(unitPrice; "Unit Price")
                {
                    Caption = 'Unit Price';
                }
                field(quantity; Quantity)
                {
                    Caption = 'Quantity';
                }
                field(discountPercent; "Line Discount %")
                {
                    Caption = 'Discount Percent';
                }
                field(taxPercent; "VAT %")
                {
                    Caption = 'Tax Percent';
                    Editable = false;
                }
                field(shipmentDate; "Shipment Date")
                {
                    Caption = 'Shipment Date';
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = Field(SystemId), "Parent Type" = const("Sales Shipment Line");
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitions: Codeunit "Upgrade Tag Definitions";
    begin
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetNewSalesShipmentLineUpgradeTag()) then
            Error(SetupNotCompletedErr);
    end;

    var
        SetupNotCompletedErr: Label 'Data required by the API was not set up. To set up the data, invoke the action from the API Setup page.';
}