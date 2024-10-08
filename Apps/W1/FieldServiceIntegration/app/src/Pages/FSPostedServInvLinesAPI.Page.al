// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Foundation.UOM;
using Microsoft.Service.History;
using Microsoft.API.V2;

page 6617 "FS Posted Serv. Inv. Lines API"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Posted Service Invoice Line';
    EntitySetCaption = 'Posted Service Invoice Lines';
    PageType = API;
    ODataKeyFields = SystemId;
    EntityName = 'postedServiceInvoiceLine';
    EntitySetName = 'postedServiceInvoiceLines';
    SourceTable = "Service Invoice Line";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

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
                field(documentId; ServiceInvoiceHeader.SystemId)
                {
                    Caption = 'Document Id';
                }
                field(sequence; Rec."Line No.")
                {
                    Caption = 'Sequence';
                }
                field(itemId; Item.SystemId)
                {
                    Caption = 'Item Id';
                }
                field(accountId; GLAccount.SystemId)
                {
                    Caption = 'Account Id';
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
                field(unitOfMeasureId; UnitOfMeasure.SystemId)
                {
                    Caption = 'Unit Of Measure Id';
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit Of Measure Code';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
                }
                field(discountAmount; Rec."Line Discount Amount")
                {
                    Caption = 'Discount Amount';
                }
                field(discountPercent; Rec."Line Discount %")
                {
                    Caption = 'Discount Percent';
                }
                field(discountAppliedBeforeTax; Rec."Line Discount Amount")
                {
                    Caption = 'Discount Applied Before Tax';
                    Editable = false;
                }
                field(amountExcludingTax; Rec."Line Amount")
                {
                    Caption = 'Amount Excluding Tax';
                    Editable = false;
                }
                field(taxCode; Rec."VAT %")
                {
                    Caption = 'Tax Code';
                }
                field(taxPercent; Rec."VAT %")
                {
                    Caption = 'Tax Percent';
                    Editable = false;
                }
                field(amountIncludingTax; Rec."Amount Including VAT")
                {
                    Caption = 'Amount Including Tax';
                    Editable = false;
                }
                field(netAmount; Rec.Amount)
                {
                    Caption = 'Net Amount';
                    Editable = false;
                }
                field(netAmountIncludingTax; Rec."Amount Including VAT")
                {
                    Caption = 'Net Amount Including Tax';
                    Editable = false;
                }
                field(itemVariantId; ItemVariant.SystemId)
                {
                    Caption = 'Item Variant Id';
                }
                field(locationId; Location.SystemId)
                {
                    Caption = 'Location Id';
                }
                part(dimensionSetLines; "APIV2 - Dimension Set Lines")
                {
                    Caption = 'Dimension Set Lines';
                    EntityName = 'dimensionSetLine';
                    EntitySetName = 'dimensionSetLines';
                    SubPageLink = "Parent Id" = field(SystemId);
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if not ServiceInvoiceHeader.Get(Rec."Document No.") then
            clear(ServiceInvoiceHeader);

        Clear(Item);
        Clear(GLAccount);
        case Rec.Type of
            Rec.Type::Item:
                if not Item.Get(Rec."No.") then
                    Clear(Item);
            Rec.Type::"G/L Account":
                if not GLAccount.Get(Rec."No.") then
                    Clear(GLAccount);
        end;

        if not UnitOfMeasure.Get(Rec."Unit of Measure Code") then
            Clear(UnitOfMeasure);
        if not Location.Get(Rec."Location Code") then
            Clear(Location);
        if not ItemVariant.Get(Item."No.", Rec."Variant Code") then
            Clear(ItemVariant);
    end;

    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        Item: Record Item;
        GLAccount: Record "G/L Account";
        UnitOfMeasure: Record "Unit of Measure";
        ItemVariant: Record "Item Variant";
        Location: Record Location;
}