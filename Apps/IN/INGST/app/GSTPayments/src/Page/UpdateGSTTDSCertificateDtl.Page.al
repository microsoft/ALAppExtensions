// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

using Microsoft.Sales.Customer;

page 18250 "Update GST TDS Certificate Dtl"
{
    Caption = 'Update GST TDS Certificate Details';
    PageType = Card;
    ApplicationArea = Basic, Suite;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(CustomerNo; CustomerNo)
            {
                Caption = 'Customer No.';
                TableRelation = Customer where("GST Customer Type" = filter(Registered));
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the customer number of the GST TDS/TCS Entry.';
            }
            field(CertificateNo; CertificateNo)
            {
                Caption = 'Certificate No.';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the received certificate number for the entry.';
            }
            field(CertificateDate; CertificateDate)
            {
                Caption = 'Date of Receipt';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the date on which TDS certificate has been received.';
            }
            field(Rectify; Rectify)
            {
                Caption = 'Rectify';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the certificate number and date of receipt is for rectification or not.';
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";

                action("Update TDS Cert. Details")
                {
                    Caption = 'Update TDS Cert. Details';
                    Image = RefreshVATExemption;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the function to update customer number, certificate number, date of receipts of certificate and rectification details on GST TDS/TCS Entry table.';

                    trigger OnAction()
                    begin
                        OnActionUpdateTDSCertDetails();
                    end;
                }
            }
        }
    }

    var
        CustomerNo: Code[10];
        CertificateNo: Code[20];
        CertificateDate: Date;
        Rectify: Boolean;
        CustomerMandatoryErr: Label 'Please enter Customer No.', Locked = true;
        CertificateMandatoryErr: Label 'Please enter Certificate No.', Locked = true;
        DateMandatoryErr: Label 'Please enter Date of Receipt.', Locked = true;
        NoRecordsErr: Label 'No records found.', Locked = true;

    local procedure OnActionUpdateTDSCertDetails()
    var
        GSTTdsTcsEntry: Record "GST TDS/TCS Entry";
        UpdateGSTTDSCertDetails: Page "Update GST TDS Cert. Details";
    begin
        if CustomerNo = '' then
            Error(CustomerMandatoryErr);

        if CertificateNo = '' then
            Error(CertificateMandatoryErr);

        if CertificateDate = 0D then
            Error(DateMandatoryErr);

        UpdateGSTTDSCertDetails.SetCertificateDetail(CertificateNo, CertificateDate, CustomerNo, Rectify);
        GSTTdsTcsEntry.SetRange("Source No.", CustomerNo);
        GSTTdsTcsEntry.SetRange(Type, GSTTdsTcsEntry.Type::TDS);
        if Rectify then begin
            GSTTdsTcsEntry.SetRange("Certificate No.", CertificateNo);
            GSTTdsTcsEntry.SetRange(Paid, false);
        end else
            GSTTdsTcsEntry.SetRange("Certificate No.", '');

        GSTTdsTcsEntry.SetRange(Reversed, false);
        if GSTTdsTcsEntry.IsEmpty then
            Error(NoRecordsErr);

        UpdateGSTTDSCertDetails.Run();
        CurrPage.Close();
    end;
}
