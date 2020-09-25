// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

report 10530 "Get MTD Records"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(DataItem1040000; Integer)
        {
            MaxIteration = 1;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                field("Start Date"; StartDate)
                {
                    Caption = 'Start Date';
                    ToolTip = 'Specifies the date from which to return the records.';
                    ApplicationArea = Basic, Suite;
                }
                field("End Date"; EndDate)
                {
                    Caption = 'End Date';
                    ToolTip = 'Specifies the date to which to return the records.';
                    ApplicationArea = Basic, Suite;
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        var
            CaptionText: Text;
        begin
            case CaptionOption of
                CaptionOption::ReturnPeriods:
                    CaptionText := GetReturnPeriodsLbl;
                CaptionOption::Payments:
                    CaptionText := GetPaymentsLbl;
                CaptionOption::Liabilities:
                    CaptionText := GetLiabilitiesLbl;
            end;
            RequestOptionsPage.Caption(CaptionText);
        end;
    }

    labels
    {
    }

    trigger OnPostReport()
    var
        MTDMgt: Codeunit "MTD Mgt.";
        TotalCount: Integer;
        NewCount: Integer;
        ModifiedCount: Integer;
    begin
        case CaptionOption of
            CaptionOption::ReturnPeriods:
                MTDMgt.RetrieveVATReturnPeriods(StartDate, EndDate, TotalCount, NewCount, ModifiedCount, true, true);
            CaptionOption::Payments:
                MTDMgt.RetrievePayments(StartDate, EndDate, TotalCount, NewCount, ModifiedCount, true);
            CaptionOption::Liabilities:
                MTDMgt.RetrieveLiabilities(StartDate, EndDate, TotalCount, NewCount, ModifiedCount, true);
        end;
    end;

    var
        GetReturnPeriodsLbl: Label 'Get VAT Return Periods';
        GetPaymentsLbl: Label 'Get VAT Payments';
        GetLiabilitiesLbl: Label 'Get VAT Liabilities';
        CaptionOption: Option ReturnPeriods,Payments,Liabilities;
        StartDate: Date;
        EndDate: Date;

    internal procedure Initialize(NewCaptionOption: Option)
    begin
        CaptionOption := NewCaptionOption;
    end;
}

