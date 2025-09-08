// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.API.V1;

using Microsoft.Purchases.Document;

page 6336 "Sustainability Purchase Line"
{
    APIGroup = 'sustainability';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    EntityCaption = 'Sustainability Purchase Line';
    EntitySetCaption = 'Sustainability Purchase Lines';
    PageType = API;
    DelayedInsert = true;
    EntityName = 'sustainabilityPurchaseLine';
    EntitySetName = 'sustainabilityPurchaseLines';
    ODataKeyFields = SystemId;
    SourceTable = "Purchase Line";
    Extensible = false;
    DeleteAllowed = false;
    SourceTableView = where("Sust. Account No." = filter('<>'''''));

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(documentType; Rec."Document Type")
                {
                    Caption = 'Document Type';
                }
                field(documentNumber; Rec."Document No.")
                {
                    Caption = 'Document Number';
                }
                field(lineNumber; Rec."Line No.")
                {
                    Caption = 'Line Number';
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(description2; Rec."Description 2")
                {
                    Caption = 'Description 2';
                }
                field(sustAccountNo; Rec."Sust. Account No.")
                {
                    Caption = 'Sustainability Account No.';
                }
                field(sustAccountName; Rec."Sust. Account Name")
                {
                    Caption = 'Sustainability Account Name';
                }
                field(energySourceCode; Rec."Energy Source Code")
                {
                    Caption = 'Energy Source Code';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(directUnitCost; Rec."Direct Unit Cost")
                {
                    Caption = 'Direct Unit Cost';
                }
                field(lineDiscount; Rec."Line Discount %")
                {
                    Caption = 'Line Discount %';
                }
                field(lineDiscountAmount; Rec."Line Discount Amount")
                {
                    Caption = 'Line Discount Amount';
                }
                field(amountIncludingVat; Rec."Amount Including VAT")
                {
                    Caption = 'Amount Including VAT';
                }
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount';
                }
                field(renewableEnergy; Rec."Renewable Energy")
                {
                    Caption = 'Renewable Energy';
                }
                field(emissionCO2; Rec."Emission CO2")
                {
                    Caption = 'Emission CO2';
                }
                field(emissionCH4; Rec."Emission CH4")
                {
                    Caption = 'Emission CH4';
                }
                field(emissionN2O; Rec."Emission N2O")
                {
                    Caption = 'Emission N2O';
                }
                field(energyConsumption; Rec."Energy Consumption")
                {
                    Caption = 'Energy Consumption';
                }
                field(sourceOfEmissionData; Rec."Source of Emission Data")
                {
                    Caption = 'Source of Emission Data';
                }
                field(emissionVerified; Rec."Emission Verified")
                {
                    Caption = 'Emission Verified';
                }
                field(cbamCompliance; Rec."CBAM Compliance")
                {
                    Caption = 'CBAM Compliance';
                }
                field(invoiceDiscountAmount; Rec."Inv. Discount Amount")
                {
                    Caption = 'Inv. Discount Amount';
                }
                field(totalEmissionCost; Rec."Total Emission Cost")
                {
                    Caption = 'Total Emission Cost';
                }
                field(jobNumber; Rec."Job No.")
                {
                    Caption = 'Job Number';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                field(unitCost; Rec."Unit Cost")
                {
                    Caption = 'Unit Cost';
                }
                field(lineAmount; Rec."Line Amount")
                {
                    Caption = 'Line Amount';
                }
            }
        }
    }
}