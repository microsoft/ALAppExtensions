// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.History;

using Microsoft.CRM.Team;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Document;
using Microsoft.Inventory.Item;
using System.Email;
using System.Globalization;

report 11750 "Posted Inventory Shipment CZL"
{
    Permissions = tabledata "Invt. Shipment Header" = r,
                  tabledata "Invt. Shipment Line" = r;
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/PostedInventoryShipment.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Posted Inventory Shipment';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Company Information"; "Company Information")
        {
            DataItemTableView = sorting("Primary Key");
            column(CompanyAddr1; CompanyAddr[1])
            {
            }
            column(CompanyAddr2; CompanyAddr[2])
            {
            }
            column(CompanyAddr3; CompanyAddr[3])
            {
            }
            column(CompanyAddr4; CompanyAddr[4])
            {
            }
            column(CompanyAddr5; CompanyAddr[5])
            {
            }
            column(CompanyAddr6; CompanyAddr[6])
            {
            }
            column(RegistrationNo_CompanyInformation; "Registration No.")
            {
                IncludeCaption = true;
            }
            column(VATRegistrationNo_CompanyInformation; "VAT Registration No.")
            {
                IncludeCaption = true;
            }

            trigger OnAfterGetRecord()
            begin
                FormatAddress.Company(CompanyAddr, "Company Information");
            end;
        }
        dataitem("Invt. Shipment Header"; "Invt. Shipment Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Posting Date";

            column(No_InvtShipmentHeader; "No.")
            {
            }
            column(PostingDate_InvtShipmentHeader; "Posting Date")
            {
                IncludeCaption = true;
            }
            column(DocumentDate_InvtShipmentHeader; "Document Date")
            {
                IncludeCaption = true;
            }
            column(RegisterUserID; GetRegisterUserIDCZL())
            {
            }
            column(PostingDescription_InvtShipmentHeader; "Posting Description")
            {
                IncludeCaption = true;
            }
            column(SalespersonCode_InvtShipmentHeader; SalespersonPurchaser.Code)
            {
                IncludeCaption = true;
            }
            column(SalespersonName_InvtShipmentHeader; SalespersonPurchaser.Name)
            {
                IncludeCaption = true;
            }
            column(ExternalDocumentNo_InvtShipmentHeader; "External Document No.")
            {
                IncludeCaption = true;
            }
            dataitem("Invt. Shipment Line"; "Invt. Shipment Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemLinkReference = "Invt. Shipment Header";
                DataItemTableView = sorting("Document No.", "Line No.") where(Quantity = filter(<> 0));

                column(ItemNo_InvtShipmentLine; "Item No.")
                {
                    IncludeCaption = true;
                }
                column(Description_InvtShipmentLine; Description)
                {
                    IncludeCaption = true;
                }
                column(LocationCode_InvtShipmentLine; "Location Code")
                {
                    IncludeCaption = true;
                }
                column(UnitofMeasureCode_InvtShipmentLine; "Unit of Measure Code")
                {
                    IncludeCaption = true;
                }
                column(UnitAmount_InvtShipmentLine; "Unit Amount")
                {
                }
                column(Quantity_InvtShipmentLine; Quantity)
                {
                    IncludeCaption = true;
                }
                column(Amount_InvtShipmentLine; Amount)
                {
                }
                column(VariantCode_InvtShipmentLine; "Variant Code")
                {
                    IncludeCaption = true;
                }
                column(BinCode_InvtShipmentLine; "Bin Code")
                {
                    IncludeCaption = true;
                }
                column(ItemCategoryCode_InvtShipmentLine; "Item Category Code")
                {
                    IncludeCaption = true;
                }

                trigger OnAfterGetRecord()
                begin
                    if Description = '' then
                        Description := GetItemDescription("Item No.");
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");
                SalespersonPurchaser.Get("Salesperson Code");

                if not IsReportInPreviewMode() then
                    Codeunit.Run(Codeunit::"Posted Invt. Shpt.-Printed CZL", "Invt. Shipment Header");
            end;
        }
    }
    labels
    {
        DocumentTypeLbl = 'Shipment';
        EstimatedAmountLbl = 'Estimated Amount';
        EstimatedUnitAmountLbl = 'Estimated Unit Amount';
        PageLbl = 'Page';
        PostedByLbl = 'Posted by';
        ReportNameLbl = 'Posted Inventory Shipment';
        TotalLbl = 'Total';
    }

    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        FormatAddress: Codeunit "Format Address";
        LanguageMgt: Codeunit Language;
        CompanyAddr: array[8] of Text[100];

    local procedure GetItemDescription(ItemNo: Code[20]) Description: Text[100]
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Description := Item.Description;
        if Item."Description 2" <> '' then
            Description += ' ' + Item."Description 2";
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;
}
