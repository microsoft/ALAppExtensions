// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

report 31064 "VIES Declaration - Test CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/VIESDeclarationTest.rdl';
    Caption = 'VIES Declaration - Test';

    dataset
    {
        dataitem(VIESDeclarationHeaderCZL; "VIES Declaration Header CZL")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            column(COMPANYNAME; CompanyProperty.DisplayName())
            {
            }
            column(VIESDeclarationHeader_No; "No.")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_VATRegistrationNo; "VAT Registration No.")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_TradeType; "Trade Type")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_PeriodNo; "Period No.")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_Year; Year)
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_StartDate; "Start Date")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_EndDate; "End Date")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_Name; Name)
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_Name2; "Name 2")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_CountryRegionName; "Country/Region Name")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_County; County)
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_MunicipalityNo; "Municipality No.")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_Street; Street)
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_HouseNo; "House No.")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_ApartmentNo; "Apartment No.")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_City; City)
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_PostCode; "Post Code")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_TaxOfficeNumber; "Tax Office Number")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_DeclarationType; "Declaration Type")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_CorrectedDeclarationNo; "Corrected Declaration No.")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_DocumentDate; "Document Date")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_AuthorizedEmployeeNo; "Authorized Employee No.")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_FilledByEmployeeNo; "Filled by Employee No.")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_PurchaseAmountLCY; "Purchase Amount (LCY)")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_SalesAmountLCY; "Sales Amount (LCY)")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_AmountLCY; "Amount (LCY)")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_NumberOfSupplies; "Number of Supplies")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_EU_Goods_Services; "EU Goods/Services")
            {
                IncludeCaption = true;
            }
            column(VIESDeclarationHeader_DeclarationPeriod; "Declaration Period")
            {
                IncludeCaption = true;
            }
            dataitem(HeaderErrorCounter; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(HeaderError; ErrorText[Number])
                {
                }
                trigger OnPreDataItem()
                begin
                    SetRange(Number, 1, ErrorCounter);
                end;

                trigger OnPostDataItem()
                begin
                    Clear(ErrorCounter);
                    Clear(ErrorText);
                end;
            }
            dataitem(VIESDeclarationLineCZL; "VIES Declaration Line CZL")
            {
                DataItemLink = "VIES Declaration No." = field("No.");
                DataItemLinkReference = VIESDeclarationHeaderCZL;
                DataItemTableView = sorting("VIES Declaration No.", "Line No.");
                column(VIESDeclarationLine_TradeType; "Trade Type")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationLine_LineType; "Line Type")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationLine_CountryRegionCode; "Country/Region Code")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationLine_VATRegistrationNo; "VAT Registration No.")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationLine_RegistrationNo; "Registration No.")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationLine_EU3PartyTrade; "EU 3-Party Trade")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationLine_EU3PartyIntermediateRole; "EU 3-Party Intermediate Role")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationLine_TradeRoleType; "Trade Role Type")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationLine_AmountLCY; "Amount (LCY)")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationLine_CorrectedRegNo; "Corrected Reg. No.")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationLine_CorectedAmount; "Corrected Amount")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationLine_RecordCode; "Record Code")
                {
                    IncludeCaption = true;
                }
                column(VIESDeclarationLine_VATRegNoOfOriginalCust; "VAT Reg. No. of Original Cust.")
                {
                    IncludeCaption = true;
                }
                dataitem(LineErrorCounter; "Integer")
                {
                    DataItemTableView = sorting(Number);
                    column(LineError; ErrorText[Number])
                    {
                    }
                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, ErrorCounter);
                    end;

                    trigger OnPostDataItem()
                    begin
                        Clear(ErrorCounter);
                        Clear(ErrorText);
                    end;
                }
                trigger OnAfterGetRecord()
                begin
                    if "Country/Region Code" = '' then
                        AddNotSpecifiedError(FieldCaption("Country/Region Code"));
                    if "VAT Registration No." = '' then
                        AddNotSpecifiedError(FieldCaption("VAT Registration No."));
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if "VAT Registration No." = '' then
                    AddNotSpecifiedError(FieldCaption("VAT Registration No."));
                if "Start Date" = 0D then
                    AddNotSpecifiedError(FieldCaption("Start Date"));
                if "End Date" = 0D then
                    AddNotSpecifiedError(FieldCaption("End Date"));
                if Name = '' then
                    AddNotSpecifiedError(FieldCaption(Name));
                if "Country/Region Name" = '' then
                    AddNotSpecifiedError(FieldCaption("Country/Region Name"));
                if "Municipality No." = '' then
                    AddNotSpecifiedError(FieldCaption("Municipality No."));
                if Street = '' then
                    AddNotSpecifiedError(FieldCaption(Street));
                if "House No." = '' then
                    AddNotSpecifiedError(FieldCaption("House No."));
                if "Apartment No." = '' then
                    AddNotSpecifiedError(FieldCaption("Apartment No."));
                if City = '' then
                    AddNotSpecifiedError(FieldCaption(City));
                if "Post Code" = '' then
                    AddNotSpecifiedError(FieldCaption("Post Code"));
                if "Tax Office Number" = '' then
                    AddNotSpecifiedError(FieldCaption("Tax Office Number"));
                if "Document Date" = 0D then
                    AddNotSpecifiedError(FieldCaption("Document Date"));
                if "Filled by Employee No." = '' then
                    AddNotSpecifiedError(FieldCaption("Filled by Employee No."));
                if "Authorized Employee No." = '' then
                    AddNotSpecifiedError(FieldCaption("Authorized Employee No."));
                if "Declaration Type" = "Declaration Type"::Corrective then
                    if "Corrected Declaration No." = '' then
                        AddNotSpecifiedError(FieldCaption("Corrected Declaration No."));
            end;
        }
    }
    labels
    {
        ReportCaptionLbl = 'VIES Declaration - Test';
        PageLbl = 'Page';
        SectionBLbl = 'SECTION B';
        SectionCLbl = 'SECTION C';
    }
    var
        ErrorText: array[99] of Text;
        ErrorCounter: Integer;

    local procedure AddNotSpecifiedError(Text: Text)
    var
        FieldNotSpecifiedErr: Label '%1 must be specified.', Comment = '%1 = FieldCaption';
    begin
        if ErrorCounter > 99 then
            exit;
        ErrorCounter += 1;
        ErrorText[ErrorCounter] := StrSubstNo(FieldNotSpecifiedErr, Text);
    end;
}
