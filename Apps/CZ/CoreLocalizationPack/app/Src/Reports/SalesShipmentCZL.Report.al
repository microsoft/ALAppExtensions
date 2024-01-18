// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.CRM.Interaction;
using Microsoft.CRM.Segment;
using Microsoft.CRM.Team;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Shipping;
using Microsoft.HumanResources.Employee;
using Microsoft.Inventory.Reports;
using Microsoft.Inventory.Tracking;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Setup;
using Microsoft.Utilities;
using System.Email;
using System.Globalization;
using System.Security.User;
using System.Utilities;

report 31191 "Sales Shipment CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/SalesShipment.rdl';
    Caption = 'Sales Shipment';
    PreviewMode = PrintLayout;

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
            }
            column(VATRegistrationNo_CompanyInformation; "VAT Registration No.")
            {
            }
            column(HomePage_CompanyInformation; "Home Page")
            {
            }
            column(Picture_CompanyInformation; Picture)
            {
            }
            dataitem("Sales & Receivables Setup"; "Sales & Receivables Setup")
            {
                DataItemTableView = sorting("Primary Key");
                column(LogoPositiononDocuments_SalesReceivablesSetup; Format("Logo Position on Documents", 0, 2))
                {
                }
                dataitem("General Ledger Setup"; "General Ledger Setup")
                {
                    DataItemTableView = sorting("Primary Key");
                    column(LCYCode_GeneralLedgerSetup; "LCY Code")
                    {
                    }
                }
            }
            trigger OnAfterGetRecord()
            begin
                FormatAddress.Company(CompanyAddr, "Company Information");
            end;
        }
        dataitem("Sales Shipment Header"; "Sales Shipment Header")
        {
            column(DocumentLbl; DocumentLbl)
            {
            }
            column(PageLbl; PageLbl)
            {
            }
            column(CopyLbl; CopyLbl)
            {
            }
            column(VendorLbl; VendLbl)
            {
            }
            column(CustomerLbl; CustLbl)
            {
            }
            column(ShipToLbl; ShipToLbl)
            {
            }
            column(PaymentTermsLbl; PaymentTermsLbl)
            {
            }
            column(PaymentMethodLbl; PaymentMethodLbl)
            {
            }
            column(ShipmentMethodLbl; ShipmentMethodLbl)
            {
            }
            column(SalespersonLbl; SalespersonLbl)
            {
            }
            column(UoMLbl; UoMLbl)
            {
            }
            column(CreatorLbl; CreatorLbl)
            {
            }
            column(SubtotalLbl; SubtotalLbl)
            {
            }
            column(DiscPercentLbl; DiscPercentLbl)
            {
            }
            column(TotalLbl; TotalLbl)
            {
            }
            column(VATLbl; VATLbl)
            {
            }
            column(No_SalesShipmentHeader; "No.")
            {
            }
            column(VATRegistrationNo_SalesShipmentHeaderCaption; FieldCaption("VAT Registration No."))
            {
            }
            column(VATRegistrationNo_SalesShipmentHeader; "VAT Registration No.")
            {
            }
            column(RegistrationNo_SalesShipmentHeaderCaption; FieldCaption("Registration No. CZL"))
            {
            }
            column(RegistrationNo_SalesShipmentHeader; "Registration No. CZL")
            {
            }
            column(DocumentDate_SalesShipmentHeaderCaption; FieldCaption("Document Date"))
            {
            }
            column(DocumentDate_SalesShipmentHeader; Format("Document Date"))
            {
            }
            column(ShipmentDate_SalesShipmentHeaderCaption; FieldCaption("Shipment Date"))
            {
            }
            column(ShipmentDate_SalesShipmentHeader; Format("Shipment Date"))
            {
            }
            column(OrderNo_SalesShipmentHeaderCaption; FieldCaption("Order No."))
            {
            }
            column(OrderNo_SalesShipmentHeader; "Order No.")
            {
            }
            column(YourReference_SalesShipmentHeaderCaption; FieldCaption("Your Reference"))
            {
            }
            column(YourReference_SalesShipmentHeader; "Your Reference")
            {
            }
            column(ShipmentMethod; ShipmentMethod.Description)
            {
            }
            column(DocFooterText; DocFooterText)
            {
            }
            column(CustAddr1; CustAddr[1])
            {
            }
            column(CustAddr2; CustAddr[2])
            {
            }
            column(CustAddr3; CustAddr[3])
            {
            }
            column(CustAddr4; CustAddr[4])
            {
            }
            column(CustAddr5; CustAddr[5])
            {
            }
            column(CustAddr6; CustAddr[6])
            {
            }
            column(ShipToAddr1; ShipToAddr[1])
            {
            }
            column(ShipToAddr2; ShipToAddr[2])
            {
            }
            column(ShipToAddr3; ShipToAddr[3])
            {
            }
            column(ShipToAddr4; ShipToAddr[4])
            {
            }
            column(ShipToAddr5; ShipToAddr[5])
            {
            }
            column(ShipToAddr6; ShipToAddr[6])
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(CopyNo; Number)
                {
                }
                dataitem("Salesperson/Purchaser"; "Salesperson/Purchaser")
                {
                    DataItemLink = Code = field("Salesperson Code");
                    DataItemLinkReference = "Sales Shipment Header";
                    DataItemTableView = sorting(Code);
                    column(Name_SalespersonPurchaser; Name)
                    {
                    }
                    column(EMail_SalespersonPurchaser; "E-Mail")
                    {
                    }
                    column(PhoneNo_SalespersonPurchaser; "Phone No.")
                    {
                    }
                }
                dataitem("Sales Shipment Line"; "Sales Shipment Line")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemLinkReference = "Sales Shipment Header";
                    DataItemTableView = sorting("Document No.", "Line No.");
                    column(LineNo_SalesShipmentLine; "Line No.")
                    {
                    }
                    column(Type_SalesShipmentLine; Format(Type, 0, 2))
                    {
                    }
                    column(No_SalesShipmentLineCaption; FieldCaption("No."))
                    {
                    }
                    column(No_SalesShipmentLine; "No.")
                    {
                    }
                    column(Description_SalesShipmentLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_SalesShipmentLine; Description)
                    {
                    }
                    column(Quantity_SalesShipmentLineCaption; FieldCaption(Quantity))
                    {
                    }
                    column(Quantity_SalesShipmentLine; Quantity)
                    {
                    }
                    column(UnitofMeasure_SalesShipmentLine; "Unit of Measure")
                    {
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if not ShowCorrectionLines and "Sales Shipment Line".Correction then
                            CurrReport.Skip();
                    end;
                }
                dataitem(ItemTrackingLine; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(ItemNo_TrackingSpecBuffer; TempTrackingSpecification."Item No.")
                    {
                    }
                    column(Description_TrackingSpecBuffer; TempTrackingSpecification.Description)
                    {
                    }
                    column(LotNo_TrackingSpecBuffer; TempTrackingSpecification."Lot No.")
                    {
                    }
                    column(SerNo_TrackingSpecBuffer; TempTrackingSpecification."Serial No.")
                    {
                    }
                    column(Expiration_TrackingSpecBuffer; Format(TempTrackingSpecification."Expiration Date"))
                    {
                    }
                    column(Quantity_TrackingSpecBuffer; TempTrackingSpecification."Quantity (Base)")
                    {
                    }
                    column(ShowTotal; ShowTotal)
                    {
                    }
                    column(ShowGroup; ShowGroup)
                    {
                    }
                    column(QuantityCaption; QuantityCaptionLbl)
                    {
                    }
                    column(SerialNoCaption; SerialNoCaptionLbl)
                    {
                    }
                    column(LotNoCaption; LotNoCaptionLbl)
                    {
                    }
                    column(DescriptionCaption; DescriptionCaptionLbl)
                    {
                    }
                    column(NoCaption; NoCaptionLbl)
                    {
                    }
                    column(ExpirationDateCaption; ExpirationDateLbl)
                    {
                    }
                    dataitem(TotalItemTracking; "Integer")
                    {
                        DataItemTableView = sorting(Number) where(Number = const(1));
                        column(Quantity1; TotalQty)
                        {
                        }
                    }
                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then
                            TempTrackingSpecification.FindSet()
                        else
                            TempTrackingSpecification.Next();

                        if not ShowCorrectionLines and TempTrackingSpecification.Correction then
                            CurrReport.Skip();

                        if TempTrackingSpecification.Correction then
                            TempTrackingSpecification."Quantity (Base)" := -TempTrackingSpecification."Quantity (Base)";

                        ShowTotal := false;
                        if ItemTrackingAppendix.IsStartNewGroup(TempTrackingSpecification) then
                            ShowTotal := true;

                        ShowGroup := false;
                        if (TempTrackingSpecification."Source Ref. No." <> OldRefNo) or
                           (TempTrackingSpecification."Item No." <> OldNo)
                        then begin
                            OldRefNo := TempTrackingSpecification."Source Ref. No.";
                            OldNo := TempTrackingSpecification."Item No.";
                            TotalQty := 0;
                        end else
                            ShowGroup := true;
                        TotalQty += TempTrackingSpecification."Quantity (Base)";
                    end;

                    trigger OnPreDataItem()
                    begin
                        TrackingSpecCount := TempTrackingSpecification.Count();
                        if TrackingSpecCount = 0 then
                            CurrReport.Break();

                        SetRange(Number, 1, TrackingSpecCount);
                        TempTrackingSpecification.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Batch Name",
                          "Source Prod. Order Line", "Source Ref. No.");
                    end;

                    trigger OnPostDataItem()
                    begin
                        OldRefNo := 0;
                        ShowGroup := false;
                        TotalQty := 0;
                    end;
                }

                dataitem("User Setup"; "User Setup")
                {
                    DataItemLink = "User ID" = field("User ID");
                    DataItemLinkReference = "Sales Shipment Header";
                    DataItemTableView = sorting("User ID");
                    dataitem(Employee; Employee)
                    {
                        DataItemLink = "No." = field("Employee No. CZL");
                        DataItemTableView = sorting("No.");
                        column(FullName_Employee; FullName())
                        {
                        }
                        column(PhoneNo_Employee; "Phone No.")
                        {
                        }
                        column(CompanyEMail_Employee; "Company E-Mail")
                        {
                        }
                    }
                }
                trigger OnPostDataItem()
                begin
                    if not IsReportInPreviewMode() then
                        Codeunit.Run(Codeunit::"Sales Shpt.-Printed", "Sales Shipment Header");
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopies) + 1;
                    if NoOfLoops <= 0 then
                        NoOfLoops := 1;

                    SetRange(Number, 1, NoOfLoops);
                end;
            }
            trigger OnAfterGetRecord()
            var
                ItemTrackingDocHandlerCZL: Codeunit "Item Tracking Doc. Handler CZL";
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                FormatAddress.SalesShptShipTo(ShipToAddr, "Sales Shipment Header");
                FormatAddress.SalesShptBillTo(CustAddr, ShipToAddr, "Sales Shipment Header");
                FormatDocument.SetShipmentMethod(ShipmentMethod, "Shipment Method Code", "Language Code");
                DocFooterText := FormatDocumentMgtCZL.GetDocumentFooterText("Language Code");

                if LogInteraction and not IsReportInPreviewMode() then
                    SegManagement.LogDocument(
                      5, "No.", 0, 0, Database::Customer, "Sell-to Customer No.", "Salesperson Code",
                      "Campaign No.", "Posting Description", '');
                if ShowLotSN then begin
                    ItemTrackingDocManagement.SetRetrieveAsmItemTracking(true);
                    BindSubscription(ItemTrackingDocHandlerCZL);
                    TrackingSpecCount :=
                      ItemTrackingDocManagement.RetrieveDocumentItemTracking(TempTrackingSpecification,
                        "No.", Database::"Sales Shipment Header", 0);
                    UnbindSubscription(ItemTrackingDocHandlerCZL);
                    ItemTrackingDocManagement.SetRetrieveAsmItemTracking(false);
                end;

                if "Currency Code" = '' then
                    "Currency Code" := "General Ledger Setup"."LCY Code";
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(NoOfCopiesCZL; NoOfCopies)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies the number of copies to print.';
                    }
                    field(LogInteractionCZL; LogInteraction)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Log Interaction';
                        Enabled = LogInteractionEnable;
                        ToolTip = 'Specifies if you want the program to record the sales shipment you print as Interactions and add them to the Interaction Log Entry table.';
                    }
                    field("Show Correction Lines"; ShowCorrectionLines)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Correction Lines';
                        ToolTip = 'Specifies if the correction lines of an undoing of quantity posting will be shown on the report.';
                    }
                    field(ShowLotSNCZL; ShowLotSN)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Serial/Lot Number Appendix';
                        ToolTip = 'Specifies when the show serial/lot number appendixis to be show';
                    }
                }
            }
        }
        trigger OnInit()
        begin
            LogInteractionEnable := true;
        end;

        trigger OnOpenPage()
        begin
            InitLogInteraction();
            LogInteractionEnable := LogInteraction;
        end;
    }
    trigger OnPreReport()
    begin
        if not CurrReport.UseRequestPage then
            InitLogInteraction();
    end;

    var
        ShipmentMethod: Record "Shipment Method";
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        ItemTrackingAppendix: Report "Item Tracking Appendix";
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        FormatDocument: Codeunit "Format Document";
        FormatDocumentMgtCZL: Codeunit "Format Document Mgt. CZL";
        SegManagement: Codeunit SegManagement;
        ItemTrackingDocManagement: Codeunit "Item Tracking Doc. Management";
        CompanyAddr: array[8] of Text[100];
        CustAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        DocFooterText: Text[1000];
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        OldRefNo: Integer;
        OldNo: Code[20];
        LogInteraction: Boolean;
        ShowCorrectionLines: Boolean;
        LogInteractionEnable: Boolean;
        ShowLotSN: Boolean;
        ShowTotal: Boolean;
        ShowGroup: Boolean;
        TotalQty: Decimal;
        TrackingSpecCount: Integer;
        DocumentLbl: Label 'Shipment';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        ShipToLbl: Label 'Ship-to';
        PaymentTermsLbl: Label 'Payment Terms';
        PaymentMethodLbl: Label 'Payment Method';
        ShipmentMethodLbl: Label 'Shipment Method';
        SalespersonLbl: Label 'Salesperson';
        UoMLbl: Label 'UoM';
        CreatorLbl: Label 'Posted by';
        SubtotalLbl: Label 'Subtotal';
        DiscPercentLbl: Label 'Discount %';
        TotalLbl: Label 'total';
        VATLbl: Label 'VAT';
        QuantityCaptionLbl: Label 'Quantity';
        SerialNoCaptionLbl: Label 'Serial No.';
        LotNoCaptionLbl: Label 'Lot No.';
        DescriptionCaptionLbl: Label 'Description';
        NoCaptionLbl: Label 'No.';
        ExpirationDateLbl: Label 'Expiration Date';

    procedure InitLogInteraction()
    begin
        LogInteraction := SegManagement.FindInteractionTemplateCode(Enum::"Interaction Log Entry Document Type"::"Sales Shpt. Note") <> '';
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;
}
