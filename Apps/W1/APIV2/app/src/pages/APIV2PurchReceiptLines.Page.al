namespace Microsoft.API.V2;

using Microsoft.Purchases.History;
using Microsoft.Upgrade;
using System.Upgrade;

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
    AboutText = 'Provides read-only access to detailed purchase receipt line data, including received items, quantities, unit costs, discounts, tax amounts, locations, and links to related purchase and sales orders. Supports GET operations for retrieving receipt line information to enable integration with warehouse management, automate inventory reconciliation, and facilitate three-way matching and supplier performance analysis. Ideal for external systems and reporting solutions that require accurate, up-to-date receipt line details for procurement and inventory workflows.';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(documentId; Rec."Document Id")
                {
                    Caption = 'Document Id';
                }
                field(sequence; Rec."Line No.")
                {
                    Caption = 'Sequence';
                }
                field(lineType; Rec.Type)
                {
                    Caption = 'Line Type';
                }
                field(lineObjectNumber; Rec."No.")
                {
                    Caption = 'Line Object No.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(description2; Rec."Description 2")
                {
                    Caption = 'Description 2';
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit Of Measure Code';
                }
                field(unitCost; Rec."Direct Unit Cost")
                {
                    Caption = 'Direct Unit Cost';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(discountPercent; Rec."Line Discount %")
                {
                    Caption = 'Discount Percent';
                }
                field(taxPercent; Rec."VAT %")
                {
                    Caption = 'Tax Percent';
                }
                field(expectedReceiptDate; Rec."Expected Receipt Date")
                {
                    Caption = 'Expected Receipt Date';
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = field(SystemId), "Parent Type" = const("Purchase Receipt Line");
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