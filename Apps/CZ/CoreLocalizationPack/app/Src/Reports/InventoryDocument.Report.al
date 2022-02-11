report 11752 "Inventory Document CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/InventoryDocument.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Inventory Document';
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
        dataitem("Invt. Document Header"; "Invt. Document Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Posting Date";

            column(No_InvtDocumentHeader; "No.")
            {
            }
            column(DocumentType_InvtDocumentHeader; "Document Type")
            {
            }
            column(DocumentTypeAsInteger_InvtDocumentHeader; "Document Type".AsInteger())
            {
            }
            column(PostingDate_InvtDocumentHeader; "Posting Date")
            {
                IncludeCaption = true;
            }
            column(DocumentDate_InvtDocumentHeader; "Document Date")
            {
                IncludeCaption = true;
            }
            dataitem("Invt. Document Line"; "Invt. Document Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemLinkReference = "Invt. Document Header";
                DataItemTableView = sorting("Document No.", "Document Type", "Line No.") where(Quantity = filter(<> 0));

                column(ItemNo_InvtDocumentLine; "Item No.")
                {
                    IncludeCaption = true;
                }
                column(Description_InvtDocumentLine; Description)
                {
                    IncludeCaption = true;
                }
                column(LocationCode_InvtDocumentLine; "Location Code")
                {
                    IncludeCaption = true;
                }
                column(UnitofMeasureCode_InvtDocumentLine; "Unit of Measure Code")
                {
                    IncludeCaption = true;
                }
                column(UnitAmount_InvtDocumentLine; "Unit Amount")
                {
                    IncludeCaption = true;
                }
                column(Quantity_InvtDocumentLine; Quantity)
                {
                    IncludeCaption = true;
                }
                column(Amount_InvtDocumentLine; Amount)
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
                CurrReport.Language := Language.GetLanguageIdOrDefault("Language Code");

                if not IsReportInPreviewMode() then
                    Codeunit.Run(Codeunit::"Invt. Document-Printed CZL", "Invt. Document Header");
            end;
        }
    }
    labels
    {
        PageLbl = 'Page';
        InventoryReceiptTestLbl = 'Inventory Receipt - Test';
        InventoryShipmentTestLbl = 'Inventory Shipment - Test';
        EstimatedAmountLbl = 'Estimated Amount';
        EstimatedUnitAmountLbl = 'Estimated Unit Amount';
        TotalLbl = 'Total';
    }

    var
        FormatAddress: Codeunit "Format Address";
        Language: Codeunit Language;
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
