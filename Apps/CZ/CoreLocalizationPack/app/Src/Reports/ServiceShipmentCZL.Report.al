// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.History;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;
using Microsoft.Inventory.Tracking;
using Microsoft.Service.Setup;
using System.Email;
using System.Globalization;
using System.Security.User;
using System.Utilities;
using Microsoft.CRM.Team;
using Microsoft.Utilities;

report 31199 "Service Shipment CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/ServiceShipment.rdl';
    Caption = 'Service Shipment';
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
            column(BankName_CompanyInformationCaption; FieldCaption("Bank Name"))
            {
            }
            column(BankName_CompanyInformation; "Bank Name")
            {
            }
            column(BankAccountNo_CompanyInformationCaption; FieldCaption("Bank Account No."))
            {
            }
            column(BankAccountNo_CompanyInformation; "Bank Account No.")
            {
            }
            dataitem("Service Mgt. Setup"; "Service Mgt. Setup")
            {
                DataItemTableView = sorting("Primary Key");
                column(LogoPositiononDocuments_ServiceMgtSetup; Format("Logo Position on Documents", 0, 2))
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
        dataitem("Service Shipment Header"; "Service Shipment Header")
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
            column(No_ServiceShipmentHeader; "No.")
            {
            }
            column(VATRegistrationNo_ServiceShipmentHeaderCaption; FieldCaption("VAT Registration No."))
            {
            }
            column(VATRegistrationNo_ServiceShipmentHeader; "VAT Registration No.")
            {
            }
            column(RegistrationNo_ServiceShipmentHeaderCaption; FieldCaption("Registration No. CZL"))
            {
            }
            column(RegistrationNo_ServiceShipmentHeader; "Registration No. CZL")
            {
            }
            column(DocumentDate_ServiceShipmentHeaderCaption; FieldCaption("Document Date"))
            {
            }
            column(DocumentDate_ServiceShipmentHeader; Format("Document Date"))
            {
            }
            column(OrderNoLbl; OrderNoLbl)
            {
            }
            column(OrderNo_ServiceShipmentHeader; "Order No.")
            {
            }
            column(YourReference_ServiceShipmentHeaderCaption; FieldCaption("Your Reference"))
            {
            }
            column(YourReference_ServiceShipmentHeader; "Your Reference")
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
                    DataItemLinkReference = "Service Shipment Header";
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
                dataitem("Service Shipment Item Line"; "Service Shipment Item Line")
                {
                    DataItemLink = "No." = field("No.");
                    DataItemLinkReference = "Service Shipment Header";
                    DataItemTableView = sorting("No.", "Line No.");
                    column(TABLECAPTION_ServiceShipmentItemLine; TableCaption)
                    {
                    }
                    column(ContractNo_ServiceShipmentItemLineCaption; FieldCaption("Contract No."))
                    {
                    }
                    column(ContractNo_ServiceShipmentItemLine; "Contract No.")
                    {
                    }
                    column(Des_ServiceShipmentItemLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Des_ServiceShipmentItemLine; Description)
                    {
                    }
                    column(SerialNo_ServiceShipmentItemLineCaption; FieldCaption("Serial No."))
                    {
                    }
                    column(SerialNo_ServiceShipmentItemLine; "Serial No.")
                    {
                    }
                    column(ItemNo_ServiceShipmentItemLineCaption; FieldCaption("Item No."))
                    {
                    }
                    column(ItemNo_ServiceShipmentItemLine; "Item No.")
                    {
                    }
                    column(ItemGrpCode_ServiceShipmentItemLineCaption; FieldCaption("Service Item Group Code"))
                    {
                    }
                    column(ItemGrpCode_ServiceShipmentItemLine; "Service Item Group Code")
                    {
                    }
                    column(ServItemNo_ServiceShipmentItemLineCaption; FieldCaption("Service Item No."))
                    {
                    }
                    column(ServItemNo_ServiceShipmentItemLine; "Service Item No.")
                    {
                    }
                    column(Warranty_ServiceShipmentItemLineCaption; FieldCaption(Warranty))
                    {
                    }
                    column(Warranty_ServiceShipmentItemLine; Format(Warranty))
                    {
                    }
                    column(LnNo_ServiceShipmentItemLine; "Line No.")
                    {
                    }
                }
                dataitem("Service Shipment Line"; "Service Shipment Line")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemLinkReference = "Service Shipment Header";
                    DataItemTableView = sorting("Document No.", "Line No.");
                    column(TABLECAPTION_ServiceShipmentLine; TableCaption)
                    {
                    }
                    column(LineNo_ServiceShipmentLine; "Line No.")
                    {
                    }
                    column(Type_ServiceShipmentLine; Format(Type, 0, 2))
                    {
                    }
                    column(No_ServiceShipmentLineCaption; FieldCaption("No."))
                    {
                    }
                    column(No_ServiceShipmentLine; "No.")
                    {
                    }
                    column(Description_ServiceShipmentLineCaption; FieldCaption(Description))
                    {
                    }
                    column(Description_ServiceShipmentLine; Description)
                    {
                    }
                    column(Quantity_ServiceShipmentLineCaption; FieldCaption(Quantity))
                    {
                    }
                    column(Quantity_ServiceShipmentLine; Quantity)
                    {
                    }
                    column(QuantityInvoiced_ServiceShipmentLineCaption; FieldCaption("Quantity Invoiced"))
                    {
                    }
                    column(QuantityInvoiced_ServiceShipmentLine; "Quantity Invoiced")
                    {
                    }
                    column(QuantityConsumed_ServiceShipmentLineCaption; FieldCaption("Quantity Consumed"))
                    {
                    }
                    column(QuantityConsumed_ServiceShipmentLine; "Quantity Consumed")
                    {
                    }
                    column(UnitofMeasure_ServiceShipmentLine; "Unit of Measure")
                    {
                    }
                    dataitem(ItemTrackingLine; "Integer")
                    {
                        DataItemTableView = sorting(Number);
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
                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then
                                TempTrackingSpecification.FindSet()
                            else
                                TempTrackingSpecification.Next();
                        end;

                        trigger OnPreDataItem()
                        begin
                            TempTrackingSpecification.SetRange("Source Ref. No.", "Service Shipment Line"."Line No.");

                            TrackingSpecCount := TempTrackingSpecification.Count();
                            if TrackingSpecCount = 0 then
                                CurrReport.Break();

                            SetRange(Number, 1, TrackingSpecCount);
                            TempTrackingSpecification.SetCurrentKey("Source ID", "Source Type", "Source Subtype", "Source Batch Name",
                              "Source Prod. Order Line", "Source Ref. No.");
                        end;
                    }
                }
                dataitem("User Setup"; "User Setup")
                {
                    DataItemLink = "User ID" = field("User ID");
                    DataItemLinkReference = "Service Shipment Header";
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
                        Codeunit.Run(Codeunit::"Service Shpt.-Printed", "Service Shipment Header");
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
            begin
                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");

                FormatAddress.ServiceShptShipTo(ShipToAddr, "Service Shipment Header");
                FormatAddress.ServiceShptBillTo(CustAddr, ShipToAddr, "Service Shipment Header");
                DocFooterText := FormatDocumentMgtCZL.GetDocumentFooterText("Language Code");

                ItemTrackingDocManagement.SetRetrieveAsmItemTracking(true);
                TrackingSpecCount :=
                  ItemTrackingDocManagement.RetrieveDocumentItemTracking(TempTrackingSpecification,
                    "No.", Database::"Service Shipment Header", 0);
                ItemTrackingDocManagement.SetRetrieveAsmItemTracking(false);

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
                    field(ShowLotSNCZL; ShowLotSN)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Serial/Lot Number Appendix';
                        ToolTip = 'Specifies when the show serial/lot number appendixis to be show';
                    }
                }
            }
        }
    }

    var
        TempTrackingSpecification: Record "Tracking Specification" temporary;
        LanguageMgt: Codeunit Language;
        FormatAddress: Codeunit "Format Address";
        FormatDocumentMgtCZL: Codeunit "Format Document Mgt. CZL";
        ItemTrackingDocManagement: Codeunit "Item Tracking Doc. Management";
        CompanyAddr: array[8] of Text[100];
        CustAddr: array[8] of Text[100];
        ShipToAddr: array[8] of Text[100];
        DocFooterText: Text[1000];
        NoOfCopies: Integer;
        NoOfLoops: Integer;
        ShowLotSN: Boolean;
        TrackingSpecCount: Integer;
        DocumentLbl: Label 'Shipment';
        PageLbl: Label 'Page';
        CopyLbl: Label 'Copy';
        VendLbl: Label 'Vendor';
        CustLbl: Label 'Customer';
        ShipToLbl: Label 'Ship-to';
        PaymentTermsLbl: Label 'Payment Terms';
        PaymentMethodLbl: Label 'Payment Method';
        SalespersonLbl: Label 'Salesperson';
        UoMLbl: Label 'UoM';
        CreatorLbl: Label 'Posted by';
        SubtotalLbl: Label 'Subtotal';
        DiscPercentLbl: Label 'Discount %';
        TotalLbl: Label 'total';
        VATLbl: Label 'VAT';
        OrderNoLbl: Label 'Order No.';

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;
}
