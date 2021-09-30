// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 10537 "MTD Fraud Prevention Headers"
{
    Caption = 'HMRC Fraud Prevention Headers Setup';
    PageType = List;
    SourceTable = "MTD Default Fraud Prev. Hdr";
    AboutTitle = 'About Fraud Prevention Headers';
    AboutText = 'HMRC requires that all communication with their APIs contain fraud prevention headers. These headers provide information about the systems that communicate with their APIs. Business Central tries to get necessary information at the time when communication takes place, but to ensure headers are always provided, you must set up default values on this page.';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Header; Rec.Header)
                {
                    ToolTip = 'Specifies the name of a fraud prevention header as defined by HMRC.';
                    ApplicationArea = Basic, Suite;
                    StyleExpr = HeaderStyleExpr;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the fraud prevention header. You can change the description, which is not submitted to HMRC.';
                    ApplicationArea = Basic, Suite;
                }
                field(DefaultValue; Rec.Value)
                {
                    Caption = 'Default Value';
                    ToolTip = 'Specifies a default value for the header. The default value is used as a fallback value if the latest information cannot be retrieved at the time of reporting.';
                    ApplicationArea = Basic, Suite;
                }
                field(SampleValue; SampleValue)
                {
                    Caption = 'Sample Value';
                    ToolTip = 'Specifies current values for the headers when you chose the Get Current Headers action. Note that some values are user-specific. If you are not the user who will submit the fraud prevention data to HMRC, the data that you see can be misleading.';
                    ApplicationArea = Basic, Suite;
                    Visible = SampleValuesAreVisible;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Get Current Headers")
            {
                Caption = 'Get Current Headers';
                ToolTip = 'Retrieves data for the headers in the context of the current user. Note that these values are temporary,  and you can use the data for troubleshooting purposes.';
                Image = Continue;
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    MTDFraudPreventionMgt.GenerateSampleValues(TempSampleMTDDefaultFraudPrevHdr);
                    SampleValuesAreVisible := true;
                end;
            }
            action("Check Latest HMRC Request")
            {
                Caption = 'Check Latest HMRC Request';
                ToolTip = 'Fetch the latest HMRC request for missing headers.';
                Image = CheckList;
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    MTDFraudPreventionMgt.CheckForMissingHeadersFromSetup();
                end;
            }
        }
    }

    var
        MTDMissingFraudPrevHdr: Record "MTD Missing Fraud Prev. Hdr";
        TempSampleMTDDefaultFraudPrevHdr: Record "MTD Default Fraud Prev. Hdr" temporary;
        MTDFraudPreventionMgt: Codeunit "MTD Fraud Prevention Mgt.";
        SampleValue: Text;
        SampleValuesAreVisible: Boolean;
        HeaderStyleExpr: Text;

    trigger OnInit()
    begin
        MTDFraudPreventionMgt.CheckInitDefaultHeadersList();
    end;

    trigger OnAfterGetRecord()
    begin
        if MTDMissingFraudPrevHdr.Get(Header) then
            HeaderStyleExpr := 'Unfavorable'
        else
            HeaderStyleExpr := '';

        if TempSampleMTDDefaultFraudPrevHdr.Get(Rec.Header) then
            SampleValue := TempSampleMTDDefaultFraudPrevHdr.Value
        else
            SampleValue := '';
    end;
}

