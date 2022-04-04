report 11751 "Posted Inventory Receipt CZL"
{
    Permissions = TableData "Invt. Receipt Header" = r,
                  TableData "Invt. Receipt Line" = r;
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/PostedInventoryReceipt.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Posted Inventory Receipt';
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
        dataitem("Invt. Receipt Header"; "Invt. Receipt Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Posting Date";

            column(No_InvtReceiptHeader; "No.")
            {
            }
            column(PostingDate_InvtReceiptHeader; "Posting Date")
            {
                IncludeCaption = true;
            }
            column(DocumentDate_InvtReceiptHeader; "Document Date")
            {
                IncludeCaption = true;
            }
            column(RegisterUserID; GetRegisterUserIDCZL())
            {
            }
            dataitem("Invt. Receipt Line"; "Invt. Receipt Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemLinkReference = "Invt. Receipt Header";
                DataItemTableView = sorting("Document No.", "Line No.") where(Quantity = filter(<> 0));

                column(ItemNo_InvtReceiptLine; "Item No.")
                {
                    IncludeCaption = true;
                }
                column(Description_InvtReceiptLine; Description)
                {
                    IncludeCaption = true;
                }
                column(LocationCode_InvtReceiptLine; "Location Code")
                {
                    IncludeCaption = true;
                }
                column(UnitofMeasureCode_InvtReceiptLine; "Unit of Measure Code")
                {
                    IncludeCaption = true;
                }
                column(UnitAmount_InvtReceiptLine; "Unit Amount")
                {
                    IncludeCaption = true;
                }
                column(Quantity_InvtReceiptLine; Quantity)
                {
                    IncludeCaption = true;
                }
                column(Amount_InvtReceiptLine; Amount)
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
                    Codeunit.Run(Codeunit::"Posted Invt. Rcpt.-Printed CZL", "Invt. Receipt Header");
            end;
        }
    }
    labels
    {
        DocumentTypeLbl = 'Receipt';
        PageLbl = 'Page';
        PostedByLbl = 'Posted by';
        ReportNameLbl = 'Posted Inventory Receipt';
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
