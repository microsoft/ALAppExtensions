page 30065 "APIV2 - Purch Receipt Lines"
{
    DelayedInsert = true;
    APIVersion = 'v2.0';
    EntityCaption = 'Purchase Receipt Line';
    EntitySetCaption = 'Purchase Receipt Lines';
    PageType = API;
    ODataKeyFields = SystemId;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    EntityName = 'purchaseReceiptLine';
    EntitySetName = 'purchaseReceiptLines';
    SourceTable = "Purch. Rcpt. Line";
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
                field(unitCost; "Direct Unit Cost")
                {
                    Caption = 'Direct Unit Cost';
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
                }
                field(expectedReceiptDate; "Expected Receipt Date")
                {
                    Caption = 'Expected Receipt Date';
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = Field(SystemId), "Parent Type" = const("Purchase Receipt Line");
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
        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitions.GetNewPurchRcptLineUpgradeTag()) then
            Error(SetupNotCompletedErr);
    end;

    var
        SetupNotCompletedErr: Label 'Data required by the API was not set up. To set up the data, invoke the action from the API Setup page.';
}